import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/theme/animation_tokens.dart';

/// Token drift guard — Slice G contract.
///
/// These assertions lock the canonical animation values defined in the
/// animation contract (live-capture-animation-contract.md §6.1).
/// If a value changes, this test fails intentionally so the change is
/// reviewed and docs are updated before merging.
void main() {
  group('AnimationTokens — duration contract', () {
    test('fast is exactly 120ms', () {
      expect(AnimationTokens.fast, const Duration(milliseconds: 120));
    });

    test('normal is exactly 180ms', () {
      expect(AnimationTokens.normal, const Duration(milliseconds: 180));
    });

    test('slow is exactly 260ms', () {
      expect(AnimationTokens.slow, const Duration(milliseconds: 260));
    });
  });

  group('AnimationTokens — curve contract', () {
    test('standard is Curves.easeOutCubic', () {
      expect(AnimationTokens.standard, Curves.easeOutCubic);
    });

    test('decelerate is Curves.easeOut', () {
      expect(AnimationTokens.decelerate, Curves.easeOut);
    });

    test('accelerate is Curves.easeIn', () {
      expect(AnimationTokens.accelerate, Curves.easeIn);
    });

    test('emphasized is Curves.easeInOutCubic', () {
      expect(AnimationTokens.emphasized, Curves.easeInOutCubic);
    });
  });

  group('AnimationTokens — map constants contract', () {
    test('markerLerpMs is 160', () {
      expect(AnimationTokens.markerLerpMs, 160);
    });

    test('pathSegmentMs is 140', () {
      expect(AnimationTokens.pathSegmentMs, 140);
    });

    test('cameraRecenterMs is 420', () {
      expect(AnimationTokens.cameraRecenterMs, 420);
    });
  });
}
