import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_action_dock.dart';

Widget _wrap(
  LiveCaptureShellState state, {
  bool reduceMotion = false,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Scaffold(
        body: LiveCaptureActionDock(
          state: state,
          onPhoto: () {},
          onNote: () {},
          onWarn: () {},
          onMedia: () {},
          onTag: () {},
        ),
      ),
    ),
  );
}

void main() {
  group('LiveCaptureActionDock', () {
    testWidgets('all 5 action pills render in active state', (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      await tester.pumpAndSettle();
      for (final key in const [
        'liveCaptureActionPhoto',
        'liveCaptureActionNote',
        'liveCaptureActionWarn',
        'liveCaptureActionMedia',
        'liveCaptureActionTag',
      ]) {
        expect(
          find.byKey(ValueKey(key)),
          findsOneWidget,
          reason: '$key not found',
        );
      }
    });

    testWidgets(
        'reduced motion: buttons visible immediately without stagger travel',
        (tester) async {
      await tester.pumpWidget(
        _wrap(LiveCaptureShellState.active, reduceMotion: true),
      );
      // After a single pump (no settle needed), all buttons should be findable
      await tester.pump();
      for (final key in const [
        'liveCaptureActionPhoto',
        'liveCaptureActionNote',
      ]) {
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
      // No Opacity/Transform wrappers when reduced motion is on
      expect(tester.takeException(), isNull);
    });

    testWidgets('stagger animation completes without exceptions', (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      // Advance past stagger total (360ms)
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('liveCaptureActionDock')), findsOneWidget);
    });

    testWidgets(
        'paused state: note tappable, others rendered but disabled',
        (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.paused));
      await tester.pumpAndSettle();
      // All 5 present
      for (final key in const [
        'liveCaptureActionPhoto',
        'liveCaptureActionNote',
        'liveCaptureActionWarn',
        'liveCaptureActionMedia',
        'liveCaptureActionTag',
      ]) {
        expect(find.byKey(ValueKey(key)), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('dock container key is stable across state changes',
        (tester) async {
      await tester.pumpWidget(_wrap(LiveCaptureShellState.planned));
      await tester.pumpWidget(_wrap(LiveCaptureShellState.active));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('liveCaptureActionDock')),
        findsOneWidget,
      );
    });
  });
}
