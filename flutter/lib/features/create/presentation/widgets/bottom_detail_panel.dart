import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class BottomDetailPanel extends StatelessWidget {
  const BottomDetailPanel({
    super.key,
    required this.expanded,
    required this.onToggle,
    this.child,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: expanded ? 320 : 64,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.sheetTop,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              height: 24,
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: AppRadius.borderSm,
                ),
              ),
            ),
          ),
          if (!expanded)
            Padding(
              padding: AppSpacing.verticalSm,
              child: Text(
                'Tap to view details',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Expanded(
              child: child ??
                  Center(
                    child: Text(
                      'Select a place or route',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}
