import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/domain/place.dart';
import 'package:dora/features/create/data/trip_repository.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';
import 'package:dora_api/dora_api.dart' as openapi;

class PlaceRepository {
  PlaceRepository(
    this._db, {
    required TripRepository tripRepository,
    openapi.SearchApi? searchApi,
    openapi.PlacesApi? placesApi,
    AuthService? authService,
  })  : _searchApi = searchApi,
        _placesApi = placesApi,
        _authService = authService,
        _tripRepository = tripRepository,
        _syncTaskDao = SyncTaskDao(_db);

  final AppDatabase _db;
  final TripRepository _tripRepository;
  final openapi.SearchApi? _searchApi;
  final openapi.PlacesApi? _placesApi;
  final AuthService? _authService;
  final SyncTaskDao _syncTaskDao;
  final Map<String, Future<String>> _ensureRemotePlaceIdInFlight = {};

  Future<List<Place>> getPlaces(String tripId) async {
    final rows = await _db.placeDao.getPlacesForTrip(tripId);
    return rows.map(_mapRow).toList();
  }

  Future<Place?> getPlace(String id) async {
    final row = await _db.placeDao.getPlaceById(id);
    return row == null ? null : _mapRow(row);
  }

  Future<Place> addPlace(Place place) async {
    final now = DateTime.now();
    final updated = place.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.insertPlace(_toCompanion(updated));
    await _updatePlaceCount(updated.tripId);
    await _enqueuePlaceSyncTask(
      placeId: updated.id,
      tripId: updated.tripId,
      operation: 'create',
    );
    return updated;
  }

  Future<void> updatePlace(Place place) async {
    final existing = await getPlace(place.id);
    final merged = _preserveSystemManagedFields(
      incoming: place,
      existing: existing,
    );
    final now = DateTime.now();
    final updated = merged.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.updatePlace(_toCompanion(updated));
    await _updatePlaceCount(updated.tripId);
    await _enqueuePlaceSyncTask(
      placeId: updated.id,
      tripId: updated.tripId,
      operation:
          (updated.serverPlaceId == null || updated.serverPlaceId!.isEmpty)
              ? 'create'
              : 'update',
    );
  }

  Future<void> deletePlace(String id) async {
    final existing = await _db.placeDao.getPlaceById(id);
    if (existing == null) {
      return;
    }
    await _db.placeDao.deletePlace(id);
    await _updatePlaceCount(existing.tripId);
    await _enqueuePlaceSyncTask(
      placeId: id,
      tripId: existing.tripId,
      operation: 'delete',
      remoteEntityId: existing.serverPlaceId,
    );
  }

  Future<void> savePlaces(List<Place> places) async {
    if (places.isEmpty) {
      return;
    }

    final existingRows = await _db.placeDao.getPlacesForTrip(places.first.tripId);
    final existingById = <String, Place>{
      for (final row in existingRows) row.id: _mapRow(row),
    };

    final now = DateTime.now();
    final companions = places
        .map((place) {
          final merged = _preserveSystemManagedFields(
            incoming: place,
            existing: existingById[place.id],
          );
          return _toCompanion(
            merged.copyWith(
              localUpdatedAt: now,
              syncStatus: 'pending',
            ),
          );
        })
        .toList();
    await _db.placeDao.insertPlaces(companions);
    await _updatePlaceCount(places.first.tripId);
    for (final place in places) {
      await _enqueuePlaceSyncTask(
        placeId: place.id,
        tripId: place.tripId,
        operation:
            (place.serverPlaceId == null || place.serverPlaceId!.isEmpty)
                ? 'create'
                : 'update',
      );
    }
  }

  Place createFromSearchResult({
    required String tripId,
    required PlaceSearchResult result,
    required int orderIndex,
  }) {
    final now = DateTime.now();
    return Place(
      id: const Uuid().v4(),
      tripId: tripId,
      name: result.name,
      address: result.address,
      coordinates: AppLatLng(
        latitude: result.latitude ?? 0,
        longitude: result.longitude ?? 0,
      ),
      orderIndex: orderIndex,
      serverPlaceId: null,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  /// Ensures a local place row has a remote backend place UUID.
  ///
  /// Media upload API requires `trip_place_id` from backend.
  /// Local editor places can exist before they are synced remotely.
  Future<String> ensureRemotePlaceId(String localPlaceId) async {
    final inFlight = _ensureRemotePlaceIdInFlight[localPlaceId];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _ensureRemotePlaceIdInternal(localPlaceId);
    _ensureRemotePlaceIdInFlight[localPlaceId] = future;

    try {
      return await future;
    } finally {
      _ensureRemotePlaceIdInFlight.remove(localPlaceId);
    }
  }

  Future<void> addPhotoUrlBridge({
    required String localPlaceId,
    required String photoUrl,
  }) async {
    final place = await getPlace(localPlaceId);
    if (place == null || photoUrl.isEmpty) {
      return;
    }
    if (place.photoUrls.contains(photoUrl)) {
      return;
    }

    final now = DateTime.now();
    final updated = place.copyWith(
      photoUrls: [...place.photoUrls, photoUrl],
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.updatePlace(_toCompanion(updated));
  }

  Future<void> removePhotoUrlBridge({
    required String localPlaceId,
    required String photoUrl,
  }) async {
    final place = await getPlace(localPlaceId);
    if (place == null || photoUrl.isEmpty) {
      return;
    }
    if (!place.photoUrls.contains(photoUrl)) {
      return;
    }

    final now = DateTime.now();
    final updated = place.copyWith(
      photoUrls: place.photoUrls.where((url) => url != photoUrl).toList(),
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.updatePlace(_toCompanion(updated));
  }

  Future<List<PlaceSearchResult>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 10,
  }) async {
    final api = _searchApi;
    final authService = _authService;
    if (api == null || authService == null) {
      return [];
    }
    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return [];
    }
    final response = await api.searchPlacesApiV1SearchPlacesGet(
      query: query,
      lat: latitude,
      lng: longitude,
      authorization: 'Bearer $token',
      radiusKm: radiusKm,
      limit: limit,
    );
    final results = response.data?.results ?? BuiltList();
    return results.map(_mapSearchResult).toList();
  }

  PlaceSearchResult _mapSearchResult(openapi.SearchResult result) {
    return PlaceSearchResult(
      id: result.id ?? '',
      name: result.name,
      category: result.source_,
      address: result.address,
      latitude: result.lat.toDouble(),
      longitude: result.lng.toDouble(),
      rating: result.rating?.toDouble(),
      reviewCount: result.popularity,
      priceLevel: null,
      photoUrl: null,
    );
  }

  Place _mapRow(PlaceRow row) {
    return Place(
      id: row.id,
      serverPlaceId: row.serverPlaceId,
      tripId: row.tripId,
      name: row.name,
      address: row.address,
      coordinates: row.coordinates,
      notes: row.notes,
      visitTime: row.visitTime,
      dayNumber: row.dayNumber,
      orderIndex: row.orderIndex,
      photoUrls: row.photoUrls,
      placeType: row.placeType,
      rating: row.rating,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
    );
  }

  PlacesCompanion _toCompanion(Place place) {
    return PlacesCompanion(
      id: Value(place.id),
      serverPlaceId: Value(place.serverPlaceId),
      tripId: Value(place.tripId),
      name: Value(place.name),
      address: Value(place.address),
      coordinates: Value(place.coordinates),
      notes: Value(place.notes),
      visitTime: Value(place.visitTime),
      dayNumber: Value(place.dayNumber),
      orderIndex: Value(place.orderIndex),
      photoUrls: Value(place.photoUrls),
      placeType: Value(place.placeType),
      rating: Value(place.rating),
      localUpdatedAt: Value(place.localUpdatedAt),
      serverUpdatedAt: Value(place.serverUpdatedAt),
      syncStatus: Value(place.syncStatus),
    );
  }

  Future<String> _ensureRemotePlaceIdInternal(String localPlaceId) async {
    final local = await getPlace(localPlaceId);
    if (local == null) {
      throw PlaceIdentityException(
        'Cannot resolve remote place id: local place not found ($localPlaceId)',
      );
    }

    final existingRemoteId = local.serverPlaceId;
    if (existingRemoteId != null && existingRemoteId.isNotEmpty) {
      return existingRemoteId;
    }

    final placesApi = _placesApi;
    final authService = _authService;
    if (placesApi == null || authService == null) {
      throw PlaceIdentityException(
        'Cannot resolve remote place id: Places API/auth service unavailable',
      );
    }

    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw PlaceIdentityException(
        'Cannot resolve remote place id: auth token unavailable',
        retryable: true,
      );
    }

    String remoteTripId;
    try {
      remoteTripId = await _tripRepository.ensureRemoteTripId(local.tripId);
    } on TripIdentityException catch (error) {
      throw PlaceIdentityException(
        error.message,
        retryable: error.retryable,
      );
    }

    openapi.PlaceResponse? responseData;
    try {
      responseData = await _createRemotePlace(
        placesApi: placesApi,
        token: token,
        local: local,
        remoteTripId: remoteTripId,
      );
    } on DioException catch (error) {
      if (_isTripNotFoundError(error)) {
        await _tripRepository.clearServerTripId(
          local.tripId,
          expectedServerTripId: remoteTripId,
        );
        try {
          final refreshedRemoteTripId =
              await _tripRepository.ensureRemoteTripId(
                local.tripId,
                allowCreate: false,
              );
          responseData = await _createRemotePlace(
            placesApi: placesApi,
            token: token,
            local: local,
            remoteTripId: refreshedRemoteTripId,
          );
        } on DioException catch (retryError) {
          if (_isRetryableDio(retryError)) {
            rethrow;
          }
          throw PlaceIdentityException(
            _mapPlaceCreateFailure(
              retryError,
              localTripId: local.tripId,
            ),
          );
        } on TripIdentityException catch (retryTripError) {
          throw PlaceIdentityException(
            retryTripError.message,
            retryable: retryTripError.retryable,
          );
        }
      } else {
        if (_isRetryableDio(error)) {
          rethrow;
        }
        throw PlaceIdentityException(
          _mapPlaceCreateFailure(
            error,
            localTripId: local.tripId,
          ),
        );
      }
    } on TripIdentityException catch (error) {
      throw PlaceIdentityException(error.message, retryable: error.retryable);
    }

    final remoteId = responseData?.id;
    if (remoteId == null || remoteId.isEmpty) {
      throw PlaceIdentityException(
        'Cannot resolve remote place id: backend returned empty id',
      );
    }

    final now = DateTime.now();
    final updated = local.copyWith(
      serverPlaceId: remoteId,
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.placeDao.updatePlace(_toCompanion(updated));

    return remoteId;
  }

  Future<void> _updatePlaceCount(String tripId) async {
    final places = await _db.placeDao.getPlacesForTrip(tripId);
    final userTrip = await _db.userTripsDao.getTripById(tripId);
    if (userTrip == null) {
      return;
    }
    final now = DateTime.now();
    await _db.userTripsDao.updateTrip(userTrip.copyWith(
      placeCount: places.length,
      lastEditedAt: now,
      localUpdatedAt: now,
      syncStatus: 'pending',
    ));
  }

  Place _preserveSystemManagedFields({
    required Place incoming,
    Place? existing,
  }) {
    if (existing == null) {
      return incoming;
    }

    // Media and remote place identity are managed by dedicated sync/upload flows.
    final existingRemoteId = existing.serverPlaceId;
    final incomingRemoteId = incoming.serverPlaceId;
    final resolvedRemoteId =
        (existingRemoteId != null && existingRemoteId.isNotEmpty)
            ? existingRemoteId
            : incomingRemoteId;

    return incoming.copyWith(
      serverPlaceId: resolvedRemoteId,
      photoUrls: existing.photoUrls,
    );
  }

  Future<void> _enqueuePlaceSyncTask({
    required String placeId,
    required String tripId,
    required String operation,
    String? remoteEntityId,
  }) async {
    await _syncTaskDao.upsertQueuedTask(
      id: const Uuid().v4(),
      entityType: 'place',
      entityId: placeId,
      operation: operation,
      remoteEntityId: remoteEntityId,
      dependsOnEntityType: 'trip',
      dependsOnEntityId: tripId,
    );
  }

  String _mapPlaceCreateFailure(
    DioException error, {
    required String localTripId,
  }) {
    final statusCode = error.response?.statusCode;
    final detail = _extractErrorDetail(error.response?.data);
    final normalizedDetail = detail.toLowerCase();

    if (statusCode == 404 && normalizedDetail.contains('trip not found')) {
      return 'Trip is not available on backend for place/media upload '
          '(local tripId=$localTripId). Sync/create this trip on server first, '
          'then retry upload.';
    }

    if (statusCode == 403) {
      return 'You do not have permission to create backend places for this '
          'trip. Check account ownership and retry.';
    }

    if (statusCode == 401) {
      return 'Session expired while preparing media upload. Please sign in '
          'again and retry.';
    }

    if (statusCode != null) {
      return 'Failed to create backend place for media upload '
          '(status $statusCode): $detail';
    }
    return 'Failed to create backend place for media upload: ${error.message ?? detail}';
  }

  String _extractErrorDetail(Object? payload) {
    if (payload is Map) {
      final detail = payload['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    }
    if (payload is String && payload.isNotEmpty) {
      return payload;
    }
    return 'Unknown backend error';
  }

  bool _isTripNotFoundError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != 404) {
      return false;
    }
    final detail = _extractErrorDetail(error.response?.data).toLowerCase();
    return detail.contains('trip not found');
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

  Future<openapi.PlaceResponse?> _createRemotePlace({
    required openapi.PlacesApi placesApi,
    required String token,
    required Place local,
    required String remoteTripId,
  }) async {
    final payload = openapi.PlaceCreate((builder) {
      builder
        ..tripId = remoteTripId
        ..name = local.name
        ..lat = local.coordinates.latitude
        ..lng = local.coordinates.longitude
        ..orderInTrip = local.orderIndex;

      final placeType = local.placeType;
      if (placeType != null && placeType.isNotEmpty) {
        builder.placeType = placeType;
      }

      final notes = local.notes;
      if (notes != null && notes.isNotEmpty) {
        builder.userNotes = notes;
      }

      final rating = local.rating;
      if (rating != null) {
        builder.userRating = rating;
      }
    });

    final response = await placesApi.createPlaceApiV1PlacesPost(
      authorization: 'Bearer $token',
      placeCreate: payload,
    );
    return response.data;
  }

  Future<void> deleteRemotePlaceById(String remotePlaceId) async {
    final placesApi = _placesApi;
    final authService = _authService;
    if (placesApi == null || authService == null) {
      throw PlaceIdentityException(
        'Cannot delete backend place: Places API/auth service unavailable.',
      );
    }

    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw PlaceIdentityException(
        'Cannot delete backend place: auth token unavailable.',
        retryable: true,
      );
    }

    await placesApi.deletePlaceApiV1PlacesPlaceIdDelete(
      placeId: remotePlaceId,
      authorization: 'Bearer $token',
    );
  }

  Future<void> syncPlaceForTask(
    String localPlaceId, {
    required String operation,
  }) async {
    switch (operation) {
      case 'create':
        await ensureRemotePlaceId(localPlaceId);
        return;
      case 'update':
        await _syncRemotePlaceUpdate(localPlaceId);
        return;
      case 'delete':
        throw PlaceIdentityException(
          'Place delete requires remote place id context.',
        );
      default:
        throw PlaceIdentityException(
          'Unsupported place sync operation: $operation',
        );
    }
  }

  Future<void> _syncRemotePlaceUpdate(String localPlaceId) async {
    final local = await getPlace(localPlaceId);
    if (local == null) {
      throw PlaceIdentityException(
        'Cannot sync place update: local place not found ($localPlaceId)',
      );
    }

    final remotePlaceId = await ensureRemotePlaceId(localPlaceId);
    final placesApi = _placesApi;
    final authService = _authService;
    if (placesApi == null || authService == null) {
      throw PlaceIdentityException(
        'Cannot sync place update: Places API/auth service unavailable.',
      );
    }

    final token = await authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw PlaceIdentityException(
        'Cannot sync place update: auth token unavailable.',
        retryable: true,
      );
    }

    final payload = openapi.PlaceUpdate((builder) {
      builder
        ..name = local.name
        ..lat = local.coordinates.latitude
        ..lng = local.coordinates.longitude
        ..orderInTrip = local.orderIndex;

      final placeType = local.placeType;
      if (placeType != null && placeType.isNotEmpty) {
        builder.placeType = placeType;
      }
      final notes = local.notes;
      if (notes != null && notes.isNotEmpty) {
        builder.userNotes = notes;
      }
      final rating = local.rating;
      if (rating != null) {
        builder.userRating = rating;
      }
    });

    await placesApi.updatePlaceApiV1PlacesPlaceIdPatch(
      placeId: remotePlaceId,
      authorization: 'Bearer $token',
      placeUpdate: payload,
    );
  }

}

class PlaceIdentityException implements Exception {
  PlaceIdentityException(
    this.message, {
    this.retryable = false,
  });

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}
