import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/network/live_tracking_api.dart';
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

class _FakeLiveTrackingApi implements LiveTrackingApi {
  @override
  Future<Map<String, dynamic>> startTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    return <String, dynamic>{
      'session_id': 'remote-$tripId',
      'trip_id': tripId,
      'state': 'active',
      'client_session_id': clientSessionId,
      'started_at': startedAt.toUtc().toIso8601String(),
      'paused_at': null,
      'resumed_at': null,
      'ended_at': null,
      'abandoned_at': null,
      'last_point_at': null,
      'timezone': timezone,
      'device_context': deviceContext ?? const <String, dynamic>{},
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
    return <String, dynamic>{
      'session_id': sessionId ?? 'remote-$tripId',
      'trip_id': tripId,
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
      'session_id': sessionId ?? 'remote-$tripId',
      'trip_id': tripId,
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
      'session_id': sessionId ?? 'remote-$tripId',
      'trip_id': tripId,
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadEventsBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> events,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> confirmCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime confirmedAt,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rejectCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime rejectedAt,
    String? reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> snoozeCheckin({
    required String candidateId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime snoozedUntil,
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
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
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> deactivateDeviceToken({
    required String idempotencyKey,
    required String clientEventId,
    required String pushToken,
    DateTime? deactivatedAt,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('LiveTrackingRuntimeRepository', () {
    late AppDatabase database;
    late SyncTaskDao syncTaskDao;
    late TrackingSessionDao sessionDao;
    late TrackingPointBatchDao batchDao;
    late _FakeClock clock;
    late _FakeLiveTrackingApi liveTrackingApi;
    late LiveTrackingRuntimeRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      syncTaskDao = SyncTaskDao(database);
      sessionDao = TrackingSessionDao(database);
      batchDao = TrackingPointBatchDao(database);
      clock = _FakeClock(DateTime.utc(2026, 3, 23, 12, 0));
      liveTrackingApi = _FakeLiveTrackingApi();
      repository = LiveTrackingRuntimeRepository(
        database,
        syncTaskDao: syncTaskDao,
        trackingSessionDao: sessionDao,
        trackingPointBatchDao: batchDao,
        liveTrackingApi: liveTrackingApi,
        resolveRemoteTripId: (localTripId) async => 'remote-trip-$localTripId',
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
      expect(session.syncStatus, 'synced');
      expect(session.timezone, 'UTC');
      expect(session.deviceContextJson, contains('"platform":"android"'));
      expect(session.remoteSessionId, 'remote-remote-trip-trip-1');

      final sessionTask = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: session.id,
      );
      expect(sessionTask, isNull);

      final repeated = await repository.startSession(
        tripId: 'trip-1',
      );
      expect(repeated.id, session.id);

      final sessions = await sessionDao.getSessionsForTrip('trip-1');
      expect(sessions.length, 1);
    });

    test('start session hydrates existing active session missing remote id',
        () async {
      final now = clock.now.toUtc();
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-existing-1',
          tripId: 'trip-1',
          clientSessionId: 'client-session-existing-1',
          state: const Value('active'),
          startedAt: Value(now),
          syncStatus: const Value('pending'),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
          serverUpdatedAt: const Value(null),
        ),
      );

      final existing = await repository.startSession(tripId: 'trip-1');
      expect(existing.id, 'session-existing-1');

      final task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: 'session-existing-1',
      );
      expect(task, isNull);
      final refreshed = await sessionDao.getSessionById('session-existing-1');
      expect(refreshed, isNotNull);
      expect(refreshed!.remoteSessionId, 'remote-remote-trip-trip-1');
      expect(refreshed.syncStatus, 'synced');
    });

    test(
        'session lifecycle transitions pause -> resume -> stop are write-through',
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
      expect(task, isNull);

      clock.advance(const Duration(seconds: 10));
      final resumed = await repository.resumeSession(tripId: 'trip-2');
      expect(resumed, isNotNull);
      expect(resumed!.state, 'active');
      expect(resumed.resumedAt, isNotNull);
      task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: started.id,
      );
      expect(task, isNull);

      clock.advance(const Duration(seconds: 10));
      final stopped = await repository.stopSession(tripId: 'trip-2');
      expect(stopped, isNotNull);
      expect(stopped!.state, 'ended');
      expect(stopped.endedAt, isNotNull);
      task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.trackingSession,
        entityId: started.id,
      );
      expect(task, isNull);

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
