import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/sync_tasks_table.dart';

part 'sync_task_dao.g.dart';

@DriftAccessor(tables: [SyncTasks])
class SyncTaskDao extends DatabaseAccessor<AppDatabase> with _$SyncTaskDaoMixin {
  SyncTaskDao(super.db);

  Future<void> upsertQueuedTask({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    String? remoteEntityId,
    String? dependsOnEntityType,
    String? dependsOnEntityId,
  }) async {
    final now = DateTime.now();
    final existing = await (select(syncTasks)
          ..where((t) =>
              t.entityType.equals(entityType) & t.entityId.equals(entityId))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      final isInProgress = existing.status == 'in_progress';
      final Value<String?> remoteEntityIdValue =
          (remoteEntityId == null && isInProgress)
          ? const Value.absent()
          : Value(remoteEntityId);
      await (update(syncTasks)..where((t) => t.id.equals(existing.id))).write(
        SyncTasksCompanion(
          operation: Value(operation),
          status: isInProgress ? const Value.absent() : const Value('queued'),
          remoteEntityId: remoteEntityIdValue,
          retryCount: isInProgress ? const Value.absent() : const Value(0),
          nextAttemptAt: isInProgress ? const Value.absent() : const Value(null),
          dependsOnEntityType: Value(dependsOnEntityType),
          dependsOnEntityId: Value(dependsOnEntityId),
          errorCode: isInProgress ? const Value.absent() : const Value(null),
          errorMessage: isInProgress ? const Value.absent() : const Value(null),
          workerSessionId:
              isInProgress ? const Value.absent() : const Value(null),
          updatedAt: Value(now),
        ),
      );
      return;
    }

    await into(syncTasks).insert(
      SyncTasksCompanion.insert(
        id: id,
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        remoteEntityId: Value(remoteEntityId),
        status: const Value('queued'),
        retryCount: const Value(0),
        nextAttemptAt: const Value(null),
        dependsOnEntityType: Value(dependsOnEntityType),
        dependsOnEntityId: Value(dependsOnEntityId),
        errorCode: const Value(null),
        errorMessage: const Value(null),
        workerSessionId: const Value(null),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<SyncTaskRow>> getRunnableTasks({
    DateTime? now,
    int limit = 20,
  }) async {
    final currentTime = now ?? DateTime.now();
    final rows = await customSelect(
      '''
      SELECT t.*
      FROM sync_tasks AS t
      WHERE t.status IN ('queued', 'failed')
        AND (t.next_attempt_at IS NULL OR t.next_attempt_at <= ?)
        AND (
          t.depends_on_entity_type IS NULL
          OR t.depends_on_entity_id IS NULL
          OR NOT EXISTS (
            SELECT 1
            FROM sync_tasks AS dependency
            WHERE dependency.entity_type = t.depends_on_entity_type
              AND dependency.entity_id = t.depends_on_entity_id
              AND dependency.status <> 'completed'
          )
        )
      ORDER BY t.created_at
      LIMIT ?
      ''',
      variables: [
        Variable<DateTime>(currentTime),
        Variable<int>(limit),
      ],
      readsFrom: {syncTasks},
    ).get();
    return rows.map((row) => syncTasks.map(row.data)).toList();
  }

  Future<List<SyncTaskRow>> claimRunnableTasks({
    required String workerSessionId,
    DateTime? now,
    int limit = 10,
  }) async {
    final claimTime = now ?? DateTime.now();
    return transaction(() async {
      final runnable = await getRunnableTasks(now: claimTime, limit: limit);
      if (runnable.isEmpty) {
        return const <SyncTaskRow>[];
      }

      final claimedIds = <String>[];
      for (final task in runnable) {
        final affected = await customUpdate(
          '''
          UPDATE sync_tasks
          SET
            status = 'in_progress',
            worker_session_id = ?,
            updated_at = ?
          WHERE id = ?
            AND status IN ('queued', 'failed')
            AND (next_attempt_at IS NULL OR next_attempt_at <= ?)
            AND (
              depends_on_entity_type IS NULL
              OR depends_on_entity_id IS NULL
              OR NOT EXISTS (
                SELECT 1
                FROM sync_tasks AS dependency
                WHERE dependency.entity_type = sync_tasks.depends_on_entity_type
                  AND dependency.entity_id = sync_tasks.depends_on_entity_id
                  AND dependency.status <> 'completed'
              )
            )
          ''',
          variables: [
            Variable<String>(workerSessionId),
            Variable<DateTime>(claimTime),
            Variable<String>(task.id),
            Variable<DateTime>(claimTime),
          ],
          updates: {syncTasks},
        );
        if (affected == 1) {
          claimedIds.add(task.id);
        }
      }

      if (claimedIds.isEmpty) {
        return const <SyncTaskRow>[];
      }

      return (select(syncTasks)
            ..where((t) => t.id.isIn(claimedIds))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();
    });
  }

  Future<int> markCompleted({
    required String taskId,
    String? expectedSessionId,
  }) {
    return _updateTaskState(
      taskId: taskId,
      expectedSessionId: expectedSessionId,
      companion: SyncTasksCompanion(
        status: const Value('completed'),
        retryCount: const Value(0),
        nextAttemptAt: const Value(null),
        errorCode: const Value(null),
        errorMessage: const Value(null),
        workerSessionId: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> markBlocked({
    required String taskId,
    required String errorCode,
    required String errorMessage,
    String? expectedSessionId,
    String? dependsOnEntityType,
    String? dependsOnEntityId,
  }) {
    return _updateTaskState(
      taskId: taskId,
      expectedSessionId: expectedSessionId,
      companion: SyncTasksCompanion(
        status: const Value('blocked'),
        errorCode: Value(errorCode),
        errorMessage: Value(errorMessage),
        dependsOnEntityType: Value(dependsOnEntityType),
        dependsOnEntityId: Value(dependsOnEntityId),
        workerSessionId: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> markFailed({
    required String taskId,
    required int retryCount,
    required String errorCode,
    required String errorMessage,
    DateTime? nextAttemptAt,
    String? expectedSessionId,
  }) {
    return _updateTaskState(
      taskId: taskId,
      expectedSessionId: expectedSessionId,
      companion: SyncTasksCompanion(
        status: const Value('failed'),
        retryCount: Value(retryCount),
        nextAttemptAt: Value(nextAttemptAt),
        errorCode: Value(errorCode),
        errorMessage: Value(errorMessage),
        workerSessionId: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> releaseSession({
    required String taskId,
    required String expectedSessionId,
  }) {
    return (update(syncTasks)
          ..where((t) =>
              t.id.equals(taskId) &
              t.workerSessionId.equals(expectedSessionId)))
        .write(
      SyncTasksCompanion(
        workerSessionId: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<SyncTaskRow>> getActiveTasks({int limit = 100}) {
    return (select(syncTasks)
          ..where((t) => t.status.isIn(const [
                'queued',
                'in_progress',
                'blocked',
                'failed',
              ]))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<SyncTaskRow?> getTaskByEntity({
    required String entityType,
    required String entityId,
  }) {
    return (select(syncTasks)
          ..where((t) =>
              t.entityType.equals(entityType) & t.entityId.equals(entityId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> _updateTaskState({
    required String taskId,
    required SyncTasksCompanion companion,
    String? expectedSessionId,
  }) {
    var predicate = syncTasks.id.equals(taskId);
    if (expectedSessionId != null) {
      predicate = predicate & syncTasks.workerSessionId.equals(expectedSessionId);
    }
    final query = update(syncTasks)..where((_) => predicate);
    return query.write(companion);
  }
}
