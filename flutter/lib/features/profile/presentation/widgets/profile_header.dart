import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/profile/data/models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onAvatarTap,
  });

  final UserProfile profile;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.allLg,
      color: AppColors.surface,
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.divider,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null
                  ? const Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary,
                      size: 36,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(profile.username, style: AppTypography.h2),
        ],
      ),
    );
  }
}
