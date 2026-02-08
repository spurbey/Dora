import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/features/trips/domain/trips_state.dart';

class ViewModeToggle extends StatelessWidget {
  const ViewModeToggle({
    super.key,
    required this.viewMode,
    required this.onChanged,
  });

  final TripsViewMode viewMode;
  final ValueChanged<TripsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.grid_view,
            isActive: viewMode == TripsViewMode.grid,
            onTap: () => onChanged(TripsViewMode.grid),
          ),
          const SizedBox(width: AppSpacing.xs),
          _ToggleButton(
            icon: Icons.view_list,
            isActive: viewMode == TripsViewMode.list,
            onTap: () => onChanged(TripsViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentSoft : Colors.transparent,
          borderRadius: AppRadius.borderMd,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
}
