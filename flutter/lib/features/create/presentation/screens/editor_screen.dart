import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_location_alt_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text('Editor', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Coming in Phase 4',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
