import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';

class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

void main() {
  group('LiveTrackingRuntimeRepository', () {
    late AppDatabase database;
    late SyncTaskDao syncTaskDao;
    late TrackingSessionDao sessionDao;
    late TrackingPointBatchDao batchDao;
    late _FakeClock clock;
    late LiveTrackingRuntimeRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      syncTaskDao = SyncTaskDao(database);
      sessionDao = TrackingSessionDao(database);
      batchDao = TrackingPointBatchDao(database);
      clock = _FakeClock(DateTime.utc(2026, 3, 23, 12, 0));
      repository = LiveTrackingRuntimeRepository(
        database,
        syncTaskDao: syncTaskDao,
        trackingSessionDao: sessionDao,
        trackingPointBatchDao: batchDao,
        now: clock.call,
        policy: const LiveTrackingBatchingPolicy(
          maxPointsPerBatch: 3,
          maxBatchWindow: Duration(minutes: 1),
          minPointCadence: Duration(seconds: 5),
          minDistanceMeters: 10,
        ),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('start session is idempotent for active/paused local session',
        () async {
      final session = await repository.startSession(
        tripId: 'trip-1',
        timezone: 'UTC',
        deviceContext: const <String, dynamic>{'platform': 'android'},
      );
      expect(session.state, 'active');
      expect(session.syncStatus, 'pending');
      expect(session.timezone, 'UTC');
      expect(session.deviceContextJson, contains('"platform":"android"'));

      final sessionTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: session.id,
      );
      expect(sessionTask, isNotNull);
      expect(sessionTask!.operation, 'start');
      expect(sessionTask.status, 'queued');

      final repeated = await repository.startSession(
        tripId: 'trip-1',
      );
      expect(repeated.id, session.id);

      final sessions = await sessionDao.getSessionsForTrip('trip-1');
      expect(sessions.length, 1);
    });

    test('session lifecycle transitions pause -> resume -> stop are queued',
        () async {
      final started = await repository.startSession(tripId: 'trip-2');
      clock.advance(const Duration(seconds: 15));

      final paused = await repository.pauseSession(tripId: 'trip-2');
      expect(paused, isNotNull);
      expect(paused!.state, 'paused');
      expect(paused.pausedAt, isNotNull);
      var task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: started.id,
      );
      expect(task, isNotNull);
      expect(task!.operation, 'pause');

      clock.advance(const Duration(seconds: 10));
      final resumed = await repository.resumeSession(tripId: 'trip-2');
      expect(resumed, isNotNull);
      expect(resumed!.state, 'active');
      expect(resumed.resumedAt, isNotNull);
      task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: started.id,
      );
      expect(task, isNotNull);
      expect(task!.operation, 'resume');

      clock.advance(const Duration(seconds: 10));
      final stopped = await repository.stopSession(tripId: 'trip-2');
      expect(stopped, isNotNull);
      expect(stopped!.state, 'ended');
      expect(stopped.endedAt, isNotNull);
      task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: started.id,
      );
      expect(task, isNotNull);
      expect(task!.operation, 'stop');

      final snapshot = await repository.getRuntimeSnapshot('trip-2');
      expect(snapshot.state, LiveTrackingRuntimeState.ended);
      expect(snapshot.sessionId, started.id);
    });

    test('ingestPoint batches payloads and suppresses near-duplicate samples',
        () async {
      final session = await repository.startSession(tripId: 'trip-3');

      final acceptedFirst = await repository.ingestPoint(
        tripId: 'trip-3',
        sessionId: session.id,
        point: TrackingPointSample(
          recordedAt: clock.now,
          latitude: 27.7172,
          longitude: 85.3240,
          accuracyMeters: 5.0,
        ),
      );
      expect(acceptedFirst, isTrue);

      var batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 1);
      expect(batches.first.pointCount, 1);
      final firstBatchTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingPointBatch,
        entityId: batches.first.id,
      );
      expect(firstBatchTask, isNotNull);
      expect(firstBatchTask!.operation, 'upload');
      expect(
          firstBatchTask.dependsOnEntityType, SyncEntityTypes.trackingSession);
      expect(firstBatchTask.dependsOnEntityId, session.id);

      clock.advance(const Duration(seconds: 2));
      final droppedNearDuplicate = await repository.ingestPoint(
        tripId: 'trip-3',
        sessionId: session.id,
        point: TrackingPointSample(
          recordedAt: clock.now,
          latitude: 27.7172001,
          longitude: 85.3240001,
        ),
      );
      expect(droppedNearDuplicate, isFalse);

      batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 1);
      expect(batches.first.pointCount, 1);

      clock.advance(const Duration(seconds: 6));
      final acceptedSecond = await repository.ingestPoint(
        tripId: 'trip-3',
        sessionId: session.id,
        point: TrackingPointSample(
          recordedAt: clock.now,
          latitude: 27.7180,
          longitude: 85.3250,
        ),
      );
      expect(acceptedSecond, isTrue);

      clock.advance(const Duration(seconds: 6));
      await repository.ingestPoint(
        tripId: 'trip-3',
        sessionId: session.id,
        point: TrackingPointSample(
          recordedAt: clock.now,
          latitude: 27.7190,
          longitude: 85.3260,
        ),
      );

      batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 1);
      expect(batches.first.pointCount, 3);
      final firstBatchPoints =
          (jsonDecode(batches.first.pointsJson) as List<dynamic>).length;
      expect(firstBatchPoints, 3);

      clock.advance(const Duration(seconds: 6));
      final acceptedFourth = await repository.ingestPoint(
        tripId: 'trip-3',
        sessionId: session.id,
        point: TrackingPointSample(
          recordedAt: clock.now,
          latitude: 27.7200,
          longitude: 85.3270,
        ),
      );
      expect(acceptedFourth, isTrue);

      batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 2);
      expect(batches.first.pointCount, 3);
      expect(batches.last.pointCount, 1);

      final updatedSession = await sessionDao.getSessionById(session.id);
      expect(updatedSession, isNotNull);
      expect(updatedSession!.lastPointAt?.toUtc(), clock.now.toUtc());
    });
  });
}
