import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/routes_table.dart';

part 'route_dao.g.dart';

@DriftAccessor(tables: [Routes])
class RouteDao extends DatabaseAccessor<AppDatabase> with _$RouteDaoMixin {
  RouteDao(AppDatabase db) : super(db);

  Future<List<TripRoute>> getRoutesForTrip(String tripId) =>
      (select(routes)..where((r) => r.tripId.equals(tripId))).get();

  Future<int> insertRoute(RoutesCompanion route) => into(routes).insert(route);

  Future<bool> updateRoute(RoutesCompanion route) =>
      update(routes).replace(route);

  Future<int> deleteRoute(String id) =>
      (delete(routes)..where((r) => r.id.equals(id))).go();
}
