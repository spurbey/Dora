import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class BottomDetailPanel extends StatelessWidget {
  const BottomDetailPanel({
    super.key,
    required this.expanded,
    required this.onToggle,
    this.child,
    this.selectedItemName,
    this.selectedItemIcon,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final Widget? child;
  final String? selectedItemName;
  final IconData? selectedItemIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top shadow gradient — separates panel from map
        IgnorePointer(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.06),
                ],
              ),
            ),
          ),
        ),
        // Panel
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          constraints: BoxConstraints(
            maxHeight: expanded ? 340 : 56,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.sheetTop,
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, -4),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle + collapsed preview
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      if (!expanded && selectedItemName != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedItemIcon ?? Icons.place,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              selectedItemName!,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.keyboard_arrow_up,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                      if (!expanded && selectedItemName == null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Tap to view details',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Content
              if (expanded)
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
        ),
      ],
    );
  }
}
