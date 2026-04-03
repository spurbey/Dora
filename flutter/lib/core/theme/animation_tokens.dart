import 'package:flutter/animation.dart';

/// Canonical animation token source for live capture runtime surfaces.
///
/// All durations and curves used in live capture widgets MUST come from here.
/// Do NOT hardcode Duration or Curve values in live capture code.
///
/// Authority: flutter/docs/live-capture-animation-contract.md §3 + §6
class AnimationTokens {
  AnimationTokens._();

  // ── Duration classes ───────────────────────────────────────────────────────
  /// 120ms — critical action acknowledgement, tap feedback, sync flash.
  static const Duration fast = Duration(milliseconds: 120);

  /// 180ms — standard overlay transitions, enable/disable state changes.
  static const Duration normal = Duration(milliseconds: 180);

  /// 260ms — screen entrance, state badge crossfade, panel transitions.
  static const Duration slow = Duration(milliseconds: 260);

  // ── Easing curves ─────────────────────────────────────────────────────────
  /// Default for most transitions: clean deceleration out.
  static const Curve standard = Curves.easeOutCubic;

  /// Elements entering the screen: decelerate into final position.
  static const Curve decelerate = Curves.easeOut;

  /// Elements leaving the screen: accelerate away.
  static const Curve accelerate = Curves.easeIn;

  /// State changes with perceptible weight (badge, panel headline).
  static const Curve emphasized = Curves.easeInOutCubic;

  // ── Map-layer constants (int ms, passed to Mapbox MapAnimationOptions) ─────
  /// GPS marker position interpolation between consecutive points.
  static const int markerLerpMs = 160;

  /// Route line growth per new path segment.
  static const int pathSegmentMs = 140;

  /// Camera flyTo duration for explicit recenter tap only.
  /// Do NOT use for passive GPS follow (use easeTo with a shorter value).
  static const int cameraRecenterMs = 420;
}
