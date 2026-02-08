import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/trips/domain/trips_state.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TripsFilter selected;
  final ValueChanged<TripsFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = TripsFilter.values;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.horizontalMd,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onChanged(filter),
            labelStyle: AppTypography.caption.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            backgroundColor: AppColors.card,
            selectedColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderLg,
              side: BorderSide(
                color: isSelected ? AppColors.accent : AppColors.divider,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemCount: filters.length,
      ),
    );
  }
}
