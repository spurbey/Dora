import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    super.key,
    this.size = 48.0,
    this.color = AppColors.accent,
    this.label,
    this.labelColor = AppColors.textSecondary,
    this.centered = true,
  });

  final double size;
  final Color color;
  final String? label;
  final Color labelColor;
  final bool centered;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = (widget.size * 0.16).clamp(4.0, 10.0);
    final trailWidth = widget.size * 1.25;
    final lineColor = widget.color.withValues(alpha: 0.14);

    final animated = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final dots = List<Widget>.generate(3, (index) {
          final phase = (_controller.value + (index * 0.2)) * math.pi * 2;
          final wave = (math.sin(phase) + 1) / 2;
          final opacity = 0.28 + (0.52 * wave);
          final scale = 0.84 + (0.22 * wave);

          return Transform.scale(
            scale: scale,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: opacity),
              ),
            ),
          );
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: trailWidth,
              height: dotSize * 2.2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: trailWidth,
                    height: 2,
                    color: lineColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dots[0],
                      SizedBox(width: dotSize * 0.9),
                      dots[1],
                      SizedBox(width: dotSize * 0.9),
                      dots[2],
                    ],
                  ),
                ],
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label!,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: widget.labelColor),
              ),
            ],
          ],
        );
      },
    );

    final content = Semantics(
      label: widget.label ?? 'Loading',
      child: SizedBox(
        width: widget.size * 2.1,
        child: animated,
      ),
    );

    if (widget.centered) {
      return Center(child: content);
    }

    return content;
  }
}
