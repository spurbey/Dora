import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/domain/trip.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

class TripRepository {
  TripRepository(this._db, this._authService);

  final AppDatabase _db;
  final AuthService _authService;

  Future<Trip?> getTrip(String id) async {
    final row = await _db.tripDao.getTripById(id);
    if (row == null) {
      return null;
    }
    return _mapRow(row);
  }

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
    final trip = Trip(
      id: const Uuid().v4(),
      userId: userId,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      tags: tags,
      visibility: visibility,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );

    await _upsertTripRow(trip);
    await _upsertUserTrip(trip, createdAt: now);

    return trip;
  }

  Future<Trip> updateTrip(Trip trip) async {
    final now = DateTime.now();
    final updated = trip.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );

    await _upsertTripRow(updated);
    await _upsertUserTrip(updated);

    return updated;
  }

  Future<void> deleteTrip(String id) async {
    await _db.tripDao.deleteTrip(id);
    await _db.userTripsDao.deleteTrip(id);
  }

  Future<void> setEditorViewport({
    required String tripId,
    required double zoom,
    required AppLatLng? centerPoint,
  }) async {
    final current = await getTrip(tripId);
    if (current == null) {
      return;
    }

    await updateTrip(current.copyWith(centerPoint: centerPoint, zoom: zoom));
  }

  Trip _mapRow(TripRow row) {
    return Trip(
      id: row.id,
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
    final companion = TripsCompanion(
      id: Value(trip.id),
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
}
