import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/public_trips_table.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';

part 'public_trips_dao.g.dart';

@DriftAccessor(tables: [PublicTrips])
class PublicTripsDao extends DatabaseAccessor<AppDatabase>
    with _$PublicTripsDaoMixin {
  PublicTripsDao(AppDatabase db) : super(db);

  Future<List<PublicTrip>> getTrips({
    int page = 1,
    int limit = 10,
    TripFilter? filter,
  }) async {
    final offset = (page - 1) * limit;
    final query = select(publicTrips)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(limit, offset: offset);

    final rows = await query.get();
    return rows.map(_mapRow).toList();
  }

  Future<PublicTrip?> getTripById(String id) async {
    final row = await (select(publicTrips)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  Future<void> insertTrips(List<PublicTrip> trips) async {
    final companions = trips.map(_toCompanion).toList();
    await batch((batch) {
      batch.insertAllOnConflictUpdate(publicTrips, companions);
    });
  }

  Future<void> insertTrip(PublicTrip trip) async {
    await into(publicTrips).insertOnConflictUpdate(_toCompanion(trip));
  }

  Future<int> clearAll() => delete(publicTrips).go();

  PublicTrip _mapRow(PublicTripRow row) {
    return PublicTrip(
      id: row.id,
      name: row.name,
      description: row.description,
      coverPhotoUrl: row.coverPhotoUrl,
      userId: row.userId,
      username: row.username,
      placeCount: row.placeCount,
      duration: row.duration,
      tags: row.tags,
      visibility: row.visibility,
      viewCount: row.viewCount,
      createdAt: row.createdAt,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
    );
  }

  PublicTripsCompanion _toCompanion(PublicTrip trip) {
    return PublicTripsCompanion(
      id: Value(trip.id),
      name: Value(trip.name),
      description: Value(trip.description),
      coverPhotoUrl: Value(trip.coverPhotoUrl),
      userId: Value(trip.userId),
      username: Value(trip.username),
      placeCount: Value(trip.placeCount),
      duration: Value(trip.duration),
      tags: Value(trip.tags),
      visibility: Value(trip.visibility),
      viewCount: Value(trip.viewCount),
      localUpdatedAt: Value(trip.localUpdatedAt),
      serverUpdatedAt: Value(trip.serverUpdatedAt),
      syncStatus: Value(trip.syncStatus),
      createdAt: Value(trip.createdAt),
    );
  }
}
