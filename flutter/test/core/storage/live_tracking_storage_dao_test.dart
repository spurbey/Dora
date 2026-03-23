import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

void main() {
  group('LiveTrackingStorageDaos', () {
    late AppDatabase database;
    late TrackingSessionDao sessionDao;
    late TrackingPointBatchDao batchDao;
    late TrackingCandidateDao candidateDao;
    late TrackingMomentDao momentDao;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      sessionDao = TrackingSessionDao(database);
      batchDao = TrackingPointBatchDao(database);
      candidateDao = TrackingCandidateDao(database);
      momentDao = TrackingMomentDao(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('session dao upserts and resolves active session for trip', () async {
      final now = DateTime.now();
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-1',
          tripId: 'trip-1',
          clientSessionId: 'client-session-1',
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );

      await sessionDao.updateLifecycle(
        sessionId: 'session-1',
        state: 'active',
        startedAt: now,
        lastPointAt: now,
      );

      final active = await sessionDao.getActiveOrPausedSessionForTrip('trip-1');
      expect(active, isNotNull);
      expect(active!.id, 'session-1');
      expect(active.state, 'active');
      expect(active.syncStatus, 'pending');
    });

    test('point batch dao claims queued work and transitions statuses',
        () async {
      final now = DateTime.now();
      await batchDao.upsertBatch(
        TrackingPointBatchesCompanion.insert(
          id: 'batch-1',
          tripId: 'trip-1',
          sessionId: 'session-1',
          clientBatchId: 'client-batch-1',
          pointCount: const Value(3),
          pointsJson: const Value('[{"p":1},{"p":2},{"p":3}]'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );

      final claimed = await batchDao.claimPendingBatches(
        workerSessionId: 'worker-batch',
        now: now.add(const Duration(seconds: 1)),
        limit: 5,
      );
      expect(claimed.length, 1);
      expect(claimed.first.id, 'batch-1');
      expect(claimed.first.status, 'in_progress');

      final released = await batchDao.clearWorkerSession(
        batchId: 'batch-1',
        expectedSessionId: 'worker-batch',
      );
      expect(released, 1);

      final reclaimed = await batchDao.claimPendingBatches(
        workerSessionId: 'worker-batch-2',
        now: now.add(const Duration(seconds: 2)),
        limit: 5,
      );
      expect(reclaimed.length, 1);
      expect(reclaimed.first.id, 'batch-1');
      expect(reclaimed.first.status, 'in_progress');

      await batchDao.markFailed(
        batchId: 'batch-1',
        errorMessage: 'network_timeout',
        retryCount: 1,
        nextAttemptAt: now.add(const Duration(seconds: 30)),
      );
      final failed = await batchDao.getBatchById('batch-1');
      expect(failed, isNotNull);
      expect(failed!.status, 'failed');
      expect(failed.retryCount, 1);

      await batchDao.markCompleted(batchId: 'batch-1');
      final completed = await batchDao.getBatchById('batch-1');
      expect(completed, isNotNull);
      expect(completed!.status, 'completed');
      expect(completed.syncStatus, 'synced');
      expect(completed.workerSessionId, isNull);
    });

    test('candidate dao tracks queued and synced decision states', () async {
      final now = DateTime.now();
      await candidateDao.upsertCandidate(
        TrackingCandidatesCompanion.insert(
          id: 'candidate-1',
          tripId: 'trip-1',
          fingerprint: 'fingerprint-1',
          status: const Value('pending'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );

      await candidateDao.markDecisionQueued(
        candidateId: 'candidate-1',
        actionType: 'reject',
        clientEventId: 'event-1',
        queuedAt: now.add(const Duration(seconds: 2)),
      );
      final queued = await candidateDao.getCandidateById('candidate-1');
      expect(queued, isNotNull);
      expect(queued!.actionState, 'queued');
      expect(queued.actionType, 'reject');
      expect(queued.syncStatus, 'pending');

      await candidateDao.markDecisionSynced(
        candidateId: 'candidate-1',
        status: 'rejected',
      );
      final synced = await candidateDao.getCandidateById('candidate-1');
      expect(synced, isNotNull);
      expect(synced!.status, 'rejected');
      expect(synced.actionState, 'synced');
      expect(synced.syncStatus, 'synced');
    });

    test('moment dao tracks pending write and synced transitions', () async {
      final now = DateTime.now();
      await momentDao.upsertMoment(
        TrackingMomentsCompanion.insert(
          id: 'moment-1',
          tripId: 'trip-1',
          capturedAt: now,
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );

      await momentDao.markPendingWrite(
        momentId: 'moment-1',
        operation: 'update',
        clientEventId: 'event-2',
      );
      final pending = await momentDao.getMomentById('moment-1');
      expect(pending, isNotNull);
      expect(pending!.pendingOperation, 'update');
      expect(pending.syncStatus, 'pending');

      await momentDao.markSynced(momentId: 'moment-1');
      final synced = await momentDao.getMomentById('moment-1');
      expect(synced, isNotNull);
      expect(synced!.pendingOperation, isNull);
      expect(synced.syncStatus, 'synced');
      expect(synced.serverUpdatedAt, isNotNull);
    });

    test('tracking tables expose expected secondary indexes', () async {
      final rows = await database.customSelect(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'index'
          AND name LIKE 'tracking_%'
        ORDER BY name
        ''',
      ).get();

      final names = rows.map((row) => row.read<String>('name')).toSet();
      expect(names, contains('tracking_sessions_trip_state_updated_idx'));
      expect(names, contains('tracking_sessions_trip_updated_idx'));
      expect(names, contains('tracking_point_batches_claim_idx'));
      expect(names, contains('tracking_point_batches_trip_created_idx'));
      expect(names, contains('tracking_point_batches_session_created_idx'));
      expect(names, contains('tracking_candidates_trip_created_idx'));
      expect(names, contains('tracking_candidates_trip_status_updated_idx'));
      expect(names, contains('tracking_candidates_action_queue_idx'));
      expect(names, contains('tracking_moments_trip_captured_idx'));
      expect(names, contains('tracking_moments_sync_pending_idx'));
    });
  });
}
