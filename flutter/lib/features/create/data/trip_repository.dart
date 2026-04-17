import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/domain/trip.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class TripRepository {
  TripRepository(
    this._db,
    this._authService, {
    openapi.TripsApi? tripsApi,
  }) : _tripsApi = tripsApi;

  final AppDatabase _db;
  final AuthService _authService;
  final openapi.TripsApi? _tripsApi;
  static final Map<String, Future<String>> _ensureRemoteTripIdInFlight = {};

  Future<Trip?> getTrip(String id) async {
    final row = await _db.tripDao.getTripById(id);
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

  /// Hydrates a trip from the backend into the local editor `trips` table.
  ///
  /// Used when a trip exists in `user_trips` (synced from server) but not in
  /// the editor workspace. For server-synced trips, `tripId` is the remote
  /// UUID. Fetches full trip details from backend and persists locally so the
  /// editor can open it.
  Future<Trip?> hydrateTripFromBackend(String tripId) async {
    final userTrip = await _db.userTripsDao.getTripById(tripId);
    if (userTrip == null) {
      return null;
    }

    final tripsApi = _tripsApi;
    if (tripsApi == null) {
      return null;
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await tripsApi.getTripApiV1TripsTripIdGet(
        tripId: tripId,
        authorization: 'Bearer $token',
      );
      final data = response.data;
      if (data == null) {
        return null;
      }

      final now = DateTime.now();
      final startDate = data.startDate;
      final endDate = data.endDate;
      final trip = Trip(
        id: tripId,
        serverTripId: tripId,
        userId: userTrip.userId,
        name: data.title,
        description: data.description,
        startDate: startDate != null
            ? DateTime(startDate.year, startDate.month, startDate.day)
            : null,
        endDate: endDate != null
            ? DateTime(endDate.year, endDate.month, endDate.day)
            : null,
        tags: const [],
        visibility: data.visibility,
        localUpdatedAt: now,
        serverUpdatedAt: data.updatedAt,
        syncStatus: 'synced',
      );

      await _upsertTripRow(trip);
      return trip;
    } catch (_) {
      return null;
    }
  }

  /// Creates a trip on the server immediately, then stores locally with
  /// `serverTripId` already set. Requires network — throws [TripIdentityException]
  /// if offline or API unavailable.
  Future<Trip> createTrip({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    List<String> tags = const [],
    String visibility = 'private',
  }) async {
    final userId = _authService.currentUser?.id ?? 'mock-user';
    final now = DateTime.now();
    final localId = const Uuid().v4();

    // Server-first: create on backend before local persistence.
    final serverTripId = await _createTripOnServer(
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      visibility: visibility,
    );

    final trip = Trip(
      id: localId,
      serverTripId: serverTripId,
      userId: userId,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      tags: tags,
      visibility: visibility,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'synced',
    );

    await _upsertTripRow(trip);
    await _upsertUserTrip(trip, createdAt: now);

    return trip;
  }

  /// Updates a trip on the server immediately, then persists locally.
  /// Trip metadata is online-authoritative for this stabilization wave.
  Future<Trip> updateTrip(Trip trip) async {
    final now = DateTime.now();
    var serverTripId = trip.serverTripId?.trim();
    if (serverTripId == null || serverTripId.isEmpty) {
      try {
        serverTripId = await ensureRemoteTripId(trip.id, allowCreate: true);
      } on TripIdentityException catch (error) {
        throw TripIdentityException(
          'Trip is not synced to server yet. Connect and retry update. '
          '(${error.message})',
          retryable: error.retryable,
        );
      }
    }

    try {
      await _updateTripOnServer(
        serverTripId: serverTripId,
        name: trip.name,
        description: trip.description,
        startDate: trip.startDate,
        endDate: trip.endDate,
        visibility: trip.visibility,
      );
    } on DioException catch (error) {
      throw TripIdentityException(
        _mapTripUpdateFailure(error),
        retryable: _isRetryableDio(error),
      );
    }

    final updated = trip.copyWith(
      serverTripId: serverTripId,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'synced',
    );

    await _upsertTripRow(updated);
    await _upsertUserTrip(updated);
    return updated;
  }

  /// Deletes a trip from the server immediately, then removes locally.
  /// Requires network for server-backed trips.
  Future<void> deleteTrip(String id) async {
    final existing = await _db.tripDao.getTripById(id);
    if (existing == null) {
      return;
    }

    // Delete from server first if it exists there.
    final serverTripId = existing.serverTripId;
    if (serverTripId != null && serverTripId.isNotEmpty) {
      await deleteRemoteTripById(serverTripId);
    }

    await _db.routeDao.deleteRoutesForTrip(id);
    await _db.placeDao.deletePlacesForTrip(id);
    await _db.tripDao.deleteTrip(id);
    await _db.userTripsDao.deleteTrip(id);
  }

  /// Direct server call to create a trip. Returns server-assigned trip ID.
  Future<String> _createTripOnServer({
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String visibility = 'private',
  }) async {
    final tripsApi = _tripsApi;
    if (tripsApi == null) {
      throw const TripIdentityException(
        'Internet connection required to create a trip.',
      );
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const TripIdentityException(
        'Please sign in before creating a trip.',
        retryable: true,
      );
    }

    final payload = openapi.TripCreate((builder) {
      builder
        ..title = name
        ..description = description
        ..visibility = visibility;
      if (startDate != null) {
        builder.startDate =
            openapi.Date(startDate.year, startDate.month, startDate.day);
      }
      if (endDate != null) {
        builder.endDate =
            openapi.Date(endDate.year, endDate.month, endDate.day);
      }
    });

    openapi.TripResponse? responseData;
    try {
      final response = await tripsApi.createTripApiV1TripsPost(
        authorization: 'Bearer $token',
        tripCreate: payload,
      );
      responseData = response.data;
    } on DioException catch (error) {
      throw TripIdentityException(_mapTripCreateFailure(error));
    }

    final remoteId = responseData?.id;
    if (remoteId == null || remoteId.isEmpty) {
      throw const TripIdentityException(
        'Server did not return a trip ID. Please try again.',
      );
    }
    return remoteId;
  }

  /// Direct server call to update a trip. Throws on any failure so the caller
  /// can fall back to local-only save with retry queue.
  Future<void> _updateTripOnServer({
    required String serverTripId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String visibility = 'private',
  }) async {
    final tripsApi = _tripsApi;
    if (tripsApi == null) {
      throw const TripIdentityException('Trips API unavailable for update.');
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const TripIdentityException(
        'Auth token unavailable for trip update.',
        retryable: true,
      );
    }

    final payload = openapi.TripUpdate((builder) {
      builder
        ..title = name
        ..description = description
        ..visibility = visibility;
      if (startDate != null) {
        builder.startDate =
            openapi.Date(startDate.year, startDate.month, startDate.day);
      }
      if (endDate != null) {
        builder.endDate =
            openapi.Date(endDate.year, endDate.month, endDate.day);
      }
    });

    await tripsApi.updateTripApiV1TripsTripIdPatch(
      tripId: serverTripId,
      authorization: 'Bearer $token',
      tripUpdate: payload,
    );
  }

  Future<void> setEditorViewport({
    required String tripId,
    required double zoom,
    required AppLatLng? centerPoint,
  }) async {
    final currentRow = await _db.tripDao.getTripById(tripId);
    if (currentRow == null) {
      return;
    }

    final currentCenter = currentRow.centerPoint;
    final centerUnchanged = currentCenter == centerPoint;
    final zoomUnchanged = currentRow.zoom == zoom;
    if (centerUnchanged && zoomUnchanged) {
      return;
    }

    // Viewport is editor-local UI state and not part of backend TripUpdate schema.
    // Persist locally without enqueueing sync tasks to avoid queue spam.
    await (_db.update(_db.trips)..where((t) => t.id.equals(tripId))).write(
      TripsCompanion(
        centerPoint: Value(centerPoint),
        zoom: Value(zoom),
      ),
    );
  }

  /// Resolves the backend trip UUID for a local trip.
  ///
  /// For locally-created trips, this creates the remote trip lazily during
  /// media/place upload flows and persists the mapping as `serverTripId`.
  Future<String> ensureRemoteTripId(
    String localTripId, {
    bool allowCreate = true,
  }) async {
    final operationKey = _identityOperationKey(
      localTripId: localTripId,
      allowCreate: allowCreate,
    );
    final inFlight = _ensureRemoteTripIdInFlight[operationKey];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _ensureRemoteTripIdInternal(
      localTripId,
      allowCreate: allowCreate,
    );
    _ensureRemoteTripIdInFlight[operationKey] = future;
    try {
      return await future;
    } finally {
      if (identical(_ensureRemoteTripIdInFlight[operationKey], future)) {
        _ensureRemoteTripIdInFlight.remove(operationKey);
      }
    }
  }

  Future<void> clearServerTripId(
    String localTripId, {
    String? expectedServerTripId,
  }) async {
    Expression<bool> predicate = _db.trips.id.equals(localTripId);
    if (expectedServerTripId != null && expectedServerTripId.isNotEmpty) {
      predicate =
          predicate & _db.trips.serverTripId.equals(expectedServerTripId);
    }
    await (_db.update(_db.trips)..where((_) => predicate)).write(
      const TripsCompanion(
        serverTripId: Value(null),
      ),
    );
  }

  Trip _mapRow(TripRow row) {
    return Trip(
      id: row.id,
      serverTripId: row.serverTripId,
      userId: row.userId,
      name: row.name,
      description: row.description,
      startDate: row.startDate,
      endDate: row.endDate,
      tags: row.tags,
      visibility: row.visibility,
      centerPoint: row.centerPoint,
      zoom: row.zoom,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
    );
  }

  Future<void> _upsertTripRow(Trip trip) async {
    final existing = await _db.tripDao.getTripById(trip.id);
    final createdAt = existing?.createdAt ?? trip.localUpdatedAt;
    final existingServerTripId = existing?.serverTripId;
    final resolvedServerTripId =
        (existingServerTripId != null && existingServerTripId.isNotEmpty)
            ? existingServerTripId
            : trip.serverTripId;

    final companion = TripsCompanion(
      id: Value(trip.id),
      serverTripId: Value(resolvedServerTripId),
      userId: Value(trip.userId),
      name: Value(trip.name),
      description: Value(trip.description),
      startDate: Value(trip.startDate),
      endDate: Value(trip.endDate),
      tags: Value(trip.tags),
      visibility: Value(trip.visibility),
      centerPoint: Value(trip.centerPoint),
      zoom: Value(trip.zoom),
      localUpdatedAt: Value(trip.localUpdatedAt),
      serverUpdatedAt: Value(trip.serverUpdatedAt),
      syncStatus: Value(trip.syncStatus),
      createdAt: Value(createdAt),
    );

    if (existing == null) {
      await _db.tripDao.insertTrip(companion);
    } else {
      await _db.tripDao.updateTrip(companion);
    }
  }

  Future<void> _upsertUserTrip(
    Trip trip, {
    DateTime? createdAt,
  }) async {
    final existing = await _db.userTripsDao.getTripById(trip.id);
    final now = DateTime.now();
    final userTrip = UserTrip(
      id: trip.id,
      userId: trip.userId,
      name: trip.name,
      description: trip.description,
      coverPhotoUrl: existing?.coverPhotoUrl,
      startDate: trip.startDate,
      endDate: trip.endDate,
      visibility: trip.visibility,
      placeCount: existing?.placeCount ?? 0,
      status: existing?.status ?? 'editing',
      lastEditedAt: now,
      localUpdatedAt: trip.localUpdatedAt,
      serverUpdatedAt: trip.serverUpdatedAt,
      syncStatus: trip.syncStatus,
      createdAt: createdAt ?? existing?.createdAt ?? now,
    );

    if (existing == null) {
      await _db.userTripsDao.insertTrip(userTrip);
    } else {
      await _db.userTripsDao.updateTrip(userTrip);
    }
  }

  Future<String> _ensureRemoteTripIdInternal(
    String localTripId, {
    required bool allowCreate,
  }) async {
    final local = await getTrip(localTripId);
    if (local == null) {
      throw TripIdentityException(
        'Cannot resolve remote trip id: local trip not found ($localTripId)',
      );
    }

    final existingServerTripId = local.serverTripId;
    if (existingServerTripId != null && existingServerTripId.isNotEmpty) {
      return existingServerTripId;
    }

    final tripsApi = _tripsApi;
    if (tripsApi == null) {
      throw const TripIdentityException(
        'Cannot resolve remote trip id: Trips API unavailable',
      );
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const TripIdentityException(
        'Cannot resolve remote trip id: auth token unavailable',
        retryable: true,
      );
    }

    // Migration bridge: pre-existing trips may already be remote-backed
    // but missing serverTripId in local schema.
    final existsWithSameId = await _tripExistsOnServer(
      candidateRemoteTripId: local.id,
      authorization: 'Bearer $token',
      tripsApi: tripsApi,
    );
    if (existsWithSameId) {
      await _persistServerTripId(localTripId: local.id, serverTripId: local.id);
      return local.id;
    }

    if (!allowCreate) {
      throw TripIdentityException(
        'Trip is not available on backend for media upload '
        '(tripId=$localTripId). Sync/create this trip on server first, then retry upload.',
      );
    }

    final payload = openapi.TripCreate((builder) {
      builder
        ..title = local.name
        ..description = local.description
        ..visibility = local.visibility;

      final start = local.startDate;
      if (start != null) {
        builder.startDate = openapi.Date(
          start.year,
          start.month,
          start.day,
        );
      }

      final end = local.endDate;
      if (end != null) {
        builder.endDate = openapi.Date(
          end.year,
          end.month,
          end.day,
        );
      }
    });

    openapi.TripResponse? responseData;
    try {
      final response = await tripsApi.createTripApiV1TripsPost(
        authorization: 'Bearer $token',
        tripCreate: payload,
      );
      responseData = response.data;
    } on DioException catch (error) {
      if (_isRetryableDio(error)) {
        rethrow;
      }
      throw TripIdentityException(_mapTripCreateFailure(error));
    }

    final remoteId = responseData?.id;
    if (remoteId == null || remoteId.isEmpty) {
      throw const TripIdentityException(
        'Cannot resolve remote trip id: backend returned empty id',
      );
    }

    await _persistServerTripId(
      localTripId: local.id,
      serverTripId: remoteId,
    );
    return remoteId;
  }

  Future<bool> _tripExistsOnServer({
    required String candidateRemoteTripId,
    required String authorization,
    required openapi.TripsApi tripsApi,
  }) async {
    try {
      await tripsApi.getTripApiV1TripsTripIdGet(
        tripId: candidateRemoteTripId,
        authorization: authorization,
      );
      return true;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 404) {
        return false;
      }
      if (_isRetryableDio(error)) {
        rethrow;
      }
      throw TripIdentityException(
        'Failed to verify backend trip identity (status ${status ?? 'unknown'}): '
        '${error.message ?? 'request failed'}',
      );
    }
  }

  Future<void> _persistServerTripId({
    required String localTripId,
    required String serverTripId,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.trips)..where((t) => t.id.equals(localTripId))).write(
      TripsCompanion(
        serverTripId: Value(serverTripId),
        localUpdatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );
  }

  Future<void> deleteRemoteTripById(String remoteTripId) async {
    final tripsApi = _tripsApi;
    if (tripsApi == null) {
      throw const TripIdentityException(
        'Cannot delete backend trip: Trips API unavailable.',
      );
    }

    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const TripIdentityException(
        'Cannot delete backend trip: auth token unavailable.',
        retryable: true,
      );
    }

    await tripsApi.deleteTripApiV1TripsTripIdDelete(
      tripId: remoteTripId,
      authorization: 'Bearer $token',
    );
  }

  String _mapTripCreateFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return 'Session expired while preparing media upload. Please sign in again and retry.';
    }
    if (statusCode == 403) {
      return 'Trip creation is not allowed for this account right now. Check account limits/permissions.';
    }
    if (statusCode != null) {
      return 'Failed to create backend trip for media upload (status $statusCode).';
    }
    return 'Failed to create backend trip for media upload: ${error.message ?? 'network error'}';
  }

  String _mapTripUpdateFailure(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return 'Session expired while updating trip. Please sign in again.';
    }
    if (statusCode == 403) {
      return 'You do not have permission to update this trip.';
    }
    if (statusCode != null) {
      return 'Failed to update trip on server (status $statusCode).';
    }
    return 'Failed to update trip on server: ${error.message ?? 'network error'}';
  }

  bool _isRetryableDio(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == null) {
      return true;
    }
    if (statusCode == 408 || statusCode == 429) {
      return true;
    }
    if (statusCode >= 500) {
      return true;
    }
    return false;
  }

  String _identityOperationKey({
    required String localTripId,
    required bool allowCreate,
  }) {
    return '$localTripId|allowCreate=$allowCreate';
  }
}

class TripIdentityException implements Exception {
  const TripIdentityException(
    this.message, {
    this.retryable = false,
  });

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}
