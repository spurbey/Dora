import 'dart:async';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/core/sync/tracking_sync_worker.dart';

class _FakeLiveTrackingApi implements LiveTrackingApi {
  int startCalls = 0;
  int pauseCalls = 0;
  int batchCalls = 0;
  int decisionCalls = 0;
  int momentCalls = 0;
  Completer<void>? startTrackingGate;
  Completer<void>? pauseTrackingGate;

  @override
  Future<Map<String, dynamic>> startTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    startCalls += 1;
    final gate = startTrackingGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    return <String, dynamic>{
      'session_id': 'remote-session-1',
      'state': 'active',
      'started_at': startedAt.toUtc().toIso8601String(),
      'last_point_at': startedAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> pauseTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime pausedAt,
    String? sessionId,
    String? reason,
  }) async {
    pauseCalls += 1;
    final gate = pauseTrackingGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    return <String, dynamic>{
      'session_id': sessionId ?? 'remote-session-1',
      'state': 'paused',
      'paused_at': pausedAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> resumeTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime resumedAt,
    String? sessionId,
  }) async {
    return <String, dynamic>{
      'session_id': sessionId ?? 'remote-session-1',
      'state': 'active',
      'resumed_at': resumedAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> stopTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime stoppedAt,
    String? sessionId,
    String? reason,
  }) async {
    return <String, dynamic>{
      'session_id': sessionId ?? 'remote-session-1',
      'state': 'ended',
      'ended_at': stoppedAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> uploadPointsBatch({
    required String tripId,
    required String idempotencyKey,
    required String sessionId,
    required String clientBatchId,
    required DateTime sentAt,
    required List<Map<String, dynamic>> points,
  }) async {
    batchCalls += 1;
    return <String, dynamic>{
      'trip_id': tripId,
      'session_id': sessionId,
      'client_batch_id': clientBatchId,
      'accepted_points': points.length,
      'duplicate_points': 0,
      'ingest_job_id': 'job-1',
      'idempotency_replayed': false,
    };
  }

  @override
  Future<Map<String, dynamic>> confirmCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime confirmedAt,
  }) async {
    decisionCalls += 1;
    return <String, dynamic>{
      'candidate': <String, dynamic>{'id': candidateId, 'status': 'confirmed'},
      'idempotency_replayed': false,
    };
  }

  @override
  Future<Map<String, dynamic>> rejectCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime rejectedAt,
    String? reason,
  }) async {
    decisionCalls += 1;
    return <String, dynamic>{
      'candidate': <String, dynamic>{'id': candidateId, 'status': 'rejected'},
      'idempotency_replayed': false,
    };
  }

  @override
  Future<Map<String, dynamic>> snoozeCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime snoozedUntil,
  }) async {
    decisionCalls += 1;
    return <String, dynamic>{
      'candidate': <String, dynamic>{'id': candidateId, 'status': 'snoozed'},
      'idempotency_replayed': false,
    };
  }

  @override
  Future<Map<String, dynamic>> createMoment({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime capturedAt,
    String? note,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  }) async {
    momentCalls += 1;
    return <String, dynamic>{
      'id': 'remote-moment-1',
      'trip_id': tripId,
      'captured_at': capturedAt.toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> updateMoment({
    required String momentId,
    required String idempotencyKey,
    required String clientEventId,
    DateTime? capturedAt,
    String? note,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  }) async {
    momentCalls += 1;
    return <String, dynamic>{
      'id': momentId,
      if (capturedAt != null)
        'captured_at': capturedAt.toUtc().toIso8601String(),
    };
  }
}

void main() {
  group('TrackingSyncWorker', () {
    late AppDatabase database;
    late SyncTaskDao syncTaskDao;
    late TrackingSessionDao sessionDao;
    late TrackingPointBatchDao batchDao;
    late TrackingCandidateDao candidateDao;
    late TrackingMomentDao momentDao;
    late _FakeLiveTrackingApi fakeApi;
    late TrackingSyncWorker worker;

    Future<Map<String, Object?>> readTask(String taskId) async {
      final row = await database.customSelect(
        '''
        SELECT
          status,
          retry_count,
          next_attempt_at,
          error_code,
          error_message,
          depends_on_entity_type,
          depends_on_entity_id,
          worker_session_id
        FROM sync_tasks
        WHERE id = ?
        LIMIT 1
        ''',
        variables: [Variable<String>(taskId)],
      ).getSingle();
      return <String, Object?>{
        'status': row.read<String>('status'),
        'retry_count': row.read<int>('retry_count'),
        'next_attempt_at': row.read<DateTime?>('next_attempt_at'),
        'error_code': row.read<String?>('error_code'),
        'error_message': row.read<String?>('error_message'),
        'depends_on_entity_type': row.read<String?>('depends_on_entity_type'),
        'depends_on_entity_id': row.read<String?>('depends_on_entity_id'),
        'worker_session_id': row.read<String?>('worker_session_id'),
      };
    }

    Future<void> waitForTaskStatus({
      required String taskId,
      required String status,
      int maxAttempts = 30,
    }) async {
      for (var i = 0; i < maxAttempts; i += 1) {
        final task = await readTask(taskId);
        if (task['status'] == status) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      fail('Task $taskId did not reach status $status');
    }

    Future<void> waitForCondition({
      required bool Function() condition,
      String description = 'condition',
      int maxAttempts = 30,
    }) async {
      for (var i = 0; i < maxAttempts; i += 1) {
        if (condition()) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      fail('Timed out waiting for $description');
    }

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      syncTaskDao = SyncTaskDao(database);
      sessionDao = TrackingSessionDao(database);
      batchDao = TrackingPointBatchDao(database);
      candidateDao = TrackingCandidateDao(database);
      momentDao = TrackingMomentDao(database);
      fakeApi = _FakeLiveTrackingApi();
      worker = TrackingSyncWorker(
        db: database,
        syncTaskDao: syncTaskDao,
        trackingSessionDao: sessionDao,
        trackingPointBatchDao: batchDao,
        trackingCandidateDao: candidateDao,
        trackingMomentDao: momentDao,
        liveTrackingApi: fakeApi,
        maxConcurrency: 1,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('processes tracking point batch and completes task', () async {
      final now = DateTime.now().toUtc();
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-local-1',
          tripId: 'trip-1',
          remoteSessionId: const Value('session-remote-1'),
          clientSessionId: 'client-session-1',
          state: const Value('active'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: Value(now),
        ),
      );
      await batchDao.upsertBatch(
        TrackingPointBatchesCompanion.insert(
          id: 'batch-local-1',
          tripId: 'trip-1',
          sessionId: 'session-local-1',
          remoteSessionId: const Value('session-remote-1'),
          clientBatchId: 'batch-client-1',
          pointsJson: const Value(
            '[{"point_id":"p-1","recorded_at":"2026-03-23T10:00:00Z","latitude":27.7,"longitude":85.3}]',
          ),
          pointCount: const Value(1),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-batch-1',
        entityType: SyncEntityTypes.trackingPointBatch,
        entityId: 'batch-local-1',
        operation: 'upload',
      );

      await worker.startIfIdle();

      final task = await readTask('task-tracking-batch-1');
      expect(task['status'], 'completed');
      expect(task['error_code'], isNull);
      expect(task['worker_session_id'], isNull);

      final batch = await batchDao.getBatchById('batch-local-1');
      expect(batch, isNotNull);
      expect(batch!.status, 'completed');
      expect(batch.syncStatus, 'synced');
      expect(fakeApi.batchCalls, 1);
    });

    test('keeps point batch task pending when remote session id is missing',
        () async {
      final now = DateTime.now().toUtc();
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-local-2',
          tripId: 'trip-2',
          clientSessionId: 'client-session-2',
          state: const Value('active'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await batchDao.upsertBatch(
        TrackingPointBatchesCompanion.insert(
          id: 'batch-local-2',
          tripId: 'trip-2',
          sessionId: 'session-local-2',
          clientBatchId: 'batch-client-2',
          pointsJson: const Value('[{"point_id":"p-1"}]'),
          pointCount: const Value(1),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-batch-2',
        entityType: SyncEntityTypes.trackingPointBatch,
        entityId: 'batch-local-2',
        operation: 'upload',
      );

      await worker.startIfIdle();

      final task = await readTask('task-tracking-batch-2');
      expect(task['status'], 'pending');
      expect(task['error_code'], 'tracking_session_remote_id_missing');
      expect(task['depends_on_entity_type'], SyncEntityTypes.trackingSession);
      expect(task['depends_on_entity_id'], 'session-local-2');
      expect(task['next_attempt_at'], isNotNull);
      expect(task['worker_session_id'], isNull);
    });

    test(
        'keeps tracking session syncStatus pending when task is requeued mid-flight',
        () async {
      final now = DateTime.now().toUtc();
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-local-requeue-1',
          tripId: 'trip-requeue-1',
          clientSessionId: 'client-session-requeue-1',
          state: const Value('planned'),
          startedAt: Value(now),
          syncStatus: const Value('pending'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-session-requeue-1',
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-local-requeue-1',
        operation: 'start',
      );

      fakeApi.startTrackingGate = Completer<void>();
      fakeApi.pauseTrackingGate = Completer<void>();
      final runFuture = worker.startIfIdle();
      await waitForTaskStatus(
        taskId: 'task-tracking-session-requeue-1',
        status: 'in_progress',
      );

      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-session-requeue-2',
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-local-requeue-1',
        operation: 'pause',
      );

      fakeApi.startTrackingGate!.complete();
      await waitForCondition(
        condition: () => fakeApi.pauseCalls == 1,
        description: 'pause sync call',
      );

      final task = await readTask('task-tracking-session-requeue-1');
      expect(task['status'], 'in_progress');
      final queuedTask = await syncTaskDao.getTaskById(
        'task-tracking-session-requeue-1',
      );
      expect(queuedTask, isNotNull);
      expect(queuedTask!.operation, 'pause');

      final session =
          await sessionDao.getSessionById('session-local-requeue-1');
      expect(session, isNotNull);
      expect(session!.syncStatus, 'pending');
      expect(fakeApi.startCalls, 1);

      fakeApi.pauseTrackingGate!.complete();
      await runFuture;
      final completedTask = await readTask('task-tracking-session-requeue-1');
      expect(completedTask['status'], 'completed');
      expect(fakeApi.pauseCalls, 1);
    });

    test('keeps non-tracking tasks unclaimed', () async {
      final now = DateTime.now().toUtc();
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-local-3',
          tripId: 'trip-3',
          remoteSessionId: const Value('session-remote-3'),
          clientSessionId: 'client-session-3',
          state: const Value('active'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: Value(now),
        ),
      );
      await batchDao.upsertBatch(
        TrackingPointBatchesCompanion.insert(
          id: 'batch-local-3',
          tripId: 'trip-3',
          sessionId: 'session-local-3',
          remoteSessionId: const Value('session-remote-3'),
          clientBatchId: 'batch-client-3',
          pointsJson: const Value('[{"point_id":"p-1"}]'),
          pointCount: const Value(1),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-trip-non-tracking',
        entityType: SyncEntityTypes.trip,
        entityId: 'trip-non-tracking',
        operation: 'update',
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-batch-3',
        entityType: SyncEntityTypes.trackingPointBatch,
        entityId: 'batch-local-3',
        operation: 'upload',
      );

      await worker.startIfIdle();

      final nonTrackingTask = await readTask('task-trip-non-tracking');
      expect(nonTrackingTask['status'], 'queued');
      expect(nonTrackingTask['error_code'], isNull);

      final trackingTask = await readTask('task-tracking-batch-3');
      expect(trackingTask['status'], 'completed');
      expect(fakeApi.batchCalls, 1);
    });

    test('syncs queued checkin decision and marks candidate synced', () async {
      final now = DateTime.now().toUtc();
      await candidateDao.upsertCandidate(
        TrackingCandidatesCompanion.insert(
          id: 'candidate-local-1',
          tripId: 'trip-4',
          fingerprint: 'fp-1',
          status: const Value('pending'),
          actionState: const Value('queued'),
          actionType: const Value('reject'),
          actionClientEventId: const Value('event-1'),
          actionQueuedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-checkin-decision-1',
        entityType: SyncEntityTypes.checkinDecision,
        entityId: 'candidate-local-1',
        operation: 'reject',
      );

      await worker.startIfIdle();

      final task = await readTask('task-checkin-decision-1');
      expect(task['status'], 'completed');
      expect(task['error_code'], isNull);

      final candidate =
          await candidateDao.getCandidateById('candidate-local-1');
      expect(candidate, isNotNull);
      expect(candidate!.status, 'rejected');
      expect(candidate.actionState, 'synced');
      expect(candidate.syncStatus, 'synced');
      expect(fakeApi.decisionCalls, 1);
    });
  });
}
