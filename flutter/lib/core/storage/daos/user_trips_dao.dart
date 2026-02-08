import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/user_trips_table.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

part 'user_trips_dao.g.dart';

@DriftAccessor(tables: [UserTrips])
class UserTripsDao extends DatabaseAccessor<AppDatabase>
    with _$UserTripsDaoMixin {
  UserTripsDao(AppDatabase db) : super(db);

  Future<List<UserTrip>> getTrips() async {
    final rows = await (select(userTrips)
          ..orderBy([(t) => OrderingTerm.desc(t.localUpdatedAt)]))
        .get();
    return rows.map(_mapRow).toList();
  }

  Future<UserTrip?> getTripById(String id) async {
    final row = await (select(userTrips)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  Future<void> insertTrips(List<UserTrip> trips) async {
    final companions = trips.map(_toCompanion).toList();
    await batch((batch) {
      batch.insertAllOnConflictUpdate(userTrips, companions);
    });
  }

  Future<void> insertTrip(UserTrip trip) async {
    await into(userTrips).insertOnConflictUpdate(_toCompanion(trip));
  }

  Future<void> updateTrip(UserTrip trip) async {
    await update(userTrips).replace(_toCompanion(trip));
  }

  Future<int> deleteTrip(String id) =>
      (delete(userTrips)..where((t) => t.id.equals(id))).go();

  Future<int> clearAll() => delete(userTrips).go();

  UserTrip _mapRow(UserTripRow row) {
    return UserTrip(
      id: row.id,
      userId: row.userId,
      name: row.name,
      description: row.description,
      coverPhotoUrl: row.coverPhotoUrl,
      startDate: row.startDate,
      endDate: row.endDate,
      visibility: row.visibility,
      placeCount: row.placeCount,
      status: row.status,
      lastEditedAt: row.lastEditedAt,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
      createdAt: row.createdAt,
    );
  }

  UserTripsCompanion _toCompanion(UserTrip trip) {
    return UserTripsCompanion(
      id: Value(trip.id),
      userId: Value(trip.userId),
      name: Value(trip.name),
      description: Value(trip.description),
      coverPhotoUrl: Value(trip.coverPhotoUrl),
      startDate: Value(trip.startDate),
      endDate: Value(trip.endDate),
      visibility: Value(trip.visibility),
      placeCount: Value(trip.placeCount),
      status: Value(trip.status),
      lastEditedAt: Value(trip.lastEditedAt),
      localUpdatedAt: Value(trip.localUpdatedAt),
      serverUpdatedAt: Value(trip.serverUpdatedAt),
      syncStatus: Value(trip.syncStatus),
      createdAt: Value(trip.createdAt),
    );
  }
}
