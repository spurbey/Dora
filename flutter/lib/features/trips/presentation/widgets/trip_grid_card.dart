import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/utils/date_time_utils.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

class TripGridCard extends StatelessWidget {
  const TripGridCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  final UserTrip trip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastEdited = trip.lastEditedAt ?? trip.localUpdatedAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.borderMd,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                  child: AspectRatio(
                    aspectRatio: 157 / 120,
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
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: _StatusBadge(status: trip.status),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: AppTypography.h3,
                    maxLines: 2,
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
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = _statusLabel(status);
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.borderMd,
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'editing':
        return 'Editing';
      case 'completed':
        return 'Completed';
      case 'shared':
        return 'Public';
      default:
        return 'Editing';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'editing':
        return AppColors.warning;
      case 'completed':
        return AppColors.success;
      case 'shared':
        return AppColors.accent;
      default:
        return AppColors.warning;
    }
  }
}
