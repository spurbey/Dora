import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline,
                size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('Profile', style: AppTypography.h2),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Coming in Phase 2',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
