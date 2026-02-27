import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';
import 'package:dora/features/trips/data/trips_api.dart';

class TripsRepository {
  TripsRepository(this._db, this._api);

  final AppDatabase _db;
  final TripsApi _api;

  Future<List<UserTrip>> getUserTrips({bool forceRefresh = false}) async {
    if (forceRefresh) {
      final cached = await _db.userTripsDao.getTrips();
      final hasPending =
          cached.any((trip) => trip.syncStatus != 'synced');
      if (hasPending) {
        return cached;
      }
    }

    if (!forceRefresh) {
      final cached = await _db.userTripsDao.getTrips();
      if (cached.isNotEmpty) {
        final hasPending =
            cached.any((trip) => trip.syncStatus != 'synced');
        if (!hasPending) {
          _refreshInBackground();
        }
        return cached;
      }
    }

    try {
      final trips = await _api.getUserTrips();
      await _db.userTripsDao.clearAll();
      await _db.userTripsDao.insertTrips(trips);
      return trips;
    } catch (e) {
      final cached = await _db.userTripsDao.getTrips();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw TripsRepositoryException('Failed to load trips: $e');
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
    try {
      final duplicated = await _api.duplicateTrip(id);
      await _db.userTripsDao.insertTrip(duplicated);
      return duplicated;
    } catch (e) {
      final original = await _db.userTripsDao.getTripById(id);
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
    final existing = await _db.userTripsDao.getTripById(id);
    if (existing == null) {
      return;
    }

    await _db.userTripsDao.deleteTrip(id);

    // Local-only pending trips have no guaranteed backend representation yet.
    if (existing.syncStatus != 'synced') {
      return;
    }

    try {
      await _api.deleteTrip(id);
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
    final trip = await _db.userTripsDao.getTripById(id);
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
      final remote = await _api.updateTripVisibility(id, visibility);
      await _db.userTripsDao.updateTrip(remote.copyWith(
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
    final trips = await _db.userTripsDao.getTrips();
    return trips.any((trip) => trip.syncStatus != 'synced');
  }

  Future<void> clearCache() async {
    await _db.transaction(() async {
      await _db.delete(_db.userTrips).go();
      await _db.delete(_db.publicTrips).go();
      await _db.delete(_db.trips).go();
      await _db.delete(_db.places).go();
      await _db.delete(_db.routes).go();
      await _db.delete(_db.media).go();
    });
  }

  void _refreshInBackground() {
    Future(() async {
      final trips = await _api.getUserTrips();
      final existing = await _db.userTripsDao.getTrips();
      final pending =
          existing.where((trip) => trip.syncStatus != 'synced').toList();
      if (pending.isNotEmpty) {
        return;
      }
      await _db.userTripsDao.clearAll();
      await _db.userTripsDao.insertTrips(trips);
    }).catchError((_) {});
  }

  Future<void> _markSyncFailed(String id) async {
    final trip = await _db.userTripsDao.getTripById(id);
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
