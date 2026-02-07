import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.book_outlined,
                size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text('My Trips', style: AppTypography.h2),
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
