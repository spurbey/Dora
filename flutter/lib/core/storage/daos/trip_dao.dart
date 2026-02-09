import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/trips_table.dart';

part 'trip_dao.g.dart';

@DriftAccessor(tables: [Trips])
class TripDao extends DatabaseAccessor<AppDatabase> with _$TripDaoMixin {
  TripDao(AppDatabase db) : super(db);

  Future<List<TripRow>> getAllTrips() => select(trips).get();

  Future<TripRow?> getTripById(String id) =>
      (select(trips)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTrip(TripsCompanion trip) => into(trips).insert(trip);

  Future<bool> updateTrip(TripsCompanion trip) => update(trips).replace(trip);

  Future<int> deleteTrip(String id) =>
      (delete(trips)..where((t) => t.id.equals(id))).go();
}
