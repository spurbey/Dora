import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';

/// Small circular brand avatar for "Dora" — the explorer guide persona.
///
/// Uses a gradient background with a compass icon. Size parameter controls
/// both diameter and icon size proportionally. Used in chat panel header,
/// message bubbles, and notification banners.
class DoraAvatar extends StatelessWidget {
  const DoraAvatar({
    super.key,
    this.size = 40,
    this.showPulse = false,
  });

  final double size;
  final bool showPulse;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.55;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            Color(0xFF2B8994),
          ],
        ),
        boxShadow: [
          if (showPulse)
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.35),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(
        Icons.explore_outlined,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}
