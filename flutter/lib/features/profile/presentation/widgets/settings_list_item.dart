import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    super.key,
    required this.title,
    this.value,
    required this.onTap,
    this.trailing,
    this.icon,
    this.accentColor = AppColors.accent,
    this.isDestructive = false,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;
  final Widget? trailing;
  final IconData? icon;
  final Color accentColor;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive ? AppColors.error : AppColors.textPrimary;
    final subtitleColor =
        isDestructive ? AppColors.error : AppColors.textSecondary;
    final iconColor = isDestructive ? AppColors.error : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.borderLg,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 12,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.13),
                    borderRadius: AppRadius.borderMd,
                    border:
                        Border.all(color: iconColor.withValues(alpha: 0.24)),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (value != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        value!,
                        style: AppTypography.caption.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: subtitleColor,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
