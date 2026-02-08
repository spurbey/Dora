import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/data/models/place_search_result.dart';

class PlaceSearchResultCard extends StatelessWidget {
  const PlaceSearchResultCard({
    super.key,
    required this.place,
    this.onTap,
    this.onAdd,
  });

  final PlaceSearchResult place;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.place, color: AppColors.accent),
      title: Text(place.name, style: AppTypography.h3),
      subtitle: Text(
        '${place.category}${place.address != null ? " · ${place.address}" : ""}',
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onAdd != null
          ? OutlinedButton(
              onPressed: onAdd,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(
                  AppSpacing.xxl + AppSpacing.lg,
                  AppSpacing.xl + AppSpacing.sm,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),
              child: const Text('+ Add'),
            )
          : null,
    );
  }
}
