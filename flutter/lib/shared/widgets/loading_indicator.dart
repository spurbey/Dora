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
      duration: const Duration(milliseconds: 960),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicator = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final bars = List<Widget>.generate(3, (index) {
          final wave = (_controller.value + (index * 0.18)) * math.pi * 2;
          final intensity = (math.sin(wave) + 1) / 2;
          final barHeight =
              (widget.size * 0.26) + (widget.size * 0.34 * intensity);
          final opacity = 0.35 + (0.65 * intensity);

          return Container(
            width: widget.size * 0.2,
            height: barHeight,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        });

        final content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.size * 0.62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  bars[0],
                  SizedBox(width: widget.size * 0.13),
                  bars[1],
                  SizedBox(width: widget.size * 0.13),
                  bars[2],
                ],
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label!,
                style: AppTypography.caption.copyWith(color: widget.labelColor),
              ),
            ],
          ],
        );

        if (widget.centered) {
          return Center(child: content);
        }

        return content;
      },
    );

    return Semantics(
      label: widget.label ?? 'Loading',
      child: SizedBox(
        width: widget.size * 2.2,
        child: indicator,
      ),
    );
  }
}
