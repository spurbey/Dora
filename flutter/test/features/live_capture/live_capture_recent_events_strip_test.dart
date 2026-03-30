import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_recent_events_strip.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('LiveCaptureRecentEventsStrip', () {
    testWidgets('shows empty placeholder when no events', (tester) async {
      await tester.pumpWidget(
        wrap(
          const LiveCaptureRecentEventsStrip(events: <TrackingEventRow>[]),
        ),
      );

      expect(find.byKey(const ValueKey('liveCaptureRecentEventsStrip')),
          findsOneWidget);
      expect(find.text('Recent captures will appear here.'), findsOneWidget);
    });

    testWidgets('renders up to three most recent events', (tester) async {
      final rows = [
        _row(id: 'm1', note: 'Warn: steep curve'),
        _row(id: 'm2', note: 'Tea break'),
        _row(id: 'm3', note: 'Photo marker'),
        _row(id: 'm4', note: 'Extra item'),
      ];

      await tester.pumpWidget(
        wrap(
          LiveCaptureRecentEventsStrip(events: rows),
        ),
      );

      expect(find.byKey(const ValueKey('liveCaptureEvent_m1')), findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureEvent_m2')), findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureEvent_m3')), findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureEvent_m4')), findsNothing);
    });
  });
}

TrackingEventRow _row({
  required String id,
  required String note,
}) {
  final now = DateTime.utc(2026, 3, 29, 12, 0);
  return TrackingEventRow(
    id: id,
    tripId: 'trip-1',
    eventType: 'note',
    note: note,
    latitude: 27.7,
    longitude: 85.3,
    payloadJson: '{}',
    clientEventId: 'event-$id',
    syncStatus: 'local_only',
    localUpdatedAt: now,
    serverUpdatedAt: null,
    createdAt: now,
    updatedAt: now,
  );
}
