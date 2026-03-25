import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';

void main() {
  group('liveTrackingMapOverlayProvider', () {
    test('updates overlay from runtime and batch stream changes', () async {
      final runtimeController =
          StreamController<LiveTrackingRuntimeSnapshot>.broadcast();
      final batchesController =
          StreamController<List<TrackingPointBatchRow>>.broadcast();

      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-1').overrideWith(
            (ref) => runtimeController.stream,
          ),
          liveTrackingSessionBatchesProvider('session-1').overrideWith(
            (ref) => batchesController.stream,
          ),
          liveTrackingRemotePathPointsProvider('trip-1').overrideWith(
            (ref) => Stream<List<AppLatLng>>.value(const <AppLatLng>[]),
          ),
        ],
      );
      addTearDown(() async {
        await runtimeController.close();
        await batchesController.close();
        container.dispose();
      });

      final updates = <LiveTrackingMapOverlay>[];
      final subscription = container.listen<LiveTrackingMapOverlay>(
        liveTrackingMapOverlayProvider('trip-1'),
        (_, next) => updates.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      runtimeController.add(
        const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-1',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-1',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      batchesController.add(
        <TrackingPointBatchRow>[
          _batch(
            id: 'batch-1',
            sessionId: 'session-1',
            points: const <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 12.0, 'longitude': 77.0},
            ],
          ),
        ],
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      var overlay = container.read(liveTrackingMapOverlayProvider('trip-1'));
      expect(overlay.currentMarker, isNotNull);
      expect(overlay.pathRoute, isNull);

      batchesController.add(
        <TrackingPointBatchRow>[
          _batch(
            id: 'batch-1',
            sessionId: 'session-1',
            points: const <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 12.0, 'longitude': 77.0},
            ],
          ),
          _batch(
            id: 'batch-2',
            sessionId: 'session-1',
            points: const <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 12.1, 'longitude': 77.1},
            ],
          ),
        ],
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      overlay = container.read(liveTrackingMapOverlayProvider('trip-1'));
      expect(overlay.currentMarker, isNotNull);
      expect(overlay.pathRoute, isNotNull);
      expect(overlay.pathRoute!.coordinates.length, 2);

      expect(updates.length, greaterThanOrEqualTo(3));
    });

    test('prefers remote path snapshot when available', () async {
      final runtimeController =
          StreamController<LiveTrackingRuntimeSnapshot>.broadcast();
      final batchesController =
          StreamController<List<TrackingPointBatchRow>>.broadcast();

      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-2').overrideWith(
            (ref) => runtimeController.stream,
          ),
          liveTrackingSessionBatchesProvider('session-2').overrideWith(
            (ref) => batchesController.stream,
          ),
          liveTrackingRemotePathPointsProvider('trip-2').overrideWith(
            (ref) => Stream<List<AppLatLng>>.value(const <AppLatLng>[
              AppLatLng(latitude: 10.0, longitude: 20.0),
              AppLatLng(latitude: 10.2, longitude: 20.2),
            ]),
          ),
        ],
      );
      addTearDown(() async {
        await runtimeController.close();
        await batchesController.close();
        container.dispose();
      });
      final subscription = container.listen<LiveTrackingMapOverlay>(
        liveTrackingMapOverlayProvider('trip-2'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      runtimeController.add(
        const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-2',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-2',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      batchesController.add(
        <TrackingPointBatchRow>[
          _batch(
            id: 'batch-r1',
            sessionId: 'session-2',
            points: const <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 12.0, 'longitude': 77.0},
              <String, dynamic>{'latitude': 12.1, 'longitude': 77.1},
            ],
          ),
        ],
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await container.read(liveTrackingRemotePathPointsProvider('trip-2').future);

      final overlay = container.read(liveTrackingMapOverlayProvider('trip-2'));
      expect(overlay.pathRoute, isNotNull);
      expect(overlay.pathRoute!.id, '_live_tracking_remote_path_session-2');
      expect(overlay.pathRoute!.coordinates.length, 2);
      expect(overlay.pathRoute!.coordinates.first.latitude, 10.0);
      expect(overlay.pathRoute!.coordinates.first.longitude, 20.0);
    });

    test('polls remote path on active cadence', () async {
      final runtimeController =
          StreamController<LiveTrackingRuntimeSnapshot>.broadcast();
      final api = _PollingLiveTrackingApi();
      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-3').overrideWith(
            (ref) => runtimeController.stream,
          ),
          liveTrackingApiProvider.overrideWith((ref) => api),
          liveTrackingRemotePathRefreshIntervalProvider(
            LiveTrackingRuntimeState.active,
          ).overrideWith((ref) => const Duration(milliseconds: 30)),
        ],
      );
      addTearDown(() async {
        await runtimeController.close();
        container.dispose();
      });

      final sub = container.listen<AsyncValue<List<AppLatLng>>>(
        liveTrackingRemotePathPointsProvider('trip-3'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      runtimeController.add(
        const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-3',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-3',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(api.fetchCalls, greaterThanOrEqualTo(2));
    });
  });
}

class _PollingLiveTrackingApi implements LiveTrackingApi {
  int fetchCalls = 0;

  @override
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) async {
    fetchCalls += 1;
    return <String, dynamic>{
      'trip_id': tripId,
      'session_id': sessionId ?? 'session-3',
      'points_count': 2,
      'points': const <Map<String, dynamic>>[
        <String, dynamic>{'latitude': 10.0, 'longitude': 20.0},
        <String, dynamic>{'latitude': 10.1, 'longitude': 20.1},
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> startTracking({
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
  Future<Map<String, dynamic>> pauseTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime pausedAt,
    String? sessionId,
    String? reason,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> resumeTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime resumedAt,
    String? sessionId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> stopTracking({
    required String tripId,
    required String idempotencyKey,
    required String clientEventId,
    required DateTime stoppedAt,
    String? sessionId,
    String? reason,
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
    Map<String, dynamic>? location,
    List<Map<String, dynamic>>? mediaRefs,
    String? linkedTripPlaceId,
    Map<String, dynamic>? extraPayload,
  }) {
    throw UnimplementedError();
  }
}

TrackingPointBatchRow _batch({
  required String id,
  required String sessionId,
  required List<Map<String, dynamic>> points,
}) {
  final now = DateTime.utc(2026, 3, 25);
  return TrackingPointBatchRow(
    id: id,
    tripId: 'trip-1',
    sessionId: sessionId,
    remoteSessionId: null,
    clientBatchId: 'client-$id',
    firstRecordedAt: now,
    lastRecordedAt: now,
    pointCount: points.length,
    pointsJson: jsonEncode(points),
    status: 'queued',
    retryCount: 0,
    nextAttemptAt: null,
    workerSessionId: null,
    lastError: null,
    syncStatus: 'pending',
    localUpdatedAt: now,
    serverUpdatedAt: null,
    createdAt: now,
    updatedAt: now,
  );
}
