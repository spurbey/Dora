import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_shadows.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';

class TimelineRouteItem extends StatelessWidget {
  const TimelineRouteItem({
    super.key,
    required this.route,
    required this.onCopy,
  });

  final TripRoute route;
  final VoidCallback onCopy;

  IconData get _transportIcon {
    switch (route.transportMode) {
      case 'bike':
        return Icons.directions_bike;
      case 'walk':
        return Icons.directions_walk;
      case 'air':
        return Icons.flight;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.verticalMd,
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_transportIcon, color: AppColors.accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${route.distance?.toStringAsFixed(1) ?? "?"} km',
                  style: AppTypography.h3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${route.duration ?? "?"} min · ${route.transportMode ?? "car"}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onCopy,
              style: OutlinedButton.styleFrom(
                minimumSize: Size(
                  AppSpacing.xxl +
                      AppSpacing.xl +
                      AppSpacing.lg +
                      AppSpacing.md,
                  AppSpacing.xl + AppSpacing.sm,
                ),
              ),
              child: const Text('Copy route'),
            ),
          ),
        ],
      ),
    );
  }
}
