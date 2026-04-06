import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/tracking_point_batches_table.dart';

part 'tracking_point_batch_dao.g.dart';

@DriftAccessor(tables: [TrackingPointBatches])
class TrackingPointBatchDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingPointBatchDaoMixin {
  TrackingPointBatchDao(super.db);
  static const Duration _staleInProgressTimeout = Duration(minutes: 3);

  Future<TrackingPointBatchRow?> getBatchById(String id) =>
      (select(trackingPointBatches)..where((b) => b.id.equals(id)))
          .getSingleOrNull();

  Future<List<TrackingPointBatchRow>> getBatchesForSession(String sessionId) =>
      (select(trackingPointBatches)
            ..where((b) => b.sessionId.equals(sessionId))
            ..orderBy([
              (b) => OrderingTerm(
                    expression: b.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Stream<List<TrackingPointBatchRow>> watchBatchesForSession(
          String sessionId) =>
      (select(trackingPointBatches)
            ..where((b) => b.sessionId.equals(sessionId))
            ..orderBy([
              (b) => OrderingTerm(
                    expression: b.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .watch();

  Future<TrackingPointBatchRow?> getLatestMutableBatchForSession(
    String sessionId,
  ) =>
      (select(trackingPointBatches)
            ..where(
              (b) =>
                  b.sessionId.equals(sessionId) &
                  b.status.equals('queued') &
                  b.workerSessionId.isNull(),
            )
            ..orderBy([
              (b) => OrderingTerm(
                    expression: b.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<int> upsertBatch(TrackingPointBatchesCompanion row) =>
      into(trackingPointBatches).insertOnConflictUpdate(row);

  Future<List<TrackingPointBatchRow>> getPendingBatches({
    DateTime? now,
    int limit = 50,
  }) {
    final currentTime = now ?? DateTime.now();
    final staleInProgressBefore = currentTime.subtract(_staleInProgressTimeout);
    return (select(trackingPointBatches)
          ..where(
            (b) =>
                b.workerSessionId.isNull() &
                (b.status.isIn(const ['queued', 'failed']) |
                    (b.status.equals('in_progress') &
                        b.updatedAt.isSmallerOrEqualValue(
                          staleInProgressBefore,
                        ))) &
                (b.nextAttemptAt.isNull() |
                    b.nextAttemptAt.isSmallerOrEqualValue(currentTime)),
          )
          ..orderBy([
            (b) =>
                OrderingTerm(expression: b.createdAt, mode: OrderingMode.asc),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<TrackingPointBatchRow>> claimPendingBatches({
    required String workerSessionId,
    DateTime? now,
    int limit = 10,
  }) async {
    final claimTime = now ?? DateTime.now();
    final staleInProgressBefore = claimTime.subtract(_staleInProgressTimeout);
    return transaction(() async {
      final candidates = await getPendingBatches(now: claimTime, limit: limit);
      if (candidates.isEmpty) {
        return const <TrackingPointBatchRow>[];
      }

      final claimedIds = <String>[];
      for (final row in candidates) {
        final affected = await customUpdate(
          '''
          UPDATE tracking_point_batches
          SET
            status = 'in_progress',
            worker_session_id = ?,
            local_updated_at = ?,
            updated_at = ?
          WHERE id = ?
            AND worker_session_id IS NULL
            AND (
              status IN ('queued', 'failed')
              OR (status = 'in_progress' AND updated_at <= ?)
            )
            AND (next_attempt_at IS NULL OR next_attempt_at <= ?)
          ''',
          variables: [
            Variable<String>(workerSessionId),
            Variable<DateTime>(claimTime),
            Variable<DateTime>(claimTime),
            Variable<String>(row.id),
            Variable<DateTime>(staleInProgressBefore),
            Variable<DateTime>(claimTime),
          ],
          updates: {trackingPointBatches},
        );
        if (affected == 1) {
          claimedIds.add(row.id);
        }
      }

      if (claimedIds.isEmpty) {
        return const <TrackingPointBatchRow>[];
      }

      return (select(trackingPointBatches)
            ..where((b) => b.id.isIn(claimedIds))
            ..orderBy([
              (b) => OrderingTerm(
                    expression: b.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();
    });
  }

  Future<int> markCompleted({
    required String batchId,
    DateTime? serverUpdatedAt,
  }) {
    final now = DateTime.now();
    return (update(trackingPointBatches)..where((b) => b.id.equals(batchId)))
        .write(
      TrackingPointBatchesCompanion(
        status: const Value('completed'),
        syncStatus: const Value('synced'),
        retryCount: const Value(0),
        nextAttemptAt: const Value(null),
        lastError: const Value(null),
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        serverUpdatedAt: Value(serverUpdatedAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markFailed({
    required String batchId,
    required String errorMessage,
    required int retryCount,
    DateTime? nextAttemptAt,
  }) {
    final now = DateTime.now();
    return (update(trackingPointBatches)..where((b) => b.id.equals(batchId)))
        .write(
      TrackingPointBatchesCompanion(
        status: const Value('failed'),
        syncStatus: const Value('pending'),
        retryCount: Value(retryCount),
        nextAttemptAt: Value(nextAttemptAt),
        lastError: Value(errorMessage),
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markDroppedStaleSession({
    required String batchId,
    required String reason,
    DateTime? updatedAt,
  }) {
    final now = (updatedAt ?? DateTime.now()).toUtc();
    return (update(trackingPointBatches)..where((b) => b.id.equals(batchId)))
        .write(
      TrackingPointBatchesCompanion(
        status: const Value('dropped_stale_session'),
        syncStatus: const Value('synced'),
        retryCount: const Value(0),
        nextAttemptAt: const Value(null),
        workerSessionId: const Value(null),
        lastError: Value(reason),
        localUpdatedAt: Value(now),
        serverUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markSessionBatchesDroppedStaleSession({
    required String sessionId,
    required String reason,
    DateTime? updatedAt,
  }) async {
    final now = (updatedAt ?? DateTime.now()).toUtc();
    return customUpdate(
      '''
      UPDATE tracking_point_batches
      SET
        status = 'dropped_stale_session',
        sync_status = 'synced',
        retry_count = 0,
        next_attempt_at = NULL,
        worker_session_id = NULL,
        last_error = ?,
        local_updated_at = ?,
        server_updated_at = ?,
        updated_at = ?
      WHERE session_id = ?
        AND status NOT IN ('completed', 'dropped_stale_session')
      ''',
      variables: [
        Variable<String>(reason),
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(sessionId),
      ],
      updates: {trackingPointBatches},
    );
  }

  Future<int> clearWorkerSession({
    required String batchId,
    String? expectedSessionId,
  }) {
    if (expectedSessionId == null) {
      final now = DateTime.now();
      return customUpdate(
        '''
        UPDATE tracking_point_batches
        SET
          worker_session_id = NULL,
          status = CASE WHEN status = 'in_progress' THEN 'queued' ELSE status END,
          local_updated_at = ?,
          updated_at = ?
        WHERE id = ?
        ''',
        variables: [
          Variable<DateTime>(now),
          Variable<DateTime>(now),
          Variable<String>(batchId),
        ],
        updates: {trackingPointBatches},
      );
    }

    final now = DateTime.now();
    return customUpdate(
      '''
      UPDATE tracking_point_batches
      SET
        worker_session_id = NULL,
        status = CASE WHEN status = 'in_progress' THEN 'queued' ELSE status END,
        local_updated_at = ?,
        updated_at = ?
      WHERE id = ?
        AND worker_session_id = ?
      ''',
      variables: [
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(batchId),
        Variable<String>(expectedSessionId),
      ],
      updates: {trackingPointBatches},
    );
  }
}
