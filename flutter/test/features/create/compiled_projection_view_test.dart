import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/domain/compiled_projection.dart';
import 'package:dora/features/create/presentation/providers/compiled_projection_provider.dart';

void main() {
  group('CompiledProjectionView.merge', () {
    test('adds unsynced local tracking events as overlay entries', () {
      final now = DateTime.utc(2026, 4, 1, 10);
      final view = CompiledProjectionView.merge(
        remote: const CompiledProjectionSnapshot(
          tripId: 'trip-1',
          compilerVersion: 1,
          stale: false,
          timelineEntries: <CompiledTimelineEntry>[],
          timelineGroups: <CompiledTimelineDayGroup>[],
          routeSegments: <CompiledRouteSegment>[],
        ),
        localEvents: <TrackingEventRow>[
          _eventRow(
            id: 'local-1',
            tripId: 'trip-1',
            clientEventId: 'client-1',
            syncStatus: 'pending',
            createdAt: now,
          ),
        ],
      );

      expect(view.entries, hasLength(1));
      expect(view.entries.first.sourceKind, 'tracking_event_local');
      expect(view.entries.first.isLocalPending, isTrue);
      expect(view.entries.first.clientEventId, 'client-1');
    });

    test('deduplicates overlay when backend compiled entry already exists', () {
      final now = DateTime.utc(2026, 4, 1, 10);
      final view = CompiledProjectionView.merge(
        remote: CompiledProjectionSnapshot(
          tripId: 'trip-1',
          compilerVersion: 1,
          stale: false,
          timelineEntries: <CompiledTimelineEntry>[
            CompiledTimelineEntry(
              entryId: 'tracking_event:server-1',
              sourceKind: 'tracking_event',
              sourceId: 'server-1',
              eventType: 'note',
              capturedAt: now,
              bucketType: 'on_route',
              bindSource: 'auto',
              title: 'Server note',
              payload: const <String, dynamic>{
                'client_event_id': 'client-1',
              },
              clientEventId: 'client-1',
            ),
          ],
          timelineGroups: const <CompiledTimelineDayGroup>[],
          routeSegments: const <CompiledRouteSegment>[],
        ),
        localEvents: <TrackingEventRow>[
          _eventRow(
            id: 'local-1',
            tripId: 'trip-1',
            clientEventId: 'client-1',
            syncStatus: 'pending',
            createdAt: now,
          ),
        ],
      );

      expect(view.entries, hasLength(1));
      expect(view.entries.first.sourceKind, 'tracking_event');
      expect(view.entries.first.isLocalPending, isFalse);
    });

    test('keeps unresolved local items under on_route bucket', () {
      final now = DateTime.utc(2026, 4, 1, 10);
      final view = CompiledProjectionView.merge(
        remote: const CompiledProjectionSnapshot(
          tripId: 'trip-1',
          compilerVersion: 1,
          stale: false,
          timelineEntries: <CompiledTimelineEntry>[],
          timelineGroups: <CompiledTimelineDayGroup>[],
          routeSegments: <CompiledRouteSegment>[],
        ),
        localEvents: <TrackingEventRow>[
          _eventRow(
            id: 'local-1',
            tripId: 'trip-1',
            clientEventId: 'client-1',
            syncStatus: 'failed',
            createdAt: now,
            resolverState: 'on_route_unresolved',
            resolvedPlaceId: null,
          ),
        ],
      );

      expect(view.entries.single.bucketType, 'on_route');
      expect(view.entries.single.placeId, isNull);
      expect(view.dayGroups.single.entries.single.bucketType, 'on_route');
    });

    test('includes synced locals when remote does not contain dedupe keys', () {
      final now = DateTime.utc(2026, 4, 1, 10);
      final view = CompiledProjectionView.merge(
        remote: const CompiledProjectionSnapshot(
          tripId: 'trip-1',
          compilerVersion: 1,
          stale: false,
          timelineEntries: <CompiledTimelineEntry>[],
          timelineGroups: <CompiledTimelineDayGroup>[],
          routeSegments: <CompiledRouteSegment>[],
        ),
        localEvents: <TrackingEventRow>[
          _eventRow(
            id: 'local-synced-1',
            tripId: 'trip-1',
            clientEventId: 'client-synced-1',
            syncStatus: 'synced',
            createdAt: now,
          ),
        ],
      );

      expect(view.entries, hasLength(1));
      expect(view.entries.single.sourceKind, 'tracking_event_local');
      expect(view.entries.single.isLocalPending, isFalse);
      expect(view.entries.single.subtitle, 'Synced');
    });
  });
}

TrackingEventRow _eventRow({
  required String id,
  required String tripId,
  required String clientEventId,
  required String syncStatus,
  required DateTime createdAt,
  String resolverState = 'resolved',
  String? resolvedPlaceId = 'place-1',
}) {
  return TrackingEventRow(
    id: id,
    tripId: tripId,
    eventType: 'note',
    note: 'Quick note',
    latitude: 27.7,
    longitude: 85.3,
    payloadJson: '{}',
    clientEventId: clientEventId,
    resolvedPlaceId: resolvedPlaceId,
    bindConfidence: 0.9,
    resolverReasonCode: 'trip_place_radius_match',
    resolverState: resolverState,
    resolverVersion: 1,
    resolvedAt: createdAt,
    resolutionHintJson: null,
    syncStatus: syncStatus,
    localUpdatedAt: createdAt,
    serverUpdatedAt: null,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
