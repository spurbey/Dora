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
      await _waitUntil(() => updates.length >= 2);

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
      await _waitUntil(() {
        final next = container.read(liveTrackingMapOverlayProvider('trip-1'));
        return next.currentMarker != null && next.pathRoute == null;
      });
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
      await _waitUntil(() {
        final next = container.read(liveTrackingMapOverlayProvider('trip-1'));
        return next.pathRoute != null;
      });
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
      await container
          .read(liveTrackingRemotePathPointsProvider('trip-2').future);

      final overlay = container.read(liveTrackingMapOverlayProvider('trip-2'));
      expect(overlay.pathRoute, isNotNull);
      expect(overlay.pathRoute!.id, '_live_tracking_remote_path_session-2');
      expect(overlay.pathRoute!.coordinates.length, 2);
      expect(overlay.pathRoute!.coordinates.first.latitude, 10.0);
      expect(overlay.pathRoute!.coordinates.first.longitude, 20.0);
    });

    test('falls back to local path when remote snapshot is under-sampled',
        () async {
      final runtimeController =
          StreamController<LiveTrackingRuntimeSnapshot>.broadcast();
      final batchesController =
          StreamController<List<TrackingPointBatchRow>>.broadcast();

      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-5').overrideWith(
            (ref) => runtimeController.stream,
          ),
          liveTrackingSessionBatchesProvider('session-5').overrideWith(
            (ref) => batchesController.stream,
          ),
          liveTrackingRemotePathPointsProvider('trip-5').overrideWith(
            (ref) => Stream<List<AppLatLng>>.value(const <AppLatLng>[
              AppLatLng(latitude: 27.7000, longitude: 85.3000),
              AppLatLng(latitude: 27.7002, longitude: 85.3002),
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
        liveTrackingMapOverlayProvider('trip-5'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      runtimeController.add(
        const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-5',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-5',
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      batchesController.add(
        <TrackingPointBatchRow>[
          _batch(
            id: 'batch-local-5',
            sessionId: 'session-5',
            points: const <Map<String, dynamic>>[
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:00:00Z',
                'latitude': 27.7000,
                'longitude': 85.3000,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:01:00Z',
                'latitude': 27.7002,
                'longitude': 85.3003,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:02:00Z',
                'latitude': 27.7004,
                'longitude': 85.3006,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:03:00Z',
                'latitude': 27.7006,
                'longitude': 85.3009,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:04:00Z',
                'latitude': 27.7008,
                'longitude': 85.3012,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:05:00Z',
                'latitude': 27.7010,
                'longitude': 85.3015,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:06:00Z',
                'latitude': 27.7012,
                'longitude': 85.3018,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-26T10:07:00Z',
                'latitude': 27.7014,
                'longitude': 85.3021,
              },
            ],
          ),
        ],
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await container
          .read(liveTrackingRemotePathPointsProvider('trip-5').future);

      final overlay = container.read(liveTrackingMapOverlayProvider('trip-5'));
      expect(overlay.pathRoute, isNotNull);
      expect(overlay.pathRoute!.id, '_live_tracking_path_session-5');
      expect(overlay.pathRoute!.coordinates.length, 8);
    });

    test('stabilizes remote path points before emitting to overlay', () async {
      final api = _NoisyPathLiveTrackingApi();
      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-6').overrideWith(
            (ref) => Stream<LiveTrackingRuntimeSnapshot>.value(
              const LiveTrackingRuntimeSnapshot(
                tripId: 'trip-6',
                state: LiveTrackingRuntimeState.active,
                sessionId: 'session-6',
                remoteSessionId: 'remote-session-6',
              ),
            ),
          ),
          liveTrackingIsAuthenticatedProvider.overrideWith((ref) => true),
          liveTrackingServerTripIdProvider('trip-6').overrideWith(
            (ref) => Stream<String?>.value('remote-trip-6'),
          ),
          liveTrackingApiProvider.overrideWith((ref) => api),
          liveTrackingRemotePathRefreshIntervalProvider(
            LiveTrackingRuntimeState.active,
          ).overrideWith((ref) => const Duration(seconds: 5)),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen<AsyncValue<List<AppLatLng>>>(
        liveTrackingRemotePathPointsProvider('trip-6'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      final points = await container
          .read(liveTrackingRemotePathPointsProvider('trip-6').future);
      expect(
        points,
        const <AppLatLng>[
          AppLatLng(latitude: 27.7000, longitude: 85.3000),
          AppLatLng(latitude: 27.7002, longitude: 85.3002),
          AppLatLng(latitude: 27.7004, longitude: 85.3004),
        ],
      );
      expect(api.fetchCalls, 1);
    });

    test('auth gate keeps remote path local-only when signed out', () async {
      final api = _PollingLiveTrackingApi();
      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-auth').overrideWith(
            (ref) => Stream<LiveTrackingRuntimeSnapshot>.value(
              const LiveTrackingRuntimeSnapshot(
                tripId: 'trip-auth',
                state: LiveTrackingRuntimeState.active,
                sessionId: 'session-auth',
                remoteSessionId: 'remote-session-auth',
              ),
            ),
          ),
          liveTrackingIsAuthenticatedProvider.overrideWith((ref) => false),
          liveTrackingServerTripIdProvider('trip-auth').overrideWith(
            (ref) => Stream<String?>.value('remote-trip-auth'),
          ),
          liveTrackingApiProvider.overrideWith((ref) => api),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen<AsyncValue<List<AppLatLng>>>(
        liveTrackingRemotePathPointsProvider('trip-auth'),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final points = container
              .read(liveTrackingRemotePathPointsProvider('trip-auth'))
              .valueOrNull ??
          const <AppLatLng>[];
      expect(points, isEmpty);
      expect(api.fetchCalls, 0);
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
          liveTrackingIsAuthenticatedProvider.overrideWith((ref) => true),
          liveTrackingServerTripIdProvider('trip-3').overrideWith(
            (ref) => Stream<String?>.value('remote-trip-3'),
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
          remoteSessionId: 'remote-session-3',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(api.fetchCalls, greaterThanOrEqualTo(2));
      expect(api.lastTripId, 'remote-trip-3');
      expect(api.lastSessionId, 'remote-session-3');
    });

    test('falls back to empty remote path when fetch fails', () async {
      final runtimeController =
          StreamController<LiveTrackingRuntimeSnapshot>.broadcast();
      final api = _FlakyLiveTrackingApi();
      final container = ProviderContainer(
        overrides: [
          liveTrackingRuntimeSnapshotProvider('trip-4').overrideWith(
            (ref) => runtimeController.stream,
          ),
          liveTrackingIsAuthenticatedProvider.overrideWith((ref) => true),
          liveTrackingServerTripIdProvider('trip-4').overrideWith(
            (ref) => Stream<String?>.value('remote-trip-4'),
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

      final updates = <List<AppLatLng>>[];
      final sub = container.listen<AsyncValue<List<AppLatLng>>>(
        liveTrackingRemotePathPointsProvider('trip-4'),
        (_, next) {
          final value = next.valueOrNull;
          if (value != null) {
            updates.add(value);
          }
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      runtimeController.add(
        const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-4',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-4',
          remoteSessionId: 'remote-session-4',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 160));
      expect(updates.any((list) => list.isNotEmpty), isTrue);
      expect(updates.last, isEmpty);
    });
  });
}

Future<void> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _PollingLiveTrackingApi implements LiveTrackingApi {
  int fetchCalls = 0;
  String? lastTripId;
  String? lastSessionId;

  @override
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) async {
    fetchCalls += 1;
    lastTripId = tripId;
    lastSessionId = sessionId;
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
  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
  }) {
    throw UnimplementedError();
  }
}

class _FlakyLiveTrackingApi implements LiveTrackingApi {
  var _calls = 0;

  @override
  Future<Map<String, dynamic>> fetchTrackingPath({
    required String tripId,
    String? sessionId,
    int limit = 5000,
  }) async {
    _calls += 1;
    if (_calls == 1) {
      return <String, dynamic>{
        'trip_id': tripId,
        'session_id': sessionId ?? 'session-4',
        'points_count': 2,
        'points': const <Map<String, dynamic>>[
          <String, dynamic>{'latitude': 10.0, 'longitude': 20.0},
          <String, dynamic>{'latitude': 10.1, 'longitude': 20.1},
        ],
      };
    }
    throw Exception('network');
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
  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
  }) {
    throw UnimplementedError();
  }
}

class _NoisyPathLiveTrackingApi implements LiveTrackingApi {
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
      'session_id': sessionId ?? 'session-6',
      'points_count': 6,
      'points': const <Map<String, dynamic>>[
        <String, dynamic>{'latitude': 27.7000, 'longitude': 85.3000},
        <String, dynamic>{'latitude': 27.7000, 'longitude': 85.3000},
        <String, dynamic>{'latitude': 27.8200, 'longitude': 85.4200},
        <String, dynamic>{'latitude': 27.7002, 'longitude': 85.3002},
        <String, dynamic>{'latitude': 27.7004, 'longitude': 85.3004},
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
  Future<Map<String, dynamic>> rebindCompiledProjectionMedia({
    required String tripId,
    required String sourceMediaId,
    required String action,
    String? tripPlaceId,
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
