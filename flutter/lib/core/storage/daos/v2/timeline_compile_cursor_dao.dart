import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/timeline_compile_cursor_table.dart';

part 'timeline_compile_cursor_dao.g.dart';

@DriftAccessor(tables: [TimelineCompileCursor])
class TimelineCompileCursorDao extends DatabaseAccessor<AppDatabase>
    with _$TimelineCompileCursorDaoMixin {
  TimelineCompileCursorDao(super.db);

  Future<TimelineCompileCursorRow?> getCursorForTrip(String tripLocalId) =>
      (select(timelineCompileCursor)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..limit(1))
          .getSingleOrNull();

  Stream<TimelineCompileCursorRow?> watchCursorForTrip(String tripLocalId) =>
      (select(timelineCompileCursor)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..limit(1))
          .watchSingleOrNull();

  Future<int> upsertCursor(TimelineCompileCursorCompanion cursor) =>
      into(timelineCompileCursor).insertOnConflictUpdate(cursor);

  Future<int> clearCursorForTrip(String tripLocalId) =>
      (delete(timelineCompileCursor)
            ..where((row) => row.tripLocalId.equals(tripLocalId)))
          .go();
}
