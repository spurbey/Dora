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
  });
}
