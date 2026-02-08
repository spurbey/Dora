import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/utils/date_time_utils.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

class TripListCard extends StatelessWidget {
  const TripListCard({
    super.key,
    required this.trip,
    required this.onTap,
    required this.onMenuTap,
  });

  final UserTrip trip;
  final VoidCallback onTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final lastEdited = trip.lastEditedAt ?? trip.localUpdatedAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.verticalSm,
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: AppRadius.borderMd,
              child: SizedBox(
                width: 80,
                height: 80,
                child: CachedNetworkImage(
                  imageUrl: trip.coverPhotoUrl ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, _) => Container(
                    color: AppColors.divider,
                  ),
                  errorWidget: (context, _, __) => Container(
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: AppTypography.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateTimeUtils.formatTripMeta(
                      placeCount: trip.placeCount,
                      durationDays: trip.durationDays,
                    ),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Last edited ${DateTimeUtils.formatRelativeTime(lastEdited)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: AppColors.textSecondary,
              onPressed: onMenuTap,
            ),
          ],
        ),
      ),
    );
  }
}
