import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/domain/place.dart';

/// Modal bottom sheet for picking a place (start or destination) during route creation.
class PlacePickerSheet extends StatelessWidget {
  const PlacePickerSheet({
    super.key,
    required this.title,
    required this.places,
    required this.onPick,
    this.excludeId,
  });

  final String title;
  final List<Place> places;
  final ValueChanged<String> onPick;
  final String? excludeId;

  @override
  Widget build(BuildContext context) {
    final eligible = excludeId == null
        ? places
        : places.where((p) => p.id != excludeId).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(
              top: AppSpacing.sm,
              bottom: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: AppTypography.h3),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Place list
        if (eligible.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'No places available. Add places to your trip first.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: eligible.length,
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              itemBuilder: (context, index) {
                final place = eligible[index];
                final isCity = place.placeType == 'city';
                return _PlaceTile(
                  name: place.name,
                  isCity: isCity,
                  onTap: () {
                    onPick(place.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({
    required this.name,
    required this.isCity,
    required this.onTap,
  });

  final String name;
  final bool isCity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (isCity ? AppColors.primary : AppColors.accent)
                    .withValues(alpha: 0.12),
                borderRadius: AppRadius.borderSm,
              ),
              child: Icon(
                isCity ? Icons.location_city : Icons.place,
                size: 18,
                color: isCity ? AppColors.primary : AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                name,
                style: AppTypography.body.copyWith(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
