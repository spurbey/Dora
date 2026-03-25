import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';

void main() {
  group('buildLiveTrackingMapOverlay', () {
    test('returns empty overlay when runtime snapshot is null', () {
      final overlay = buildLiveTrackingMapOverlay(
        snapshot: null,
        sessionBatches: const <TrackingPointBatchRow>[],
      );

      expect(overlay.pathRoute, isNull);
      expect(overlay.currentMarker, isNull);
    });

    test('returns empty overlay when runtime state is planned', () {
      final overlay = buildLiveTrackingMapOverlay(
        snapshot: const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-1',
          state: LiveTrackingRuntimeState.planned,
          sessionId: 'session-1',
        ),
        sessionBatches: <TrackingPointBatchRow>[
          _batch(
            id: 'batch-1',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 11.0, 'longitude': 22.0},
            ],
          ),
        ],
      );

      expect(overlay.pathRoute, isNull);
      expect(overlay.currentMarker, isNull);
    });

    test('returns marker only when exactly one valid point exists', () {
      final overlay = buildLiveTrackingMapOverlay(
        snapshot: const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-1',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-1',
        ),
        sessionBatches: <TrackingPointBatchRow>[
          _batch(
            id: 'batch-1',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 11.0, 'longitude': 22.0},
            ],
          ),
        ],
      );

      expect(overlay.pathRoute, isNull);
      expect(overlay.currentMarker, isNotNull);
      expect(
        overlay.currentMarker!.position,
        const AppLatLng(latitude: 11.0, longitude: 22.0),
      );
      expect(overlay.currentMarker!.id, '_live_tracking_current_session-1');
    });

    test('returns route and marker with consecutive duplicate dedupe', () {
      final overlay = buildLiveTrackingMapOverlay(
        snapshot: const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-1',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-1',
        ),
        sessionBatches: <TrackingPointBatchRow>[
          _batch(
            id: 'batch-1',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 10.0, 'longitude': 20.0},
              <String, dynamic>{'latitude': 10.0, 'longitude': 20.0},
              <String, dynamic>{'latitude': 11.0, 'longitude': 21.0},
            ],
          ),
          _batch(
            id: 'batch-2',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{'latitude': 11.0, 'longitude': 21.0},
              <String, dynamic>{'latitude': 12.0, 'longitude': 22.0},
              <String, dynamic>{'latitude': null, 'longitude': 99.0},
            ],
          ),
          _batch(
            id: 'batch-3',
            sessionId: 'session-1',
            rawPointsJson: '{"invalid": true}',
          ),
        ],
      );

      expect(overlay.pathRoute, isNotNull);
      expect(overlay.pathRoute!.id, '_live_tracking_path_session-1');
      expect(
        overlay.pathRoute!.coordinates,
        const <AppLatLng>[
          AppLatLng(latitude: 10.0, longitude: 20.0),
          AppLatLng(latitude: 11.0, longitude: 21.0),
          AppLatLng(latitude: 12.0, longitude: 22.0),
        ],
      );
      expect(overlay.currentMarker, isNotNull);
      expect(
        overlay.currentMarker!.position,
        const AppLatLng(latitude: 12.0, longitude: 22.0),
      );
    });

    test('orders points by recorded_at across out-of-order batch creation', () {
      final overlay = buildLiveTrackingMapOverlay(
        snapshot: const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-1',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-1',
        ),
        sessionBatches: <TrackingPointBatchRow>[
          _batch(
            id: 'batch-early',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:00:00Z',
                'latitude': 27.7000,
                'longitude': 85.3000,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:20:00Z',
                'latitude': 27.7020,
                'longitude': 85.3020,
              },
            ],
          ),
          _batch(
            id: 'batch-late',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:10:00Z',
                'latitude': 27.7010,
                'longitude': 85.3010,
              },
            ],
          ),
        ],
      );

      expect(overlay.pathRoute, isNotNull);
      expect(
        overlay.pathRoute!.coordinates,
        const <AppLatLng>[
          AppLatLng(latitude: 27.7000, longitude: 85.3000),
          AppLatLng(latitude: 27.7010, longitude: 85.3010),
          AppLatLng(latitude: 27.7020, longitude: 85.3020),
        ],
      );
    });

    test('filters low quality spikes for stable route overlay', () {
      final overlay = buildLiveTrackingMapOverlay(
        snapshot: const LiveTrackingRuntimeSnapshot(
          tripId: 'trip-1',
          state: LiveTrackingRuntimeState.active,
          sessionId: 'session-1',
        ),
        sessionBatches: <TrackingPointBatchRow>[
          _batch(
            id: 'batch-stable',
            sessionId: 'session-1',
            points: <Map<String, dynamic>>[
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:00:00Z',
                'latitude': 27.7000,
                'longitude': 85.3000,
                'accuracy_m': 5.0,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:00:40Z',
                'latitude': 27.8200,
                'longitude': 85.4200,
                'accuracy_m': 5.0,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:01:20Z',
                'latitude': 27.7002,
                'longitude': 85.3002,
                'accuracy_m': 6.0,
              },
              <String, dynamic>{
                'recorded_at': '2026-03-25T10:02:00Z',
                'latitude': 27.7004,
                'longitude': 85.3004,
                'accuracy_m': 120.0,
              },
            ],
          ),
        ],
      );

      expect(overlay.pathRoute, isNotNull);
      expect(
        overlay.pathRoute!.coordinates,
        const <AppLatLng>[
          AppLatLng(latitude: 27.7000, longitude: 85.3000),
          AppLatLng(latitude: 27.7002, longitude: 85.3002),
        ],
      );
      expect(
        overlay.currentMarker!.position,
        const AppLatLng(latitude: 27.7002, longitude: 85.3002),
      );
    });
  });
}

TrackingPointBatchRow _batch({
  required String id,
  required String sessionId,
  List<Map<String, dynamic>>? points,
  String? rawPointsJson,
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
    pointCount: points?.length ?? 0,
    pointsJson:
        rawPointsJson ?? jsonEncode(points ?? const <Map<String, dynamic>>[]),
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
