import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/shared/widgets/shimmer.dart';

class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerBox(height: 80, width: 80, borderRadius: BorderRadius.all(Radius.circular(40))),
        SizedBox(height: AppSpacing.sm),
        ShimmerBox(height: 16, width: 120),
      ],
    );
  }
}

class StatsRowShimmer extends StatelessWidget {
  const StatsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        ShimmerBox(height: 28, width: 40),
        ShimmerBox(height: 28, width: 40),
        ShimmerBox(height: 28, width: 40),
        ShimmerBox(height: 28, width: 40),
      ],
    );
  }
}
