import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/widgets/live_tracking_control_strip.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('LiveTrackingControlStrip', () {
    testWidgets('shows start action when state is planned', (tester) async {
      var startTapped = 0;
      await tester.pumpWidget(
        wrap(
          LiveTrackingControlStrip(
            runtimeState: LiveTrackingRuntimeState.planned,
            isBusy: false,
            subtitle: 'Not started',
            onStart: () => startTapped += 1,
            onPause: () {},
            onResume: () {},
            onStop: () {},
          ),
        ),
      );

      expect(find.byKey(const ValueKey('liveTrackingActionStart')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveTrackingActionPause')), findsNothing);
      expect(
          find.byKey(const ValueKey('liveTrackingActionResume')), findsNothing);
      expect(
          find.byKey(const ValueKey('liveTrackingActionStop')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('liveTrackingActionStart')));
      await tester.pump();
      expect(startTapped, 1);
    });

    testWidgets('shows pause and stop when active', (tester) async {
      await tester.pumpWidget(
        wrap(
          LiveTrackingControlStrip(
            runtimeState: LiveTrackingRuntimeState.active,
            isBusy: false,
            subtitle: 'Active',
            onStart: () {},
            onPause: () {},
            onResume: () {},
            onStop: () {},
          ),
        ),
      );

      expect(find.byKey(const ValueKey('liveTrackingActionPause')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveTrackingActionStop')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveTrackingActionStart')), findsNothing);
      expect(
          find.byKey(const ValueKey('liveTrackingActionResume')), findsNothing);
    });

    testWidgets('shows resume and stop when paused', (tester) async {
      await tester.pumpWidget(
        wrap(
          LiveTrackingControlStrip(
            runtimeState: LiveTrackingRuntimeState.paused,
            isBusy: false,
            subtitle: 'Paused',
            onStart: () {},
            onPause: () {},
            onResume: () {},
            onStop: () {},
          ),
        ),
      );

      expect(find.byKey(const ValueKey('liveTrackingActionResume')),
          findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveTrackingActionStop')), findsOneWidget);
      expect(
          find.byKey(const ValueKey('liveTrackingActionPause')), findsNothing);
      expect(
          find.byKey(const ValueKey('liveTrackingActionStart')), findsNothing);
    });

    testWidgets('disables controls while action is in progress',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          LiveTrackingControlStrip(
            runtimeState: LiveTrackingRuntimeState.planned,
            isBusy: true,
            busyLabel: 'Starting...',
            subtitle: 'Not started',
            onStart: () {},
            onPause: () {},
            onResume: () {},
            onStop: () {},
          ),
        ),
      );

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('liveTrackingActionStart')),
      );
      expect(button.onPressed, isNull);
      expect(find.text('Starting...'), findsOneWidget);
    });

    testWidgets('disables controls when runtime state is unavailable',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          LiveTrackingControlStrip(
            runtimeState: LiveTrackingRuntimeState.planned,
            isBusy: false,
            controlsEnabled: false,
            subtitle: 'Checking tracking state...',
            onStart: () {},
            onPause: () {},
            onResume: () {},
            onStop: () {},
          ),
        ),
      );

      final button = tester.widget<FilledButton>(
        find.byKey(const ValueKey('liveTrackingActionStart')),
      );
      expect(button.onPressed, isNull);
      expect(find.text('Checking tracking state...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
