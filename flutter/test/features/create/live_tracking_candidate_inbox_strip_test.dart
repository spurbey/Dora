import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/presentation/widgets/live_tracking_candidate_inbox_strip.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('LiveTrackingCandidateInboxStrip', () {
    testWidgets('renders candidates and emits action callbacks',
        (tester) async {
      String? confirmedId;
      String? rejectedId;
      String? snoozedId;
      final candidate = _candidate(id: 'candidate-1');

      await tester.pumpWidget(
        wrap(
          LiveTrackingCandidateInboxStrip(
            candidates: <TrackingCandidateRow>[candidate],
            inFlightCandidateIds: const <String>{},
            onConfirm: (id) => confirmedId = id,
            onReject: (id) => rejectedId = id,
            onSnooze: (id) => snoozedId = id,
          ),
        ),
      );

      expect(find.byKey(const ValueKey('candidateTile_candidate-1')),
          findsOneWidget);

      await tester
          .tap(find.byKey(const ValueKey('candidateConfirm_candidate-1')));
      await tester.pump();
      await tester
          .tap(find.byKey(const ValueKey('candidateReject_candidate-1')));
      await tester.pump();
      await tester
          .tap(find.byKey(const ValueKey('candidateSnooze_candidate-1')));
      await tester.pump();

      expect(confirmedId, 'candidate-1');
      expect(rejectedId, 'candidate-1');
      expect(snoozedId, 'candidate-1');
    });

    testWidgets('disables actions when candidate is queued or in flight',
        (tester) async {
      final queuedCandidate = _candidate(id: 'queued-1', actionState: 'queued');
      final inFlightCandidate = _candidate(id: 'active-1');

      await tester.pumpWidget(
        wrap(
          LiveTrackingCandidateInboxStrip(
            candidates: <TrackingCandidateRow>[
              queuedCandidate,
              inFlightCandidate,
            ],
            inFlightCandidateIds: const <String>{'active-1'},
            onConfirm: (_) {},
            onReject: (_) {},
            onSnooze: (_) {},
          ),
        ),
      );

      final queuedConfirm = tester.widget<FilledButton>(
        find.byKey(const ValueKey('candidateConfirm_queued-1')),
      );
      expect(queuedConfirm.onPressed, isNull);

      final inFlightReject = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('candidateReject_active-1')),
      );
      expect(inFlightReject.onPressed, isNull);
    });
  });
}

TrackingCandidateRow _candidate({
  required String id,
  String status = 'pending',
  String actionState = 'none',
}) {
  final now = DateTime.utc(2026, 3, 25, 10, 0);
  return TrackingCandidateRow(
    id: id,
    tripId: 'trip-1',
    sessionId: null,
    fingerprint: 'fp-$id',
    status: status,
    confidence: 0.92,
    suggestedName: 'Airport Plaza',
    suggestedLatitude: 27.7,
    suggestedLongitude: 85.3,
    startedAt: now.subtract(const Duration(minutes: 10)),
    endedAt: now,
    confirmedTripPlaceId: null,
    rejectedReason: null,
    snoozedUntil: null,
    cooldownUntil: null,
    payloadJson: '{}',
    notificationState: null,
    actionState: actionState,
    actionType: null,
    actionClientEventId: null,
    actionQueuedAt: null,
    actionSyncedAt: null,
    syncStatus: 'synced',
    localUpdatedAt: now,
    serverUpdatedAt: now,
    createdAt: now,
    updatedAt: now,
  );
}
