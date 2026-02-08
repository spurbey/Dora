import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/data/models/public_trip.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final PublicTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: AppSpacing.verticalMd,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.md),
              ),
              child: AspectRatio(
                aspectRatio: 5 / 3,
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
            Padding(
              padding: AppSpacing.allMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.name, style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '📸 ${trip.placeCount} places'
                    '${trip.duration != null ? ' · ${trip.duration} days' : ''}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'by @${trip.username}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
