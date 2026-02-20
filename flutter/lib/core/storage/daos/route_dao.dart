import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/routes_table.dart';

part 'route_dao.g.dart';

@DriftAccessor(tables: [Routes])
class RouteDao extends DatabaseAccessor<AppDatabase> with _$RouteDaoMixin {
  RouteDao(AppDatabase db) : super(db);

  Future<List<RouteRow>> getRoutesForTrip(String tripId) =>
      (select(routes)
            ..where((r) => r.tripId.equals(tripId))
            ..orderBy([
              (r) => OrderingTerm.asc(r.orderIndex),
              (r) => OrderingTerm.asc(r.localUpdatedAt),
            ]))
          .get();

  Future<RouteRow?> getRouteById(String id) =>
      (select(routes)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<int> insertRoute(RoutesCompanion route) => into(routes).insert(route);

  Future<void> insertRoutes(List<RoutesCompanion> entries) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(routes, entries);
    });
  }

  Future<bool> updateRoute(RoutesCompanion route) =>
      update(routes).replace(route);

  Future<int> deleteRoute(String id) =>
      (delete(routes)..where((r) => r.id.equals(id))).go();

  Future<void> deleteRoutesForTrip(String tripId) =>
      (delete(routes)..where((r) => r.tripId.equals(tripId))).go();
}
