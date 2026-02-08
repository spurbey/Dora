import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/shared/widgets/shimmer.dart';

class TripGridCardShimmer extends StatelessWidget {
  const TripGridCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(
          height: 120,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.md),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ShimmerBox(
          height: 14,
          width: MediaQuery.of(context).size.width * 0.4,
        ),
        const SizedBox(height: AppSpacing.xs),
        const ShimmerBox(height: 12, width: 120),
        const SizedBox(height: AppSpacing.xs),
        const ShimmerBox(height: 12, width: 160),
      ],
    );
  }
}

class TripListCardShimmer extends StatelessWidget {
  const TripListCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ShimmerBox(
          height: 80,
          width: 80,
          borderRadius: AppRadius.borderMd,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(height: 14, width: 140),
              SizedBox(height: AppSpacing.xs),
              ShimmerBox(height: 12, width: 120),
              SizedBox(height: AppSpacing.xs),
              ShimmerBox(height: 12, width: 160),
            ],
          ),
        ),
      ],
    );
  }
}
