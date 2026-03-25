import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_capture_coordinator.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';

class _FakeClock {
  _FakeClock(this.current);

  DateTime current;

  DateTime now() => current;

  void advance(Duration value) {
    current = current.add(value);
  }
}

void main() {
  group('LiveTrackingCaptureCoordinator', () {
    late AppDatabase database;
    late TrackingSessionDao sessionDao;
    late TrackingPointBatchDao batchDao;
    late SyncTaskDao syncTaskDao;
    late _FakeClock clock;
    late LiveTrackingRuntimeRepository repository;
    late StreamController<TrackingPointSample> pointController;
    late LocationAccessState permissionState;
    late bool lastPermissionRequested;
    late int streamFactoryCalls;
    late LiveTrackingCaptureCoordinator coordinator;

    Future<void> waitForCondition({
      required Future<bool> Function() predicate,
      int attempts = 40,
    }) async {
      for (var i = 0; i < attempts; i += 1) {
        if (await predicate()) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      fail('Timed out waiting for condition');
    }

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      sessionDao = TrackingSessionDao(database);
      batchDao = TrackingPointBatchDao(database);
      syncTaskDao = SyncTaskDao(database);
      clock = _FakeClock(DateTime.utc(2026, 3, 24, 9, 0, 0));
      repository = LiveTrackingRuntimeRepository(
        database,
        trackingSessionDao: sessionDao,
        trackingPointBatchDao: batchDao,
        syncTaskDao: syncTaskDao,
        now: clock.now,
      );
      permissionState = LocationAccessState.granted;
      lastPermissionRequested = false;
      streamFactoryCalls = 0;
      pointController = StreamController<TrackingPointSample>.broadcast();
      coordinator = LiveTrackingCaptureCoordinator(
        repository: repository,
        trackingSessionDao: sessionDao,
        ensureLocationAccess: ({required bool requestIfDenied}) async {
          lastPermissionRequested = requestIfDenied;
          return permissionState;
        },
        pointStreamFactory: () {
          streamFactoryCalls += 1;
          return pointController.stream;
        },
      );
    });

    tearDown(() async {
      await coordinator.dispose();
      await pointController.close();
      await database.close();
    });

    test('startTracking begins capture and ingests points', () async {
      final session = await coordinator.startTracking(
        tripId: 'trip-capture-1',
        timezone: 'UTC',
      );
      expect(lastPermissionRequested, isTrue);
      expect(streamFactoryCalls, 1);
      expect(coordinator.isCapturing, isTrue);

      pointController.add(
        TrackingPointSample(
          recordedAt: clock.current,
          latitude: 27.7172,
          longitude: 85.3240,
          accuracyMeters: 4,
        ),
      );

      await waitForCondition(
        predicate: () async {
          final rows = await batchDao.getBatchesForSession(session.id);
          return rows.isNotEmpty;
        },
      );

      final batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 1);
      expect(batches.first.pointCount, 1);
    });

    test('serializes burst points without dropping samples', () async {
      final session = await coordinator.startTracking(tripId: 'trip-burst-1');

      for (var i = 0; i < 6; i += 1) {
        pointController.add(
          TrackingPointSample(
            recordedAt: clock.current.add(Duration(seconds: i * 6)),
            latitude: 27.7000 + (i / 1000),
            longitude: 85.3000 + (i / 1000),
          ),
        );
      }

      await waitForCondition(
        attempts: 80,
        predicate: () async {
          final batches = await batchDao.getBatchesForSession(session.id);
          final totalCount =
              batches.fold<int>(0, (sum, batch) => sum + batch.pointCount);
          return totalCount == 6;
        },
      );

      final batches = await batchDao.getBatchesForSession(session.id);
      final totalCount =
          batches.fold<int>(0, (sum, batch) => sum + batch.pointCount);
      expect(totalCount, 6);
    });

    test('pauseTracking stops ingestion for paused session', () async {
      final session = await coordinator.startTracking(tripId: 'trip-capture-2');
      pointController.add(
        TrackingPointSample(
          recordedAt: clock.current,
          latitude: 27.7100,
          longitude: 85.3100,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
      var batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 1);
      expect(batches.first.pointCount, 1);

      await coordinator.pauseTracking(tripId: 'trip-capture-2');
      expect(coordinator.isCapturing, isFalse);

      clock.advance(const Duration(seconds: 10));
      pointController.add(
        TrackingPointSample(
          recordedAt: clock.current,
          latitude: 27.7105,
          longitude: 85.3105,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      batches = await batchDao.getBatchesForSession(session.id);
      expect(batches.length, 1);
      expect(batches.first.pointCount, 1);
    });

    test('reuses one point stream for multiple active sessions', () async {
      final first = await coordinator.startTracking(tripId: 'trip-multi-1');
      final second = await coordinator.startTracking(tripId: 'trip-multi-2');
      expect(streamFactoryCalls, 1);

      pointController.add(
        TrackingPointSample(
          recordedAt: clock.current,
          latitude: 27.9000,
          longitude: 85.5000,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));

      final firstBatches = await batchDao.getBatchesForSession(first.id);
      final secondBatches = await batchDao.getBatchesForSession(second.id);
      expect(firstBatches.length, 1);
      expect(secondBatches.length, 1);
      expect(firstBatches.first.pointCount, 1);
      expect(secondBatches.first.pointCount, 1);
    });

    test('recoverActiveSessions restores capture without permission prompt',
        () async {
      final now = clock.current;
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-recover-1',
          tripId: 'trip-recover-1',
          clientSessionId: 'client-session-recover-1',
          state: const Value('active'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final recoveredCount = await coordinator.recoverActiveSessions();
      expect(recoveredCount, 1);
      expect(lastPermissionRequested, isFalse);
      expect(streamFactoryCalls, 1);
      expect(coordinator.isCapturing, isTrue);

      pointController.add(
        TrackingPointSample(
          recordedAt: now.add(const Duration(seconds: 3)),
          latitude: 27.8000,
          longitude: 85.4000,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final batches = await batchDao.getBatchesForSession('session-recover-1');
      expect(batches.length, 1);
      expect(batches.first.pointCount, 1);
    });

    test('recoverActiveSessions skips capture when access is denied', () async {
      final now = clock.current;
      await sessionDao.upsertSession(
        TrackingSessionsCompanion.insert(
          id: 'session-recover-2',
          tripId: 'trip-recover-2',
          clientSessionId: 'client-session-recover-2',
          state: const Value('active'),
          startedAt: Value(now),
          localUpdatedAt: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      permissionState = LocationAccessState.denied;
      final recoveredCount = await coordinator.recoverActiveSessions();
      expect(recoveredCount, 0);
      expect(lastPermissionRequested, isFalse);
      expect(streamFactoryCalls, 0);
      expect(coordinator.isCapturing, isFalse);
    });

    test('startTracking throws explicit exception when permission denied',
        () async {
      permissionState = LocationAccessState.deniedForever;
      expect(
        () => coordinator.startTracking(tripId: 'trip-capture-3'),
        throwsA(
          isA<LiveTrackingCaptureException>().having(
            (e) => e.code,
            'code',
            'location_permission_denied_forever',
          ),
        ),
      );
      expect(streamFactoryCalls, 0);
    });

    test('restarts capture stream with bounded backoff after failures',
        () async {
      await coordinator.dispose();
      streamFactoryCalls = 0;
      coordinator = LiveTrackingCaptureCoordinator(
        repository: repository,
        trackingSessionDao: sessionDao,
        ensureLocationAccess: ({required bool requestIfDenied}) async {
          lastPermissionRequested = requestIfDenied;
          return permissionState;
        },
        pointStreamFactory: () {
          streamFactoryCalls += 1;
          return Stream<TrackingPointSample>.error(StateError('stream failed'));
        },
        restartInitialDelay: const Duration(milliseconds: 100),
        restartMaxDelay: const Duration(milliseconds: 200),
      );

      await coordinator.startTracking(tripId: 'trip-backoff-1');
      expect(streamFactoryCalls, 1);

      await Future<void>.delayed(const Duration(milliseconds: 70));
      expect(streamFactoryCalls, 1);

      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(streamFactoryCalls, greaterThanOrEqualTo(2));

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(streamFactoryCalls, inInclusiveRange(2, 3));

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(streamFactoryCalls, greaterThanOrEqualTo(3));
    });
  });
}
