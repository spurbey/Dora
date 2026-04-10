import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/route_point_journal_table.dart';

part 'route_point_journal_dao.g.dart';

@DriftAccessor(tables: [RoutePointJournal])
class RoutePointJournalDao extends DatabaseAccessor<AppDatabase>
    with _$RoutePointJournalDaoMixin {
  RoutePointJournalDao(super.db);

  Future<RoutePointJournalRow?> getPointById(String pointId) =>
      (select(routePointJournal)
            ..where((row) => row.pointId.equals(pointId))
            ..limit(1))
          .getSingleOrNull();

  Future<int> upsertPoint(RoutePointJournalCompanion row) =>
      into(routePointJournal).insertOnConflictUpdate(row);

  Future<void> upsertPoints(Iterable<RoutePointJournalCompanion> rows) async {
    if (rows.isEmpty) {
      return;
    }
    await batch((batch) {
      batch.insertAllOnConflictUpdate(routePointJournal, rows.toList());
    });
  }

  Future<List<RoutePointJournalRow>> listPointsForSession(String sessionId) =>
      (select(routePointJournal)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.pointSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Stream<List<RoutePointJournalRow>> watchPointsForSession(String sessionId) =>
      (select(routePointJournal)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.pointSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .watch();

  Future<List<RoutePointJournalRow>> listPointsForTrip(String tripLocalId) =>
      (select(routePointJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();
}
