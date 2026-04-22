import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/route_segment_claim_local_table.dart';

part 'route_segment_claim_local_dao.g.dart';

@DriftAccessor(tables: [RouteSegmentClaimLocal])
class RouteSegmentClaimLocalDao extends DatabaseAccessor<AppDatabase>
    with _$RouteSegmentClaimLocalDaoMixin {
  RouteSegmentClaimLocalDao(super.db);

  Stream<List<RouteSegmentClaimLocalRow>> watchClaimsForTrip(
          String tripLocalId) =>
      (select(routeSegmentClaimLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.manualRouteId,
                    mode: OrderingMode.asc,
                  ),
              (row) => OrderingTerm(
                    expression: row.routeSegmentKey,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .watch();

  Future<List<RouteSegmentClaimLocalRow>> listClaimsForTrip(
          String tripLocalId) =>
      (select(routeSegmentClaimLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.manualRouteId,
                    mode: OrderingMode.asc,
                  ),
              (row) => OrderingTerm(
                    expression: row.routeSegmentKey,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<Set<String>> listClaimedSegmentKeysForTrip(String tripLocalId) async {
    final rows = await (selectOnly(routeSegmentClaimLocal)
          ..addColumns([routeSegmentClaimLocal.routeSegmentKey])
          ..where(routeSegmentClaimLocal.tripLocalId.equals(tripLocalId)))
        .get();
    return rows
        .map((row) => row.read<String>(routeSegmentClaimLocal.routeSegmentKey))
        .whereType<String>()
        .toSet();
  }

  Stream<Set<String>> watchClaimedSegmentKeysForTrip(String tripLocalId) {
    return (selectOnly(routeSegmentClaimLocal)
          ..addColumns([routeSegmentClaimLocal.routeSegmentKey])
          ..where(routeSegmentClaimLocal.tripLocalId.equals(tripLocalId)))
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => row.read<String>(
                  routeSegmentClaimLocal.routeSegmentKey,
                ),
              )
              .whereType<String>()
              .toSet(),
        );
  }

  Future<void> replaceClaimsForTrip({
    required String tripLocalId,
    required List<RouteSegmentClaimLocalCompanion> rows,
  }) async {
    await transaction(() async {
      await (delete(routeSegmentClaimLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId)))
          .go();
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(routeSegmentClaimLocal, rows);
      });
    });
  }
}
