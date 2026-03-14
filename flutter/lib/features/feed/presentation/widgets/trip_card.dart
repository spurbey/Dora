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

  static String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = trip.coverPhotoUrl?.trim();
    final hasCover = coverUrl != null && coverUrl.isNotEmpty;

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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasCover)
                      CachedNetworkImage(
                        imageUrl: coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, _) => Container(
                          color: AppColors.divider,
                        ),
                        errorWidget: (context, _, __) => _FallbackCover(trip: trip),
                      )
                    else
                      _FallbackCover(trip: trip),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.52),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Row(
                        children: [
                          if (trip.placeCount > 0) ...[
                            const Icon(Icons.place,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 3),
                            Text(
                              '${trip.placeCount}',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          if (trip.duration != null && trip.duration! > 0) ...[
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              '${trip.duration}d',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          const Spacer(),
                          if (trip.viewCount > 0) ...[
                            const Icon(Icons.visibility_outlined,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 3),
                            Text(
                              _formatCount(trip.viewCount),
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.allMd,
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
                    '@${trip.username}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  if (trip.description != null &&
                      trip.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      trip.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (trip.tags.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: trip.tags
                          .take(3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentSoft,
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: Text(
                                tag,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accent,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover({required this.trip});

  final PublicTrip trip;

  @override
  Widget build(BuildContext context) {
    final seed = trip.name.runes.fold<int>(0, (sum, rune) => sum + rune);
    final hue = seed % 360;
    final primary = HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.42).toColor();
    final secondary = HSLColor.fromAHSL(1, (hue + 32).toDouble() % 360, 0.45, 0.34).toColor();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, secondary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.landscape,
          size: 40,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
