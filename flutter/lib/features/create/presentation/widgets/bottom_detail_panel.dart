import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

const double _handleHeight = 56.0;
const double _contentHeight = 284.0;

class BottomDetailPanel extends StatelessWidget {
  const BottomDetailPanel({
    super.key,
    required this.expanded,
    required this.onToggle,
    this.child,
    this.selectedItemName,
    this.selectedItemIcon,
    this.statusText,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final Widget? child;
  final String? selectedItemName;
  final IconData? selectedItemIcon;
  final String? statusText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IgnorePointer(
          child: Container(
            width: double.infinity,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: double.infinity,
          height: expanded ? _handleHeight + _contentHeight : _handleHeight,
          clipBehavior: Clip.hardEdge,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _handleHeight,
                child: GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        if (selectedItemName != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                selectedItemIcon ?? Icons.place,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  selectedItemName!,
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                expanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_up,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          if (statusText != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              statusText!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.accent,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: AppSpacing.xs),
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
              ),
              ClipRect(
                child: SizedBox(
                  height: expanded ? _contentHeight : 0,
                  child: IgnorePointer(
                    ignoring: !expanded,
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
