import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/timeline_projection_local_table.dart';

part 'timeline_projection_local_dao.g.dart';

@DriftAccessor(tables: [TimelineProjectionLocal])
class TimelineProjectionLocalDao extends DatabaseAccessor<AppDatabase>
    with _$TimelineProjectionLocalDaoMixin {
  TimelineProjectionLocalDao(super.db);

  Stream<List<TimelineProjectionLocalRow>> watchEntriesForTrip(
    String tripLocalId,
  ) =>
      (select(timelineProjectionLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<List<TimelineProjectionLocalRow>> listEntriesForTrip(
    String tripLocalId,
  ) =>
      (select(timelineProjectionLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Future<List<TimelineProjectionLocalRow>> listEntriesForTripFromCapturedAt(
    String tripLocalId,
    DateTime fromCapturedAt,
  ) =>
      (select(timelineProjectionLocal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.capturedAt.isBiggerOrEqualValue(fromCapturedAt.toUtc()),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<void> replaceEntriesForTripFromCapturedAt({
    required String tripLocalId,
    required DateTime fromCapturedAt,
    required List<TimelineProjectionLocalCompanion> rows,
  }) async {
    await transaction(() async {
      await (delete(timelineProjectionLocal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.capturedAt.isBiggerOrEqualValue(fromCapturedAt.toUtc()),
            ))
          .go();
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(timelineProjectionLocal, rows);
      });
    });
  }

  Future<void> replaceAllEntriesForTrip({
    required String tripLocalId,
    required List<TimelineProjectionLocalCompanion> rows,
  }) async {
    await transaction(() async {
      await (delete(timelineProjectionLocal)
            ..where((row) => row.tripLocalId.equals(tripLocalId)))
          .go();
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(timelineProjectionLocal, rows);
      });
    });
  }

  Future<int> countEntriesForTrip(String tripLocalId) async {
    final row = await (selectOnly(timelineProjectionLocal)
          ..addColumns([timelineProjectionLocal.entryId.count()])
          ..where(timelineProjectionLocal.tripLocalId.equals(tripLocalId)))
        .getSingle();
    return row.read(timelineProjectionLocal.entryId.count()) ?? 0;
  }
}
