import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
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
            (ref) async => const <AppLatLng>[],
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
            (ref) async => const <AppLatLng>[
              AppLatLng(latitude: 10.0, longitude: 20.0),
              AppLatLng(latitude: 10.2, longitude: 20.2),
            ],
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
  });
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
