import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/features/live_capture/presentation/widgets/live_capture_transient_effects.dart';

Widget _wrap(
  Stream<TransientEffect> stream, {
  bool cancelAll = false,
  bool disableAnimations = false,
}) {
  final child = LiveCaptureTransientEffects(
    stream: stream,
    cancelAll: cancelAll,
  );
  return MaterialApp(
    home: Scaffold(
      body: disableAnimations
          ? MediaQuery(
              data: const MediaQueryData(disableAnimations: true),
              child: child,
            )
          : child,
    ),
  );
}

void main() {
  group('LiveCaptureTransientEffects', () {
    testWidgets('reduced-motion: no burst rendered when disableAnimations is true',
        (tester) async {
      final ctrl = StreamController<TransientEffect>.broadcast();
      addTearDown(ctrl.close);

      await tester.pumpWidget(
        _wrap(ctrl.stream, disableAnimations: true),
      );

      ctrl.add(const TransientEffect(TransientEffectType.photoCaptured));
      await tester.pump();

      // Widget returns SizedBox.shrink — no Lottie widget in the tree.
      expect(
        find.byKey(
          const ValueKey('liveCaptureTransientEffect_photoCaptured'),
        ),
        findsNothing,
      );
    });

    testWidgets('cancelAll clears an in-progress effect', (tester) async {
      final ctrl = StreamController<TransientEffect>.broadcast();
      addTearDown(ctrl.close);

      await tester.pumpWidget(_wrap(ctrl.stream));
      ctrl.add(const TransientEffect(TransientEffectType.photoCaptured));
      // Let Lottie asset load and first frame render.
      await tester.pump(const Duration(milliseconds: 100));

      // Now flip cancelAll = true — effect should clear.
      await tester.pumpWidget(_wrap(ctrl.stream, cancelAll: true));
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey('liveCaptureTransientEffect_photoCaptured'),
        ),
        findsNothing,
      );
    });

    testWidgets('photo burst renders without crash and clears after duration',
        (tester) async {
      final ctrl = StreamController<TransientEffect>.broadcast();
      addTearDown(ctrl.close);

      await tester.pumpWidget(_wrap(ctrl.stream));

      ctrl.add(const TransientEffect(TransientEffectType.photoCaptured));
      await tester.pump(const Duration(milliseconds: 100));

      // Burst widget is present while animation is running.
      expect(
        find.byKey(
          const ValueKey('liveCaptureTransientEffect_photoCaptured'),
        ),
        findsOneWidget,
      );

      // Advance past the full 2500ms duration — effect should clear.
      await tester.pump(const Duration(milliseconds: 2600));

      expect(
        find.byKey(
          const ValueKey('liveCaptureTransientEffect_photoCaptured'),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
