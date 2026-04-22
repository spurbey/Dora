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
                    expression: row.displayOrder,
                    mode: OrderingMode.desc,
                  ),
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
                    expression: row.displayOrder,
                    mode: OrderingMode.desc,
                  ),
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

  Future<Map<String, double>> listDisplayOrderByEntryIdForTrip(
    String tripLocalId,
  ) async {
    final rows = await (selectOnly(timelineProjectionLocal)
          ..addColumns([
            timelineProjectionLocal.entryId,
            timelineProjectionLocal.displayOrder,
          ])
          ..where(timelineProjectionLocal.tripLocalId.equals(tripLocalId)))
        .get();
    final mapped = <String, double>{};
    for (final row in rows) {
      final entryId = row.read<String>(timelineProjectionLocal.entryId);
      final displayOrder =
          row.read<double>(timelineProjectionLocal.displayOrder);
      if (entryId == null || displayOrder == null) {
        continue;
      }
      mapped[entryId] = displayOrder;
    }
    return mapped;
  }

  Future<Map<String, double>> listDisplayOrderByEntryIdForTripFromCapturedAt({
    required String tripLocalId,
    required DateTime fromCapturedAt,
  }) async {
    final rows = await (selectOnly(timelineProjectionLocal)
          ..addColumns([
            timelineProjectionLocal.entryId,
            timelineProjectionLocal.displayOrder,
          ])
          ..where(
            timelineProjectionLocal.tripLocalId.equals(tripLocalId) &
                timelineProjectionLocal.capturedAt
                    .isBiggerOrEqualValue(fromCapturedAt.toUtc()),
          ))
        .get();
    final mapped = <String, double>{};
    for (final row in rows) {
      final entryId = row.read<String>(timelineProjectionLocal.entryId);
      final displayOrder =
          row.read<double>(timelineProjectionLocal.displayOrder);
      if (entryId == null || displayOrder == null) {
        continue;
      }
      mapped[entryId] = displayOrder;
    }
    return mapped;
  }

  Future<bool> updateDisplayOrder({
    required String tripLocalId,
    required String entryId,
    required double displayOrder,
  }) async {
    final updatedRows = await (update(timelineProjectionLocal)
          ..where(
            (row) =>
                row.tripLocalId.equals(tripLocalId) &
                row.entryId.equals(entryId),
          ))
        .write(
      TimelineProjectionLocalCompanion(
        displayOrder: Value(displayOrder),
      ),
    );
    return updatedRows > 0;
  }

  Future<double?> minDisplayOrderGapForTrip(String tripLocalId) async {
    final rows = await (selectOnly(timelineProjectionLocal)
          ..addColumns([timelineProjectionLocal.displayOrder])
          ..where(
            timelineProjectionLocal.tripLocalId.equals(tripLocalId) &
                timelineProjectionLocal.displayOrder.isNotNull(),
          )
          ..orderBy([
            OrderingTerm(
              expression: timelineProjectionLocal.displayOrder,
              mode: OrderingMode.asc,
            ),
          ]))
        .get();
    if (rows.length < 2) {
      return null;
    }
    var minGap = double.infinity;
    double? previous;
    for (final row in rows) {
      final current = row.read<double>(timelineProjectionLocal.displayOrder);
      if (current == null) {
        continue;
      }
      if (previous != null) {
        final gap = (current - previous).abs();
        if (gap < minGap) {
          minGap = gap;
        }
      }
      previous = current;
    }
    return minGap.isFinite ? minGap : null;
  }

  Future<void> normalizeDisplayOrderForTrip(
    String tripLocalId, {
    double step = 1000.0,
  }) async {
    final rows = await listEntriesForTrip(tripLocalId);
    if (rows.isEmpty) {
      return;
    }
    final ascending = rows.toList(growable: false).reversed.toList();
    await batch((batch) {
      for (var index = 0; index < ascending.length; index++) {
        final row = ascending[index];
        final normalized = (index + 1) * step;
        batch.update(
          timelineProjectionLocal,
          TimelineProjectionLocalCompanion(
            displayOrder: Value(normalized),
          ),
          where: (table) =>
              table.tripLocalId.equals(tripLocalId) &
              table.entryId.equals(row.entryId),
        );
      }
    });
  }
}
