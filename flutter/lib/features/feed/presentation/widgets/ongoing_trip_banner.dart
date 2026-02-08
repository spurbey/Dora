import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class OngoingTripBanner extends StatelessWidget {
  const OngoingTripBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.verticalMd,
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: AppColors.accent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Continue Your Journey',
              style: AppTypography.h3.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Continue editing →',
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
