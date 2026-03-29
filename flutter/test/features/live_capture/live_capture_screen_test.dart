import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    testWidgets('ended state shows restart and editor controls',
        (tester) async {
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
  });
}
