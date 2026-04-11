import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/route_projection_local_table.dart';

part 'route_projection_local_dao.g.dart';

@DriftAccessor(tables: [RouteProjectionLocal])
class RouteProjectionLocalDao extends DatabaseAccessor<AppDatabase>
    with _$RouteProjectionLocalDaoMixin {
  RouteProjectionLocalDao(super.db);

  Stream<List<RouteProjectionLocalRow>> watchSegmentsForTrip(
    String tripLocalId,
  ) =>
      (select(routeProjectionLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.startedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<List<RouteProjectionLocalRow>> listSegmentsForTrip(
    String tripLocalId,
  ) =>
      (select(routeProjectionLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.startedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Future<void> replaceSegmentsForSessions({
    required String tripLocalId,
    required Set<String> sessionIds,
    required List<RouteProjectionLocalCompanion> rows,
  }) async {
    await transaction(() async {
      if (sessionIds.isNotEmpty) {
        await (delete(routeProjectionLocal)
              ..where(
                (row) =>
                    row.tripLocalId.equals(tripLocalId) &
                    row.sessionId.isIn(sessionIds.toList()),
              ))
            .go();
      }
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(routeProjectionLocal, rows);
      });
    });
  }

  Future<void> replaceAllSegmentsForTrip({
    required String tripLocalId,
    required List<RouteProjectionLocalCompanion> rows,
  }) async {
    await transaction(() async {
      await (delete(routeProjectionLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId)))
          .go();
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(routeProjectionLocal, rows);
      });
    });
  }
}
