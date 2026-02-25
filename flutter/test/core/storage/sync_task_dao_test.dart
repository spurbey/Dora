import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

void main() {
  group('SyncTaskDao', () {
    late AppDatabase database;
    late SyncTaskDao dao;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      dao = SyncTaskDao(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('upsertQueuedTask inserts once and re-queues existing task', () async {
      await dao.upsertQueuedTask(
        id: 'task-1',
        entityType: 'trip',
        entityId: 'trip-1',
        operation: 'create',
      );

      final first = await dao.getActiveTasks(limit: 10);
      expect(first.length, 1);
      expect(first.first.id, 'task-1');
      expect(first.first.status, 'queued');
      expect(first.first.operation, 'create');

      await dao.claimRunnableTasks(
        workerSessionId: 'worker-1',
        limit: 10,
      );

      await dao.upsertQueuedTask(
        id: 'task-2',
        entityType: 'trip',
        entityId: 'trip-1',
        operation: 'update',
      );

      final afterUpsert = await dao.getActiveTasks(limit: 10);
      expect(afterUpsert.length, 1);
      expect(afterUpsert.first.id, 'task-1');
      expect(afterUpsert.first.status, 'queued');
      expect(afterUpsert.first.operation, 'update');
    });

    test('claimRunnableTasks ignores not-ready failed tasks', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final later = now + const Duration(minutes: 5).inMilliseconds;

      await database.customInsert(
        '''
        INSERT INTO sync_tasks (
          id,
          entity_type,
          entity_id,
          operation,
          status,
          retry_count,
          next_attempt_at,
          created_at,
          updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, NULL, ?, ?)
        ''',
        variables: [
          Variable<String>('task-ready'),
          Variable<String>('place'),
          Variable<String>('place-1'),
          Variable<String>('create'),
          Variable<String>('queued'),
          Variable<int>(0),
          Variable<int>(now),
          Variable<int>(now),
        ],
      );

      await database.customInsert(
        '''
        INSERT INTO sync_tasks (
          id,
          entity_type,
          entity_id,
          operation,
          status,
          retry_count,
          next_attempt_at,
          created_at,
          updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        variables: [
          Variable<String>('task-failed-future'),
          Variable<String>('place'),
          Variable<String>('place-2'),
          Variable<String>('create'),
          Variable<String>('failed'),
          Variable<int>(1),
          Variable<int>(later),
          Variable<int>(now),
          Variable<int>(now),
        ],
      );

      final claimed = await dao.claimRunnableTasks(
        workerSessionId: 'worker-2',
        limit: 10,
      );

      expect(claimed.length, 1);
      expect(claimed.first.id, 'task-ready');
      expect(claimed.first.status, 'in_progress');

      final rows = await database.customSelect(
        '''
        SELECT id, status
        FROM sync_tasks
        ORDER BY id
        ''',
      ).get();

      final statusById = {
        for (final row in rows) row.read<String>('id'): row.read<String>('status'),
      };

      expect(statusById['task-ready'], 'in_progress');
      expect(statusById['task-failed-future'], 'failed');
    });

    test('upsertQueuedTask stores remoteEntityId for delete operations', () async {
      await dao.upsertQueuedTask(
        id: 'task-delete-1',
        entityType: 'place',
        entityId: 'place-remote-1',
        operation: 'delete',
        remoteEntityId: 'remote-place-1',
      );

      final row = await database.customSelect(
        '''
        SELECT operation, remote_entity_id
        FROM sync_tasks
        WHERE entity_type = 'place' AND entity_id = 'place-remote-1'
        LIMIT 1
        ''',
      ).getSingle();

      expect(row.read<String>('operation'), 'delete');
      expect(row.read<String?>('remote_entity_id'), 'remote-place-1');
    });

    test('upsertQueuedTask does not clear in-progress worker lock', () async {
      await dao.upsertQueuedTask(
        id: 'task-lock-1',
        entityType: 'trip',
        entityId: 'trip-lock-1',
        operation: 'create',
      );

      final claimed = await dao.claimRunnableTasks(
        workerSessionId: 'worker-lock',
        limit: 10,
      );
      expect(claimed.length, 1);
      expect(claimed.first.status, 'in_progress');

      await dao.upsertQueuedTask(
        id: 'task-lock-2',
        entityType: 'trip',
        entityId: 'trip-lock-1',
        operation: 'update',
      );

      final row = (await database.customSelect(
        '''
        SELECT status, operation, worker_session_id
        FROM sync_tasks
        WHERE entity_type = 'trip' AND entity_id = 'trip-lock-1'
        LIMIT 1
        ''',
      ).getSingle());

      expect(row.read<String>('status'), 'in_progress');
      expect(row.read<String>('operation'), 'update');
      expect(row.read<String?>('worker_session_id'), isNot(equals(null)));
    });

    test('upsertQueuedTask preserves in-progress remoteEntityId when absent', () async {
      await dao.upsertQueuedTask(
        id: 'task-lock-remote-1',
        entityType: 'route',
        entityId: 'route-lock-1',
        operation: 'delete',
        remoteEntityId: 'remote-route-1',
      );

      await dao.claimRunnableTasks(
        workerSessionId: 'worker-lock-remote',
        limit: 10,
      );

      await dao.upsertQueuedTask(
        id: 'task-lock-remote-2',
        entityType: 'route',
        entityId: 'route-lock-1',
        operation: 'update',
      );

      final row = await database.customSelect(
        '''
        SELECT status, operation, remote_entity_id
        FROM sync_tasks
        WHERE entity_type = 'route' AND entity_id = 'route-lock-1'
        LIMIT 1
        ''',
      ).getSingle();

      expect(row.read<String>('status'), 'in_progress');
      expect(row.read<String>('operation'), 'update');
      expect(row.read<String?>('remote_entity_id'), 'remote-route-1');
    });

    test('claimRunnableTasks waits for dependency task completion', () async {
      await dao.upsertQueuedTask(
        id: 'trip-task-1',
        entityType: 'trip',
        entityId: 'trip-1',
        operation: 'create',
      );
      await dao.upsertQueuedTask(
        id: 'place-task-1',
        entityType: 'place',
        entityId: 'place-1',
        operation: 'create',
        dependsOnEntityType: 'trip',
        dependsOnEntityId: 'trip-1',
      );

      final firstClaim = await dao.claimRunnableTasks(
        workerSessionId: 'worker-dep-1',
        limit: 10,
      );

      expect(firstClaim.length, 1);
      expect(firstClaim.first.id, 'trip-task-1');

      await dao.markCompleted(
        taskId: 'trip-task-1',
        expectedSessionId: 'worker-dep-1',
      );

      final secondClaim = await dao.claimRunnableTasks(
        workerSessionId: 'worker-dep-2',
        limit: 10,
      );

      expect(secondClaim.length, 1);
      expect(secondClaim.first.id, 'place-task-1');
    });

    test('claimRunnableTasks does not run when dependency is blocked', () async {
      await dao.upsertQueuedTask(
        id: 'trip-task-blocked',
        entityType: 'trip',
        entityId: 'trip-b',
        operation: 'create',
      );
      await dao.upsertQueuedTask(
        id: 'place-task-blocked',
        entityType: 'place',
        entityId: 'place-b',
        operation: 'create',
        dependsOnEntityType: 'trip',
        dependsOnEntityId: 'trip-b',
      );

      final firstClaim = await dao.claimRunnableTasks(
        workerSessionId: 'worker-dep-block-1',
        limit: 10,
      );
      expect(firstClaim.length, 1);
      expect(firstClaim.first.id, 'trip-task-blocked');

      await dao.markBlocked(
        taskId: 'trip-task-blocked',
        errorCode: 'trip_create_forbidden',
        errorMessage: 'Trip create denied',
        expectedSessionId: 'worker-dep-block-1',
      );

      final secondClaim = await dao.claimRunnableTasks(
        workerSessionId: 'worker-dep-block-2',
        limit: 10,
      );

      expect(secondClaim, isEmpty);
    });
  });
}
