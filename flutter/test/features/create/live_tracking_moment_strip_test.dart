import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/presentation/widgets/live_tracking_moment_strip.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('LiveTrackingMomentStrip', () {
    testWidgets('renders moments and triggers capture/edit callbacks',
        (tester) async {
      var captureTapCount = 0;
      String? editedMomentId;
      final moment = _moment(
        id: 'moment-1',
        linkedTripPlaceId: 'place-1',
      );

      await tester.pumpWidget(
        wrap(
          LiveTrackingMomentStrip(
            moments: <TrackingMomentRow>[moment],
            inFlightMomentIds: const <String>{},
            canCapture: true,
            captureInFlight: false,
            onCaptureNow: () => captureTapCount += 1,
            onEditMoment: (row) => editedMomentId = row.id,
          ),
        ),
      );

      expect(find.byKey(const ValueKey('momentTile_moment-1')), findsOneWidget);
      expect(find.textContaining('Place linked'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('momentCaptureNow')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('momentEdit_moment-1')));
      await tester.pump();

      expect(captureTapCount, 1);
      expect(editedMomentId, 'moment-1');
    });

    testWidgets('disables capture and edit actions when busy', (tester) async {
      final busyMoment = _moment(id: 'moment-busy');

      await tester.pumpWidget(
        wrap(
          LiveTrackingMomentStrip(
            moments: <TrackingMomentRow>[busyMoment],
            inFlightMomentIds: const <String>{'moment-busy'},
            canCapture: true,
            captureInFlight: true,
            onCaptureNow: () {},
            onEditMoment: (_) {},
          ),
        ),
      );

      final captureButton = tester.widget<FilledButton>(
        find.byKey(const ValueKey('momentCaptureNow')),
      );
      expect(captureButton.onPressed, isNull);

      final editButton = tester.widget<TextButton>(
        find.byKey(const ValueKey('momentEdit_moment-busy')),
      );
      expect(editButton.onPressed, isNull);
    });
  });
}

TrackingMomentRow _moment({
  required String id,
  String? linkedTripPlaceId,
}) {
  final now = DateTime.utc(2026, 3, 26, 10, 30);
  return TrackingMomentRow(
    id: id,
    tripId: 'trip-1',
    candidateId: null,
    linkedTripPlaceId: linkedTripPlaceId,
    source: 'manual',
    confidence: null,
    capturedAt: now,
    latitude: 27.7,
    longitude: 85.3,
    note: 'Morning walk',
    mediaRefsJson: '[]',
    extraPayloadJson: '{}',
    lockedFieldsJson: '{}',
    pendingOperation: null,
    clientEventId: null,
    syncStatus: 'synced',
    localUpdatedAt: now,
    serverUpdatedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
