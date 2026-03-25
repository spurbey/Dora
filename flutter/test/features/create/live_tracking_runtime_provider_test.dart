import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
