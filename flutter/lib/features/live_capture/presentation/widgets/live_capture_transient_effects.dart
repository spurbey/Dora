import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// One-shot visual burst types for live capture actions.
enum TransientEffectType { photoCaptured, warnCaptured }

/// Carries the effect type from the screen to the overlay.
class TransientEffect {
  const TransientEffect(this.type);
  final TransientEffectType type;
}

/// Full-screen overlay that plays a one-shot Lottie burst on capture events.
///
/// - Driven by a [Stream<TransientEffect>] from the parent screen.
/// - [cancelAll] clears any in-progress animation (set true when sync is blocked).
/// - Reduced-motion: renders nothing when [MediaQueryData.disableAnimations] is true.
/// - Pointer-transparent: never intercepts touches.
class LiveCaptureTransientEffects extends StatefulWidget {
  const LiveCaptureTransientEffects({
    super.key,
    required this.stream,
    this.cancelAll = false,
  });

  final Stream<TransientEffect> stream;

  /// When flipped to true, any in-progress burst is immediately cleared.
  final bool cancelAll;

  @override
  State<LiveCaptureTransientEffects> createState() =>
      _LiveCaptureTransientEffectsState();
}

class _LiveCaptureTransientEffectsState
    extends State<LiveCaptureTransientEffects>
    with SingleTickerProviderStateMixin {
  StreamSubscription<TransientEffect>? _sub;
  TransientEffect? _current;
  late final AnimationController _ctrl;

  /// Half of the raw Lottie duration (5000ms → 2500ms).
  static const Duration _photoDuration = Duration(milliseconds: 2500);

  /// Half of the raw Lottie duration (3000ms → 1500ms).
  static const Duration _warnDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _ctrl.addStatusListener(_onAnimationStatus);
    _sub = widget.stream.listen(_onEffect);
  }

  @override
  void didUpdateWidget(LiveCaptureTransientEffects old) {
    super.didUpdateWidget(old);
    if (widget.cancelAll && !old.cancelAll) {
      _clearEffect();
    }
  }

  void _onEffect(TransientEffect effect) {
    if (!mounted) return;
    setState(() => _current = effect);
    _ctrl.stop();
    _ctrl.reset();
    _ctrl.duration = effect.type == TransientEffectType.photoCaptured
        ? _photoDuration
        : _warnDuration;
    _ctrl.forward();
  }

  void _clearEffect() {
    _ctrl.stop();
    if (mounted) setState(() => _current = null);
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) setState(() => _current = null);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return const SizedBox.shrink();
    final current = _current;
    if (current == null) return const SizedBox.shrink();

    final asset = current.type == TransientEffectType.photoCaptured
        ? 'assets/lottie/live_capture_photo_burst.json'
        : 'assets/lottie/live_capture_warn_burst.json';

    return IgnorePointer(
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            asset,
            key: ValueKey('liveCaptureTransientEffect_${current.type.name}'),
            controller: _ctrl,
            repeat: false,
          ),
        ),
      ),
    );
  }
}
