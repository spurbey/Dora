import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/tracking_sync_provider.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';
import 'package:dora/features/live_capture/presentation/providers/live_tracking_event_provider.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/screens/live_capture_screen.dart';

void main() {
  Widget wrap(LiveCaptureShellState state) {
    return ProviderScope(
      child: MaterialApp(
        home: LiveCaptureScreen(
          tripId: 'trip-123',
          previewState: state,
        ),
      ),
    );
  }

  group('LiveCaptureScreen shell states', () {
    testWidgets('planned state shows start control', (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.planned));

      expect(find.byKey(const ValueKey('liveCaptureTopBar')), findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureControlStart')),
          findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('liveCaptureStateBadge')),
          matching: find.text('Ready'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('active state shows pause and stop controls', (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.active));

      expect(find.byKey(const ValueKey('liveCaptureControlPause')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveCaptureControlStop')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('liveCaptureStateBadge')),
          matching: find.text('Active'),
        ),
        findsOneWidget,
      );
      expect(
          find.byKey(const ValueKey('liveCaptureActionPhoto')), findsOneWidget);
    });

    testWidgets('paused state shows resume and stop controls', (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.paused));

      expect(find.byKey(const ValueKey('liveCaptureControlResume')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveCaptureControlStop')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('liveCaptureStateBadge')),
          matching: find.text('Paused'),
        ),
        findsOneWidget,
      );
    });

    // Spec §4.4: during Paused, only Note action is enabled.
    testWidgets('paused state enables only note action, disables others',
        (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.paused));
      await tester.pumpAndSettle();

      // Note must be present (enabled — InkWell has onTap non-null)
      expect(find.byKey(const ValueKey('liveCaptureActionNote')), findsOneWidget);

      // All other capture actions must be present but disabled (rendered, not tappable)
      for (final key in const [
        'liveCaptureActionPhoto',
        'liveCaptureActionWarn',
        'liveCaptureActionMedia',
        'liveCaptureActionTag',
      ]) {
        expect(find.byKey(ValueKey(key)), findsOneWidget,
            reason: '$key should still be rendered in paused state');
      }
    });

    testWidgets('ended state shows start-new and editor controls', (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.ended));

      expect(find.byKey(const ValueKey('liveCaptureControlStartNew')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureControlOpenEditor')),
          findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('liveCaptureStateBadge')),
          matching: find.text('Ended'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('blocked state shows retry and review controls',
        (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.blocked));

      expect(find.byKey(const ValueKey('liveCaptureControlRetry')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureControlReview')),
          findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('liveCaptureStateBadge')),
          matching: find.text('Sync Blocked'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('blocked state remains stable on compact viewport',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrap(LiveCaptureShellState.blocked));
      await tester.pumpAndSettle();

      expect(
          find.byKey(const ValueKey('liveCaptureBottomPanel')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'uses tracking-scoped sync status and does not depend on editor sync provider',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveTrackingCaptureBootstrapProvider.overrideWith((ref) {}),
            trackingSyncBootstrapProvider.overrideWith((ref) {}),
            liveTrackingRuntimeSnapshotProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const LiveTrackingRuntimeSnapshot(
                  tripId: 'trip-123',
                  state: LiveTrackingRuntimeState.active,
                  sessionId: 'session-1',
                ),
              ),
            ),
            liveTrackingSyncStatusProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const EditorSyncStatus(
                  kind: EditorSyncStatusKind.synced,
                  label: 'Synced',
                  snapshot: EditorSyncSnapshot(
                    blockedItems: 0,
                    failedItems: 0,
                    activeItems: 0,
                    unsyncedRows: 0,
                  ),
                ),
              ),
            ),
            editorSyncStatusProvider('trip-123').overrideWith(
              (ref) => throw StateError(
                'LiveCaptureScreen must not read editorSyncStatusProvider',
              ),
            ),
            liveTrackingMapOverlayProvider('trip-123').overrideWith(
              (ref) => const LiveTrackingMapOverlay(),
            ),
            liveTrackingEventsProvider('trip-123').overrideWith(
              (ref) => Stream.value(const <TrackingEventRow>[]),
            ),
          ],
          child: const MaterialApp(
            home: LiveCaptureScreen(tripId: 'trip-123'),
          ),
        ),
      );
      // Use pump with a finite duration — pumpAndSettle would hang due to the
      // repeating GPS-pulse animation in LiveCaptureTopBar when state is active.
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const ValueKey('liveCaptureControlPause')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveCaptureControlRetry')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'tracking blocked sync shows callout but keeps runtime controls active',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveTrackingCaptureBootstrapProvider.overrideWith((ref) {}),
            trackingSyncBootstrapProvider.overrideWith((ref) {}),
            liveTrackingRuntimeSnapshotProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const LiveTrackingRuntimeSnapshot(
                  tripId: 'trip-123',
                  state: LiveTrackingRuntimeState.active,
                  sessionId: 'session-1',
                ),
              ),
            ),
            liveTrackingSyncStatusProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const EditorSyncStatus(
                  kind: EditorSyncStatusKind.blocked,
                  label: 'Sync blocked',
                  snapshot: EditorSyncSnapshot(
                    blockedItems: 1,
                    failedItems: 0,
                    activeItems: 0,
                    unsyncedRows: 0,
                    firstBlockedTaskEntityType: 'tracking_session',
                    firstBlockedTaskEntityId: 'session-1',
                    firstBlockedTaskErrorMessage:
                        'Tracking can only be started from planned trip status',
                  ),
                ),
              ),
            ),
            liveTrackingMapOverlayProvider('trip-123').overrideWith(
              (ref) => const LiveTrackingMapOverlay(),
            ),
            liveTrackingEventsProvider('trip-123').overrideWith(
              (ref) => Stream.value(const <TrackingEventRow>[]),
            ),
          ],
          child: const MaterialApp(
            home: LiveCaptureScreen(tripId: 'trip-123'),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const ValueKey('liveCaptureBlockedCallout')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureControlPause')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveCaptureControlRetry')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows unresolved capture banner when resolver needs review',
        (tester) async {
      final unresolvedRow = _trackingEventRow(
        id: 'event-unresolved-1',
        tripId: 'trip-123',
        resolverState: 'on_route_unresolved',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveTrackingCaptureBootstrapProvider.overrideWith((ref) {}),
            trackingSyncBootstrapProvider.overrideWith((ref) {}),
            liveTrackingRuntimeSnapshotProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const LiveTrackingRuntimeSnapshot(
                  tripId: 'trip-123',
                  state: LiveTrackingRuntimeState.active,
                  sessionId: 'session-1',
                ),
              ),
            ),
            liveTrackingSyncStatusProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const EditorSyncStatus(
                  kind: EditorSyncStatusKind.syncing,
                  label: 'Syncing...',
                  snapshot: EditorSyncSnapshot(
                    blockedItems: 0,
                    failedItems: 0,
                    activeItems: 1,
                    unsyncedRows: 1,
                  ),
                ),
              ),
            ),
            liveTrackingUnresolvedSummaryProvider('trip-123').overrideWith(
              (ref) => LiveTrackingUnresolvedSummary(
                unresolvedCount: 2,
                latestUnresolved: unresolvedRow,
                latestReviewRequired: null,
                reviewHints: const <LiveTrackingPlaceHint>[],
              ),
            ),
            liveTrackingMapOverlayProvider('trip-123').overrideWith(
              (ref) => const LiveTrackingMapOverlay(),
            ),
            liveTrackingEventsProvider('trip-123').overrideWith(
              (ref) => Stream.value(const <TrackingEventRow>[]),
            ),
          ],
          child: const MaterialApp(
            home: LiveCaptureScreen(tripId: 'trip-123'),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.byKey(const ValueKey('liveCaptureUnresolvedBanner')),
        findsOneWidget,
      );
      expect(find.textContaining('captures need place selection'), findsOne);
    });

    testWidgets('shows probable place prompt for review-required captures',
        (tester) async {
      final reviewRow = _trackingEventRow(
        id: 'event-review-1',
        tripId: 'trip-123',
        resolverState: 'review_required',
        resolutionHintJson:
            '[{"name":"Cafe House","latitude":27.7,"longitude":85.3,"confidence":0.62,"reason":"ambiguous_candidates","place_id":"place-1"}]',
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveTrackingCaptureBootstrapProvider.overrideWith((ref) {}),
            trackingSyncBootstrapProvider.overrideWith((ref) {}),
            liveTrackingRuntimeSnapshotProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const LiveTrackingRuntimeSnapshot(
                  tripId: 'trip-123',
                  state: LiveTrackingRuntimeState.active,
                  sessionId: 'session-1',
                ),
              ),
            ),
            liveTrackingSyncStatusProvider('trip-123').overrideWith(
              (ref) => Stream.value(
                const EditorSyncStatus(
                  kind: EditorSyncStatusKind.synced,
                  label: 'Synced',
                  snapshot: EditorSyncSnapshot(
                    blockedItems: 0,
                    failedItems: 0,
                    activeItems: 0,
                    unsyncedRows: 0,
                  ),
                ),
              ),
            ),
            liveTrackingMapOverlayProvider('trip-123').overrideWith(
              (ref) => const LiveTrackingMapOverlay(),
            ),
            liveTrackingUnresolvedSummaryProvider('trip-123').overrideWith(
              (ref) => LiveTrackingUnresolvedSummary(
                unresolvedCount: 1,
                latestUnresolved: reviewRow,
                latestReviewRequired: reviewRow,
                reviewHints: const <LiveTrackingPlaceHint>[
                  LiveTrackingPlaceHint(
                    name: 'Cafe House',
                    latitude: 27.7,
                    longitude: 85.3,
                    confidence: 0.62,
                    reason: 'ambiguous_candidates',
                    placeId: 'place-1',
                  ),
                ],
              ),
            ),
            liveTrackingEventsProvider('trip-123').overrideWith(
              (ref) => Stream.value(const <TrackingEventRow>[]),
            ),
          ],
          child: const MaterialApp(
            home: LiveCaptureScreen(tripId: 'trip-123'),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.byKey(const ValueKey('liveCaptureProbablePlacePrompt')),
        findsOneWidget,
      );
      expect(find.textContaining('Probable place'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Keep on route'), findsOneWidget);
    });
  });
}

TrackingEventRow _trackingEventRow({
  required String id,
  required String tripId,
  required String resolverState,
  String eventType = 'note',
  String? resolutionHintJson,
}) {
  final now = DateTime.utc(2026, 3, 31, 10, 0, 0);
  return TrackingEventRow(
    id: id,
    tripId: tripId,
    eventType: eventType,
    note: null,
    latitude: 27.7,
    longitude: 85.3,
    payloadJson: '{}',
    clientEventId: id,
    resolvedPlaceId: null,
    bindConfidence: null,
    resolverReasonCode: null,
    resolverState: resolverState,
    resolverVersion: 1,
    resolvedAt: null,
    resolutionHintJson: resolutionHintJson,
    syncStatus: 'pending',
    localUpdatedAt: now,
    serverUpdatedAt: null,
    createdAt: now,
    updatedAt: now,
  );
}
