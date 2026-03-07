import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/data/trips_api.dart';

class TripsRepository {
  TripsRepository(this._db, this._api, this._authService);

  final AppDatabase _db;
  final TripsApi _api;
  final AuthService _authService;

  static const int _pageSize = 50;

  Future<List<UserTrip>> getCachedUserTrips() async {
    final userId = _currentUserId();
    if (userId == null) {
      return const <UserTrip>[];
    }
    return _db.userTripsDao.getTripsForUser(userId);
  }

  Future<List<UserTrip>> getUserTrips({bool forceRefresh = false}) async {
    final userId = _currentUserId();
    if (userId == null) {
      return const <UserTrip>[];
    }
    final cached = await _db.userTripsDao.getTripsForUser(userId);

    try {
      // Always try backend first so My Trips stays backend-authoritative.
      final remoteTrips = await _fetchAllRemoteTrips();
      final merged = await _mergeTrips(
        userId: userId,
        localTrips: cached,
        remoteTrips: remoteTrips,
      );
      await _persistMergedTrips(userId: userId, mergedTrips: merged);
      return merged;
    } catch (e) {
      if (cached.isNotEmpty) {
        return cached;
      }
      final operation = forceRefresh ? 'refresh' : 'load';
      throw TripsRepositoryException('Failed to $operation trips: $e');
    }
  }

  Future<UserTrip?> getActiveTrip() async {
    final trips = await getUserTrips();
    for (final trip in trips) {
      if (trip.isActive) {
        return trip;
      }
    }
    return null;
  }

  Future<UserTrip> duplicateTrip(String id) async {
    final userId = _requireCurrentUserId();
    try {
      final remoteId = await _resolveRemoteTripIdForUserTripId(
        localTripId: id,
        userId: userId,
      );
      final duplicated = await _api.duplicateTrip(remoteId);
      await _db.userTripsDao.insertTrip(duplicated);
      return duplicated;
    } catch (e) {
      final original = await _db.userTripsDao.getTripByIdForUser(id, userId);
      if (original == null) {
        throw TripsRepositoryException('Trip not found');
      }

      final now = DateTime.now();
      final duplicated = original.copyWith(
        id: const Uuid().v4(),
        name: _copyName(original.name),
        status: 'editing',
        lastEditedAt: now,
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'pending',
        createdAt: now,
      );

      await _db.userTripsDao.insertTrip(duplicated);
      await _markSyncFailed(duplicated.id);
      return duplicated;
    }
  }

  Future<void> deleteTrip(String id) async {
    final userId = _requireCurrentUserId();
    final existing = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (existing == null) {
      return;
    }

    await _db.userTripsDao.deleteTrip(id);

    // Local-only pending trips have no guaranteed backend representation yet.
    if (existing.syncStatus != 'synced') {
      return;
    }

    try {
      final remoteTripId = await _resolveRemoteTripIdForUserTrip(
        trip: existing,
        userId: userId,
      );
      await _api.deleteTrip(remoteTripId);
    } catch (e) {
      final restored = existing.copyWith(
        syncStatus: 'failed',
        localUpdatedAt: DateTime.now(),
      );
      await _db.userTripsDao.insertTrip(restored);
      throw TripsRepositoryException('Failed to delete trip: $e');
    }
  }

  Future<UserTrip> updateVisibility(String id, String visibility) async {
    final userId = _requireCurrentUserId();
    final trip = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (trip == null) {
      throw TripsRepositoryException('Trip not found');
    }

    final now = DateTime.now();
    final updated = trip.copyWith(
      visibility: visibility,
      status: visibility == 'public' ? 'shared' : trip.status,
      lastEditedAt: now,
      localUpdatedAt: now,
      syncStatus: 'pending',
    );

    await _db.userTripsDao.updateTrip(updated);

    try {
      final remoteTripId = await _resolveRemoteTripIdForUserTrip(
        trip: updated,
        userId: userId,
      );
      final remote = await _api.updateTripVisibility(remoteTripId, visibility);
      await _db.userTripsDao.updateTrip(remote.copyWith(
        id: updated.id,
        userId: updated.userId,
        localUpdatedAt: now,
        syncStatus: 'synced',
      ));
      return remote;
    } catch (e) {
      await _markSyncFailed(updated.id);
      throw TripsRepositoryException('Failed to update visibility: $e');
    }
  }

  Future<bool> hasPendingChanges() async {
    final userId = _currentUserId();
    if (userId == null) {
      return false;
    }
    final trips = await _db.userTripsDao.getTripsForUser(userId);
    return trips.any((trip) => trip.syncStatus != 'synced');
  }

  Future<void> clearCache() async {
    final userId = _currentUserId();
    if (userId == null) {
      return;
    }
    final tripIds = (await _db.tripDao.getAllTrips())
        .where((trip) => trip.userId == userId)
        .map((trip) => trip.id)
        .toList();

    await _db.transaction(() async {
      await _db.userTripsDao.clearAllForUser(userId);
      await _db.delete(_db.publicTrips).go();
      if (tripIds.isNotEmpty) {
        await (_db.delete(_db.places)..where((t) => t.tripId.isIn(tripIds)))
            .go();
        await (_db.delete(_db.routes)..where((t) => t.tripId.isIn(tripIds)))
            .go();
        await (_db.delete(_db.media)..where((t) => t.tripId.isIn(tripIds)))
            .go();
      }
      await (_db.delete(_db.trips)..where((t) => t.userId.equals(userId))).go();
    });
  }

  String? _currentUserId() {
    final userId = _authService.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      return null;
    }
    return userId;
  }

  String _requireCurrentUserId() {
    final userId = _currentUserId();
    if (userId == null) {
      throw TripsRepositoryException('No authenticated user');
    }
    return userId;
  }

  Future<List<UserTrip>> _fetchAllRemoteTrips() async {
    final allTrips = <UserTrip>[];
    const maxPages = 20;
    var page = 1;

    while (page <= maxPages) {
      final pageTrips = await _api.getUserTrips(
        page: page,
        limit: _pageSize,
      );
      if (pageTrips.isEmpty) {
        break;
      }
      allTrips.addAll(pageTrips);
      if (pageTrips.length < _pageSize) {
        break;
      }
      page += 1;
    }

    return allTrips;
  }

  Future<List<UserTrip>> _mergeTrips({
    required String userId,
    required List<UserTrip> localTrips,
    required List<UserTrip> remoteTrips,
  }) async {
    final localServerIds = await _serverTripIdsByLocalId(userId);
    final mergedByIdentity = <String, UserTrip>{};

    for (final remote in remoteTrips.where((trip) => trip.userId == userId)) {
      mergedByIdentity[remote.id] = remote;
    }

    for (final local in localTrips.where((trip) => trip.userId == userId)) {
      final identity = localServerIds[local.id] ?? local.id;
      final remote = mergedByIdentity[identity];
      final hasLocalUnsyncedChanges = local.syncStatus != 'synced';

      if (hasLocalUnsyncedChanges) {
        mergedByIdentity[identity] = _mergeLocalPriorityTrip(
          local: local,
          remote: remote,
        );
        continue;
      }

      if (remote == null) {
        // Remote list is authoritative for synced entities.
        continue;
      }

      mergedByIdentity[identity] = _mergeRemotePriorityTrip(
        local: local,
        remote: remote,
      );
    }

    final merged = mergedByIdentity.values.toList()
      ..sort((a, b) => b.localUpdatedAt.compareTo(a.localUpdatedAt));
    return merged;
  }

  UserTrip _mergeLocalPriorityTrip({
    required UserTrip local,
    required UserTrip? remote,
  }) {
    return local.copyWith(
      coverPhotoUrl: local.coverPhotoUrl ?? remote?.coverPhotoUrl,
      placeCount: local.placeCount > 0
          ? local.placeCount
          : (remote?.placeCount ?? local.placeCount),
      serverUpdatedAt: remote?.serverUpdatedAt ?? local.serverUpdatedAt,
    );
  }

  UserTrip _mergeRemotePriorityTrip({
    required UserTrip local,
    required UserTrip remote,
  }) {
    final latestLocalUpdatedAt =
        local.localUpdatedAt.isAfter(remote.localUpdatedAt)
            ? local.localUpdatedAt
            : remote.localUpdatedAt;
    return remote.copyWith(
      id: local.id,
      userId: local.userId,
      placeCount: remote.placeCount > 0 ? remote.placeCount : local.placeCount,
      localUpdatedAt: latestLocalUpdatedAt,
      syncStatus: 'synced',
    );
  }

  Future<Map<String, String>> _serverTripIdsByLocalId(String userId) async {
    final rows = await _db.tripDao.getAllTrips();
    final mapped = <String, String>{};
    for (final row in rows) {
      final serverTripId = row.serverTripId;
      if (row.userId != userId ||
          serverTripId == null ||
          serverTripId.isEmpty) {
        continue;
      }
      mapped[row.id] = serverTripId;
    }
    return mapped;
  }

  Future<void> _persistMergedTrips({
    required String userId,
    required List<UserTrip> mergedTrips,
  }) async {
    final scopedTrips = mergedTrips
        .map((trip) =>
            trip.userId == userId ? trip : trip.copyWith(userId: userId))
        .toList();
    await _db.userTripsDao.insertTrips(scopedTrips);
    final mergedIds = scopedTrips.map((trip) => trip.id).toList();
    await _db.userTripsDao.deleteSyncedTripsNotInIdsForUser(
      userId: userId,
      ids: mergedIds,
    );
  }

  Future<String> _resolveRemoteTripIdForUserTripId({
    required String localTripId,
    required String userId,
  }) async {
    final trip = await _db.userTripsDao.getTripByIdForUser(localTripId, userId);
    if (trip == null) {
      throw TripsRepositoryException('Trip not found');
    }
    return _resolveRemoteTripIdForUserTrip(trip: trip, userId: userId);
  }

  Future<String> _resolveRemoteTripIdForUserTrip({
    required UserTrip trip,
    required String userId,
  }) async {
    if (trip.userId != userId) {
      throw TripsRepositoryException('Trip does not belong to current user');
    }

    final tripRow = await _db.tripDao.getTripById(trip.id);
    final serverTripId = tripRow?.serverTripId;
    if (serverTripId != null && serverTripId.isNotEmpty) {
      return serverTripId;
    }

    if (trip.syncStatus == 'synced') {
      return trip.id;
    }

    throw TripsRepositoryException(
      'Trip is not synced to backend yet. Please retry after sync completes.',
    );
  }

  Future<void> _markSyncFailed(String id) async {
    final userId = _requireCurrentUserId();
    final trip = await _db.userTripsDao.getTripByIdForUser(id, userId);
    if (trip == null) {
      return;
    }
    await _db.userTripsDao.updateTrip(trip.copyWith(syncStatus: 'failed'));
  }

  static String _copyName(String name) {
    const suffix = ' (Copy)';
    const maxLength = 28;
    final trimmed = name.length > maxLength
        ? name.substring(0, maxLength).trimRight()
        : name;
    return '$trimmed$suffix';
  }
}

class TripsRepositoryException implements Exception {
  TripsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
