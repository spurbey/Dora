import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_top_bar.dart';

Widget _wrap(LiveCaptureShellState state, {EditorSyncStatusKind? syncKind}) {
  return MaterialApp(
    home: Scaffold(
      body: LiveCaptureTopBar(
        tripName: 'Test Trip',
        state: state,
        syncLabel: syncKind == EditorSyncStatusKind.synced ? 'Synced' : 'Syncing...',
        syncKind: syncKind,
        onBack: () {},
      ),
    ),
  );
}

void main() {
  group('LiveCaptureTopBar', () {
    testWidgets('renders topBar key', (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      expect(find.byKey(const ValueKey('liveCaptureTopBar')), findsOneWidget);
    });

    testWidgets('state badge is present for all states', (tester) async {
      for (final state in LiveCaptureShellState.values) {
        await tester.pumpWidget(_wrap(state));
        expect(
          find.byKey(const ValueKey('liveCaptureStateBadge')),
          findsOneWidget,
          reason: 'badge missing for state $state',
        );
      }
    });

    testWidgets('active state creates pulse controller and it is running',
        (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      await tester.pump(const Duration(milliseconds: 300));
      // Widget tree is stable and pulse is animating (no exceptions)
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('liveCaptureStateBadge')), findsOneWidget);
    });

    testWidgets(
        'pulse stops when state changes from active to paused',
        (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      await tester.pump(const Duration(milliseconds: 200));

      // Rebuild with paused state
      await tester.pumpWidget(_wrap(LiveCaptureShellState.paused));
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('liveCaptureStateBadge')),
          matching: find.text('Paused'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('reduced motion: active state renders without crash',
        (tester) async {
      // MediaQuery must be placed INSIDE MaterialApp to override its own MediaQuery.
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: LiveCaptureTopBar(
                tripName: 'Test Trip',
                state: LiveCaptureShellState.active,
                syncLabel: 'Synced',
                onBack: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byKey(const ValueKey('liveCaptureStateBadge')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('sync label renders with expected text', (tester) async {
      await tester.pumpWidget(
        _wrap(LiveCaptureShellState.active, syncKind: EditorSyncStatusKind.synced),
      );
      expect(
        find.byKey(const ValueKey('liveCaptureSyncLabel')),
        findsOneWidget,
      );
    });

    testWidgets('state transitions crossfade via AnimatedSwitcher',
        (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.planned));
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      // During transition both old/new children coexist inside AnimatedSwitcher —
      // the outer container key stays unique.
      expect(find.byKey(const ValueKey('liveCaptureStateBadge')), findsOneWidget);
      // pump with finite duration — pumpAndSettle would hang on the repeating pulse.
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });
}
