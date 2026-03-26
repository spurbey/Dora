import 'dart:async';

import 'package:dio/dio.dart';
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
  final List<String> startTripIds = <String>[];
  final List<String> pauseTripIds = <String>[];
  final List<String> batchTripIds = <String>[];
  final List<String> momentCreateTripIds = <String>[];
  final List<String> momentUpdateIds = <String>[];
  final List<bool> momentUpdateIncludeNote = <bool>[];
  final List<bool> momentUpdateIncludeLinkedTripPlaceId = <bool>[];
  Object? startError;
  Object? decisionError;
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
    final forcedError = startError;
    if (forcedError != null) {
      throw forcedError;
    }
    startCalls += 1;
    startTripIds.add(tripId);
    final gate = startTrackingGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    return <String, dynamic>{
      'session_id': 'remote-session-1',
      'trip_id': tripId,
      'state': 'active',
      'client_session_id': clientSessionId,
      'started_at': startedAt.toUtc().toIso8601String(),
      'paused_at': null,
      'resumed_at': null,
      'ended_at': null,
      'abandoned_at': null,
      'last_point_at': startedAt.toUtc().toIso8601String(),
      'updated_at':
          startedAt.toUtc().add(const Duration(seconds: 45)).toIso8601String(),
      'timezone': timezone,
      'device_context': <String, dynamic>{
        'platform': 'android',
        'sdk': '34',
        ...?deviceContext,
      },
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
    pauseTripIds.add(tripId);
    final gate = pauseTrackingGate;
    if (gate != null && !gate.isCompleted) {
      await gate.future;
    }
    return <String, dynamic>{
      'session_id': sessionId ?? 'remote-session-1',
      'state': 'paused',
      'paused_at': pausedAt.toUtc().toIso8601String(),
      'updated_at':
          pausedAt.toUtc().add(const Duration(seconds: 30)).toIso8601String(),
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
      'updated_at':
          resumedAt.toUtc().add(const Duration(seconds: 30)).toIso8601String(),
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
      'updated_at':
          stoppedAt.toUtc().add(const Duration(seconds: 30)).toIso8601String(),
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
    batchTripIds.add(tripId);
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
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) async {
    return <String, dynamic>{
      'trip_id': tripId,
      'session_id': sessionId ?? 'remote-session-1',
      'points_count': 0,
      'points': const <Map<String, dynamic>>[],
    };
  }

  @override
  Future<Map<String, dynamic>> confirmCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime confirmedAt,
  }) async {
    final forcedError = decisionError;
    if (forcedError != null) {
      throw forcedError;
    }
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
    final forcedError = decisionError;
    if (forcedError != null) {
      throw forcedError;
    }
    decisionCalls += 1;
    final createdAt = rejectedAt.subtract(const Duration(minutes: 10)).toUtc();
    final updatedAt = rejectedAt.toUtc();
    return <String, dynamic>{
      'candidate': <String, dynamic>{
        'id': candidateId,
        'trip_id': 'remote-trip-4',
        'user_id': 'user-1',
        'session_id': 'remote-session-1',
        'fingerprint': 'fp-updated',
        'status': 'rejected',
        'confidence': 0.91,
        'suggested_name': 'Lukla',
        'suggested_latitude': 27.6889,
        'suggested_longitude': 86.7314,
        'started_at': createdAt.toIso8601String(),
        'ended_at': updatedAt.toIso8601String(),
        'confirmed_trip_place_id': null,
        'rejected_reason': reason ?? 'not_a_match',
        'snoozed_until': null,
        'cooldown_until':
            updatedAt.add(const Duration(hours: 24)).toIso8601String(),
        'payload': <String, dynamic>{
          'source': 'worker',
          'score': 0.91,
        },
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      },
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
    final forcedError = decisionError;
    if (forcedError != null) {
      throw forcedError;
    }
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
    momentCreateTripIds.add(tripId);
    final createdAt = capturedAt.toUtc();
    final updatedAt = createdAt.add(const Duration(minutes: 1));
    return <String, dynamic>{
      'id': 'remote-moment-1',
      'trip_id': tripId,
      'user_id': 'user-1',
      'candidate_id': null,
      'linked_trip_place_id': linkedTripPlaceId,
      'source': 'manual',
      'confidence': null,
      'captured_at': capturedAt.toUtc().toIso8601String(),
      'latitude': location?['latitude'],
      'longitude': location?['longitude'],
      'note': note,
      'media_refs': mediaRefs ?? <Map<String, dynamic>>[],
      'extra_payload': extraPayload ?? <String, dynamic>{},
      'locked_fields': <String, dynamic>{},
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> updateMoment({
    required String momentId,
    required String idempotencyKey,
    required String clientEventId,
    DateTime? capturedAt,
    String? note,
    bool includeNote = false,
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    bool includeLinkedTripPlaceId = false,
    Map<String, dynamic>? extraPayload,
  }) async {
    momentCalls += 1;
    momentUpdateIds.add(momentId);
    momentUpdateIncludeNote.add(includeNote);
    momentUpdateIncludeLinkedTripPlaceId.add(includeLinkedTripPlaceId);
    final effectiveCapturedAt =
        capturedAt ?? DateTime.utc(2026, 3, 23, 10, 45, 00);
    final createdAt = effectiveCapturedAt.subtract(const Duration(minutes: 20));
    final updatedAt = effectiveCapturedAt.add(const Duration(minutes: 2));
    return <String, dynamic>{
      'id': momentId,
      'trip_id': 'remote-trip-5',
      'user_id': 'user-1',
      'candidate_id': 'candidate-local-2',
      'linked_trip_place_id': 'place-remote-1',
      'source': 'edited_auto',
      'confidence': 0.77,
      'captured_at': effectiveCapturedAt.toUtc().toIso8601String(),
      'latitude': 27.7172,
      'longitude': 85.3240,
      'note': 'server-updated-note',
      'media_refs': const <Map<String, dynamic>>[
        <String, dynamic>{'media_id': 'm-1', 'type': 'photo'},
      ],
      'extra_payload': <String, dynamic>{
        'weather': 'clear',
        'mood': 'excited',
      },
      'locked_fields': <String, dynamic>{
        'note': true,
        'location': true,
      },
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> registerDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String platform,
    required String pushToken,
    DateTime? seenAt,
    String? deviceId,
    String? appVersion,
    String? locale,
  }) async {
    final tokenHint = pushToken.length > 8
        ? pushToken.substring(pushToken.length - 8)
        : pushToken;
    return <String, dynamic>{
      'id': 'device-token-1',
      'platform': platform,
      'token_hint': tokenHint,
      'is_active': true,
      'last_seen_at': (seenAt ?? DateTime.now().toUtc()).toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> deactivateDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String pushToken,
    DateTime? deactivatedAt,
  }) async {
    final tokenHint = pushToken.length > 8
        ? pushToken.substring(pushToken.length - 8)
        : pushToken;
    return <String, dynamic>{
      'id': 'device-token-1',
      'token_hint': tokenHint,
      'is_active': false,
      'last_seen_at':
          (deactivatedAt ?? DateTime.now().toUtc()).toIso8601String(),
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

    Future<void> seedTripIdentity({
      required String localTripId,
      required String serverTripId,
    }) async {
      final now = DateTime.now().toUtc();
      await database.tripDao.insertTrip(
        TripsCompanion.insert(
          id: localTripId,
          serverTripId: Value(serverTripId),
          userId: 'user-1',
          name: 'Trip $localTripId',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
        ),
      );
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
      await seedTripIdentity(
        localTripId: 'trip-1',
        serverTripId: 'remote-trip-1',
      );
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
      expect(fakeApi.batchTripIds.single, 'remote-trip-1');
    });

    test('keeps point batch task pending when remote session id is missing',
        () async {
      final now = DateTime.now().toUtc();
      await seedTripIdentity(
        localTripId: 'trip-2',
        serverTripId: 'remote-trip-2',
      );
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

    test('keeps tracking session task pending until trip has remote identity',
        () async {
      final now = DateTime.now().toUtc();
      await database.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-no-remote',
          userId: 'user-1',
          name: 'Trip pending identity',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'pending',
          createdAt: now,
        ),
      );
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-no-remote-trip',
          tripId: 'trip-no-remote',
          clientSessionId: 'client-session-no-remote',
          state: const Value('planned'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-session-no-remote-trip',
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-no-remote-trip',
        operation: 'start',
      );

      await worker.startIfIdle();

      final task = await readTask('task-tracking-session-no-remote-trip');
      expect(task['status'], 'pending');
      expect(task['error_code'], 'tracking_trip_remote_id_missing');
      expect(task['depends_on_entity_type'], SyncEntityTypes.trip);
      expect(task['depends_on_entity_id'], 'trip-no-remote');
      expect(fakeApi.startCalls, 0);
    });

    test(
        'keeps tracking session syncStatus pending when task is requeued mid-flight',
        () async {
      final now = DateTime.now().toUtc();
      await seedTripIdentity(
        localTripId: 'trip-requeue-1',
        serverTripId: 'remote-trip-requeue-1',
      );
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

    test('hydrates tracking session snapshot fields from server', () async {
      final now = DateTime.utc(2026, 3, 23, 10, 30);
      await seedTripIdentity(
        localTripId: 'trip-4',
        serverTripId: 'remote-trip-4',
      );
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-local-4',
          tripId: 'trip-4',
          clientSessionId: 'client-session-4',
          state: const Value('planned'),
          timezone: const Value('Asia/Katmandu'),
          deviceContextJson: const Value('{"build":"local"}'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-session-4',
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-local-4',
        operation: 'start',
      );

      await worker.startIfIdle();

      final session = await sessionDao.getSessionById('session-local-4');
      expect(session, isNotNull);
      expect(session!.state, 'active');
      expect(session.remoteSessionId, 'remote-session-1');
      expect(session.clientSessionId, 'client-session-4');
      expect(session.timezone, 'Asia/Katmandu');
      expect(session.deviceContextJson, contains('"platform":"android"'));
      expect(session.lastPointAt, isNotNull);
      expect(
        session.serverUpdatedAt?.toUtc(),
        DateTime.utc(2026, 3, 23, 10, 30, 45),
      );
      expect(session.syncStatus, 'synced');
      expect(fakeApi.startTripIds.single, 'remote-trip-4');
    });

    test(
        'uses current row fallback for omitted session fields to avoid stale overwrite',
        () async {
      final now = DateTime.utc(2026, 3, 23, 11, 30);
      await seedTripIdentity(
        localTripId: 'trip-stale-fallback-1',
        serverTripId: 'remote-trip-stale-fallback-1',
      );
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-local-stale-fallback-1',
          tripId: 'trip-stale-fallback-1',
          remoteSessionId: const Value('remote-session-1'),
          clientSessionId: 'client-session-old',
          state: const Value('active'),
          timezone: const Value('Asia/Katmandu'),
          deviceContextJson: const Value('{"build":"old"}'),
          startedAt: Value(now.subtract(const Duration(minutes: 10))),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-tracking-session-stale-fallback-1',
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-local-stale-fallback-1',
        operation: 'pause',
      );

      fakeApi.pauseTrackingGate = Completer<void>();
      final runFuture = worker.startIfIdle();
      await waitForTaskStatus(
        taskId: 'task-tracking-session-stale-fallback-1',
        status: 'in_progress',
      );

      final midFlightTime = now.add(const Duration(minutes: 1));
      await (database.update(database.trackingSessions)
            ..where((t) => t.id.equals('session-local-stale-fallback-1')))
          .write(
        TrackingSessionsCompanion(
          clientSessionId: const Value('client-session-new'),
          timezone: const Value('UTC'),
          deviceContextJson:
              const Value('{"build":"new","source":"midflight"}'),
          localUpdatedAt: Value(midFlightTime),
          updatedAt: Value(midFlightTime),
        ),
      );

      fakeApi.pauseTrackingGate!.complete();
      await runFuture;

      final session =
          await sessionDao.getSessionById('session-local-stale-fallback-1');
      expect(session, isNotNull);
      expect(session!.state, 'paused');
      expect(session.clientSessionId, 'client-session-new');
      expect(session.timezone, 'UTC');
      expect(session.deviceContextJson, contains('"build":"new"'));
      expect(session.deviceContextJson, contains('"source":"midflight"'));
    });

    test('keeps non-tracking tasks unclaimed', () async {
      final now = DateTime.now().toUtc();
      await seedTripIdentity(
        localTripId: 'trip-3',
        serverTripId: 'remote-trip-3',
      );
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
      expect(fakeApi.batchTripIds.last, 'remote-trip-3');
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
      expect(candidate.fingerprint, 'fp-updated');
      expect(candidate.confidence, closeTo(0.91, 0.0001));
      expect(candidate.suggestedName, 'Lukla');
      expect(candidate.suggestedLatitude, closeTo(27.6889, 0.0001));
      expect(candidate.suggestedLongitude, closeTo(86.7314, 0.0001));
      expect(candidate.rejectedReason, 'not_a_match');
      expect(candidate.cooldownUntil, isNotNull);
      expect(candidate.tripId, 'trip-4');
      expect(candidate.sessionId, 'remote-session-1');
      expect(candidate.payloadJson, contains('"source":"worker"'));
      expect(candidate.actionState, 'synced');
      expect(candidate.syncStatus, 'synced');
      expect(candidate.serverUpdatedAt, isNotNull);
      expect(fakeApi.decisionCalls, 1);
    });

    test('marks candidate decision as failed when task is blocked', () async {
      final now = DateTime.now().toUtc();
      await candidateDao.upsertCandidate(
        TrackingCandidatesCompanion.insert(
          id: 'candidate-local-fail-1',
          tripId: 'trip-4',
          fingerprint: 'fp-fail-1',
          status: const Value('pending'),
          actionState: const Value('queued'),
          actionType: const Value('reject'),
          actionClientEventId: const Value('event-fail-1'),
          actionQueuedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-checkin-decision-fail-1',
        entityType: SyncEntityTypes.checkinDecision,
        entityId: 'candidate-local-fail-1',
        operation: 'reject',
      );
      fakeApi.decisionError = Exception('forced decision failure');

      await worker.startIfIdle();

      final task = await readTask('task-checkin-decision-fail-1');
      expect(task['status'], 'blocked');
      expect(task['error_code'], 'unknown_tracking_sync_failure');

      final candidate =
          await candidateDao.getCandidateById('candidate-local-fail-1');
      expect(candidate, isNotNull);
      expect(candidate!.actionState, 'failed');
      expect(candidate.syncStatus, 'pending');
    });

    test('hydrates moment snapshot fields from server response', () async {
      final now = DateTime.utc(2026, 3, 23, 11, 0);
      await seedTripIdentity(
        localTripId: 'trip-5',
        serverTripId: 'remote-trip-5',
      );
      await momentDao.upsertMoment(
        TrackingMomentsCompanion.insert(
          id: 'moment-local-1',
          tripId: 'trip-5',
          source: const Value('manual'),
          capturedAt: now,
          note: const Value('local-note'),
          mediaRefsJson: const Value('[]'),
          extraPayloadJson: const Value('{"origin":"local"}'),
          lockedFieldsJson: const Value('{}'),
          pendingOperation: const Value('update'),
          clientEventId: const Value('moment-event-1'),
          syncStatus: const Value('pending'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-moment-update-1',
        entityType: SyncEntityTypes.moment,
        entityId: 'moment-local-1',
        operation: 'update',
      );

      await worker.startIfIdle();

      final task = await readTask('task-moment-update-1');
      expect(task['status'], 'completed');
      final moment = await momentDao.getMomentById('moment-local-1');
      expect(moment, isNotNull);
      expect(moment!.source, 'edited_auto');
      expect(moment.confidence, closeTo(0.77, 0.0001));
      expect(moment.tripId, 'trip-5');
      expect(moment.candidateId, 'candidate-local-2');
      expect(moment.linkedTripPlaceId, 'place-remote-1');
      expect(moment.note, 'server-updated-note');
      expect(moment.latitude, closeTo(27.7172, 0.0001));
      expect(moment.longitude, closeTo(85.324, 0.0001));
      expect(moment.mediaRefsJson, contains('"media_id":"m-1"'));
      expect(moment.extraPayloadJson, contains('"weather":"clear"'));
      expect(moment.lockedFieldsJson, contains('"location":true'));
      expect(moment.pendingOperation, isNull);
      expect(moment.syncStatus, 'synced');
      expect(moment.serverUpdatedAt, isNotNull);
      expect(fakeApi.momentCalls, 1);
      expect(fakeApi.momentUpdateIncludeNote.single, isFalse);
      expect(fakeApi.momentUpdateIncludeLinkedTripPlaceId.single, isFalse);
    });

    test('sends explicit include flags for moment clear operations', () async {
      final now = DateTime.utc(2026, 3, 23, 11, 30);
      await seedTripIdentity(
        localTripId: 'trip-6',
        serverTripId: 'remote-trip-6',
      );
      await momentDao.upsertMoment(
        TrackingMomentsCompanion.insert(
          id: 'moment-local-clear-1',
          tripId: 'trip-6',
          source: const Value('manual'),
          capturedAt: now,
          note: const Value(null),
          linkedTripPlaceId: const Value(null),
          mediaRefsJson: const Value('[]'),
          extraPayloadJson: const Value('{}'),
          lockedFieldsJson: const Value(
            '{"__patch_include_note":true,"__patch_include_linked_trip_place_id":true}',
          ),
          pendingOperation: const Value('update'),
          clientEventId: const Value('moment-event-clear-1'),
          syncStatus: const Value('pending'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-moment-clear-1',
        entityType: SyncEntityTypes.moment,
        entityId: 'moment-local-clear-1',
        operation: 'update',
      );

      await worker.startIfIdle();

      final task = await readTask('task-moment-clear-1');
      expect(task['status'], 'completed');
      expect(fakeApi.momentUpdateIds.last, 'moment-local-clear-1');
      expect(fakeApi.momentUpdateIncludeNote.last, isTrue);
      expect(fakeApi.momentUpdateIncludeLinkedTripPlaceId.last, isTrue);
    });

    test(
        'requeues identity-blocked tracking tasks after tracking-session sync success',
        () async {
      final now = DateTime.utc(2026, 3, 23, 12, 0);
      await seedTripIdentity(
        localTripId: 'trip-recovery-1',
        serverTripId: 'remote-trip-recovery-1',
      );
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-recovery-1',
          tripId: 'trip-recovery-1',
          clientSessionId: 'client-session-recovery-1',
          state: const Value('planned'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await momentDao.upsertMoment(
        TrackingMomentsCompanion.insert(
          id: 'moment-recovery-1',
          tripId: 'trip-recovery-1',
          source: const Value('manual'),
          capturedAt: now,
          note: const Value('recover me'),
          pendingOperation: const Value('update'),
          clientEventId: const Value('moment-event-recovery-1'),
          syncStatus: const Value('pending'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-moment-recovery-1',
        entityType: SyncEntityTypes.moment,
        entityId: 'moment-recovery-1',
        operation: 'update',
      );
      await syncTaskDao.markBlocked(
        taskId: 'task-moment-recovery-1',
        errorCode: 'http_404',
        errorMessage: 'trip identity mismatch',
      );
      await syncTaskDao.upsertQueuedTask(
        id: 'task-session-recovery-1',
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-recovery-1',
        operation: 'start',
      );

      await worker.startIfIdle();

      final momentTask = await readTask('task-moment-recovery-1');
      expect(momentTask['status'], 'completed');
      expect(momentTask['error_code'], isNull);
    });

    test('recovers stale trip identity on 404 trip-not-found', () async {
      final now = DateTime.now().toUtc();
      const localTripId = 'trip-stale-404-1';
      const staleRemoteTripId = 'remote-trip-stale-404-1';
      const taskId = 'task-session-stale-404-1';
      await seedTripIdentity(
        localTripId: localTripId,
        serverTripId: staleRemoteTripId,
      );
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-stale-404-1',
          tripId: localTripId,
          clientSessionId: 'client-session-stale-404-1',
          state: const Value('planned'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );
      await syncTaskDao.upsertQueuedTask(
        id: taskId,
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-stale-404-1',
        operation: 'start',
      );

      final requestOptions = RequestOptions(
          path: '/api/v1/trips/$staleRemoteTripId/tracking/start');
      fakeApi.startError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 404,
          data: <String, dynamic>{'detail': 'Trip not found'},
        ),
      );

      await worker.startIfIdle();

      final task = await readTask(taskId);
      expect(task['status'], 'pending');
      expect(task['error_code'], 'tracking_trip_identity_stale');
      expect(task['depends_on_entity_type'], SyncEntityTypes.trip);
      expect(task['depends_on_entity_id'], localTripId);

      final trip = await database.tripDao.getTripById(localTripId);
      expect(trip, isNotNull);
      expect(trip!.serverTripId, isNull);
      expect(trip.syncStatus, 'pending');

      final tripTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trip,
        entityId: localTripId,
      );
      expect(tripTask, isNotNull);
      expect(tripTask!.operation, 'create');
      expect(tripTask.status, 'queued');
    });
  });
}
