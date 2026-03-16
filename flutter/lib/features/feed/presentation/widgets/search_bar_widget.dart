import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.horizontalMd,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.borderMd,
          onTap: onTap,
          child: IgnorePointer(
            child: SearchBar(
              hintText: 'Plan, advise, or search...',
              leading: const Icon(Icons.explore, color: AppColors.accent),
              backgroundColor: WidgetStateProperty.all(AppColors.card),
              elevation: const WidgetStatePropertyAll(0),
              shape: WidgetStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
