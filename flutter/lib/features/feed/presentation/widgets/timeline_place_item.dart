import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';

class TimelinePlaceItem extends StatelessWidget {
  const TimelinePlaceItem({
    super.key,
    required this.place,
    required this.onSave,
  });

  final TripPlace place;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.verticalMd,
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (place.dayNumber != null) ...[
            Text(
              'Day ${place.dayNumber}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              const Icon(Icons.place, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  place.name,
                  style: AppTypography.h3,
                ),
              ),
            ],
          ),
          if (place.notes != null && place.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              place.notes!,
              style: AppTypography.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (place.photoUrls.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: place.photoUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(right: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: AppRadius.borderSm,
                      child: CachedNetworkImage(
                        imageUrl: place.photoUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(
                  AppSpacing.xxl +
                      AppSpacing.xl +
                      AppSpacing.lg +
                      AppSpacing.md,
                  AppSpacing.xl + AppSpacing.sm,
                ),
              ),
              child: const Text('Save to trip'),
            ),
          ),
        ],
      ),
    );
  }
}
