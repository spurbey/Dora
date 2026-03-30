import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/create/presentation/providers/live_tracking_runtime_provider.dart';
import 'package:dora/features/create/presentation/providers/tracking_sync_provider.dart';
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

      expect(
          find.byKey(const ValueKey('liveCaptureMapCanvas')), findsOneWidget);
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

    testWidgets('ended state shows editor control', (tester) async {
      await tester.pumpWidget(wrap(LiveCaptureShellState.ended));

      expect(find.byKey(const ValueKey('liveCaptureControlStartNew')),
          findsNothing);
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
      await tester.pumpAndSettle();

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
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('liveCaptureBlockedCallout')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('liveCaptureControlPause')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveCaptureControlRetry')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('media actions are command-gated with deterministic feedback',
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
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('liveCaptureActionPhoto')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Photo capture is temporarily disabled until place binding is available.',
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('liveCaptureActionMedia')));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Media capture is temporarily disabled until place binding is available.',
        ),
        findsOneWidget,
      );
    });
  });
}
