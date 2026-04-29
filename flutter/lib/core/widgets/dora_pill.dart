import 'package:flutter/material.dart';

import 'package:dora/core/theme/dora_theme.dart';

/// Circular gradient pill with optional badge dot and tap handler.
///
/// Used for the Dora top-left pill, the dimensional mode toggle, and any
/// other circular floating chrome. Renders a [child] (typically a
/// [CustomPainter]-drawn icon) centered inside a gradient circle.
///
/// **Animation:** breathing pulse can be enabled via [pulse]. Single
/// [AnimationController] drives subtle scale 1.0 → 1.04 → 1.0 over 4s.
class DoraPill extends StatefulWidget {
  const DoraPill({
    super.key,
    required this.child,
    this.size = 60,
    this.gradientColors = const [
      DoraColors.brandPrimary,
      DoraColors.brandAccent,
    ],
    this.shadows = DoraShadow.tight,
    this.badgeColor,
    this.pulse = false,
    this.onTap,
    this.semanticsLabel,
  });

  final Widget child;
  final double size;
  final List<Color> gradientColors;
  final List<BoxShadow> shadows;

  /// When non-null, paints a small dot in the top-right (e.g. amber for
  /// "has-message" state). 12px circle.
  final Color? badgeColor;

  /// When true, plays a 4-second breathing pulse loop (scale 1.0 → 1.04 → 1.0).
  final bool pulse;

  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  State<DoraPill> createState() => _DoraPillState();
}

class _DoraPillState extends State<DoraPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.pulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant DoraPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pill = AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: widget.pulse ? _scale.value : 1.0,
        child: child,
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 1.0,
            colors: widget.gradientColors,
          ),
          boxShadow: widget.shadows,
        ),
        child: Center(child: widget.child),
      ),
    );

    Widget tree = pill;

    if (widget.badgeColor != null) {
      tree = Stack(
        clipBehavior: Clip.none,
        children: [
          tree,
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.badgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: DoraColors.surfaceWhite,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.onTap != null) {
      tree = Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: widget.onTap,
          customBorder: const CircleBorder(),
          child: tree,
        ),
      );
    }

    if (widget.semanticsLabel != null) {
      tree = Semantics(
        label: widget.semanticsLabel,
        button: widget.onTap != null,
        child: tree,
      );
    }

    return tree;
  }
}
