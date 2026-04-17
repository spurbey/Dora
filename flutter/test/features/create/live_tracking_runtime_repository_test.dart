import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';

class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration duration) {
    now = now.add(duration);
  }
}

class _FakeLiveTrackingApi implements LiveTrackingApi {
  DioException? startTrackingError;

  @override
  Future<Map<String, dynamic>> startTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    final error = startTrackingError;
    if (error != null) {
      throw error;
    }
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
  Future<Map<String, dynamic>> startTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required DateTime startedAt,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> stopTrackingV2({
    required String tripId,
    required String idempotencyKey,
    required String clientSessionId,
    required int sealVersion,
    required String stopClientEventId,
    required DateTime stoppedAt,
    String? reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> publishStartV2({
    required String tripId,
    required String idempotencyKey,
    required String clientJobId,
    required int schemaVersion,
    required Map<String, dynamic> publishSummary,
    required List<Map<String, dynamic>> mediaManifest,
    required String mediaManifestDigest,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> publishMediaCompleteV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required List<Map<String, dynamic>> uploadedMedia,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> publishPayloadChunkV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
    required int chunkIndex,
    required int totalChunks,
    required String chunkContentHash,
    required String chunkJson,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> publishCommitV2({
    required String tripId,
    required String idempotencyKey,
    required String publishToken,
    required String clientJobId,
    required int schemaVersion,
  }) {
    throw UnimplementedError();
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
  Future<Map<String, dynamic>> uploadTrackingMediaBinary({
    required String tripId,
    required String filePath,
    String? fileName,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> uploadMediaBatch({
    required String tripId,
    required String idempotencyKey,
    required List<Map<String, dynamic>> media,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> fetchCompiledProjection({
    required String tripId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rebindCompiledProjection({
    required String tripId,
    required String sourceEventId,
    required String action,
    String? tripPlaceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
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
    late TrackingSessionDao sessionDao;
    late TrackingPointBatchDao batchDao;
    late _FakeClock clock;
    late _FakeLiveTrackingApi liveTrackingApi;
    late LiveTrackingRuntimeRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionDao = TrackingSessionDao(database);
      batchDao = TrackingPointBatchDao(database);
      clock = _FakeClock(DateTime.utc(2026, 3, 23, 12, 0));
      liveTrackingApi = _FakeLiveTrackingApi();
      repository = LiveTrackingRuntimeRepository(
        database,
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

      final repeated = await repository.startSession(
        tripId: 'trip-1',
      );
      expect(repeated.id, session.id);

      final sessions = await sessionDao.getSessionsForTrip('trip-1');
      expect(sessions.length, 1);
    });

    test('start session fails fast when remote trip identity is missing',
        () async {
      final failingRepository = LiveTrackingRuntimeRepository(
        database,
        trackingSessionDao: sessionDao,
        trackingPointBatchDao: batchDao,
        liveTrackingApi: liveTrackingApi,
        resolveRemoteTripId: (localTripId) async {
          throw const TripIdentityException(
            'Trip must be synced before tracking start.',
            retryable: true,
          );
        },
        now: clock.call,
      );

      await expectLater(
        () => failingRepository.startSession(tripId: 'trip-missing-identity'),
        throwsA(
          isA<LiveTrackingCommandException>()
              .having((e) => e.code, 'code', 'tracking_trip_identity_missing'),
        ),
      );
    });

    test('start session repairs stale trip identity on command 404', () async {
      final now = clock.now.toUtc();
      await database.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-404',
          serverTripId: const Value('remote-trip-trip-404'),
          userId: 'user-404',
          name: 'Trip 404',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
        ),
      );

      var clearCalled = false;
      String? clearLocalTripId;
      String? clearExpectedRemoteTripId;

      final requestOptions = RequestOptions(path: '/tracking/start');
      liveTrackingApi.startTrackingError = DioException(
        requestOptions: requestOptions,
        response: Response<Map<String, dynamic>>(
          requestOptions: requestOptions,
          statusCode: 404,
          data: const <String, dynamic>{'detail': 'Trip not found'},
        ),
        type: DioExceptionType.badResponse,
      );

      final staleRepository = LiveTrackingRuntimeRepository(
        database,
        trackingSessionDao: sessionDao,
        trackingPointBatchDao: batchDao,
        liveTrackingApi: liveTrackingApi,
        resolveRemoteTripId: (localTripId) async => 'remote-trip-trip-404',
        clearRemoteTripId: (localTripId, {expectedServerTripId}) async {
          clearCalled = true;
          clearLocalTripId = localTripId;
          clearExpectedRemoteTripId = expectedServerTripId;
        },
        now: clock.call,
      );

      await expectLater(
        () => staleRepository.startSession(tripId: 'trip-404'),
        throwsA(
          isA<LiveTrackingCommandException>()
              .having((e) => e.code, 'code', 'tracking_trip_identity_stale'),
        ),
      );

      expect(clearCalled, isTrue);
      expect(clearLocalTripId, 'trip-404');
      expect(clearExpectedRemoteTripId, 'remote-trip-trip-404');
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

      clock.advance(const Duration(seconds: 10));
      final resumed = await repository.resumeSession(tripId: 'trip-2');
      expect(resumed, isNotNull);
      expect(resumed!.state, 'active');
      expect(resumed.resumedAt, isNotNull);

      clock.advance(const Duration(seconds: 10));
      final stopped = await repository.stopSession(tripId: 'trip-2');
      expect(stopped, isNotNull);
      expect(stopped!.state, 'ended');
      expect(stopped.endedAt, isNotNull);

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
