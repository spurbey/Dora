import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';

class LiveCaptureTopBar extends StatelessWidget {
  const LiveCaptureTopBar({
    super.key,
    required this.tripName,
    required this.state,
    required this.syncLabel,
    required this.onBack,
  });

  final String tripName;
  final LiveCaptureShellState state;
  final String syncLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final stateMeta = _stateMeta(state);
    return Container(
      key: const ValueKey('liveCaptureTopBar'),
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.9),
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('liveCaptureBack'),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tripName,
                  key: const ValueKey('liveCaptureTripName'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      key: const ValueKey('liveCaptureStateBadge'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: stateMeta.background,
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            stateMeta.icon,
                            size: 12,
                            color: stateMeta.foreground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stateMeta.label,
                            key: const ValueKey('liveCaptureStateLabel'),
                            style: AppTypography.caption.copyWith(
                              color: stateMeta.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      syncLabel,
                      key: const ValueKey('liveCaptureSyncLabel'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('liveCaptureMore'),
            onPressed: () {},
            icon: const Icon(Icons.more_vert, size: 20),
          ),
        ],
      ),
    );
  }

  _StateMeta _stateMeta(LiveCaptureShellState value) {
    switch (value) {
      case LiveCaptureShellState.active:
        return const _StateMeta(
          label: 'Active',
          icon: Icons.gps_fixed,
          foreground: AppColors.success,
          background: Color(0xFFE8F7F0),
        );
      case LiveCaptureShellState.paused:
        return const _StateMeta(
          label: 'Paused',
          icon: Icons.pause_circle,
          foreground: AppColors.warning,
          background: Color(0xFFFEF6E9),
        );
      case LiveCaptureShellState.ended:
        return const _StateMeta(
          label: 'Ended',
          icon: Icons.flag,
          foreground: AppColors.textSecondary,
          background: Color(0xFFEFEFEF),
        );
      case LiveCaptureShellState.blocked:
        return const _StateMeta(
          label: 'Sync Blocked',
          icon: Icons.error_outline,
          foreground: AppColors.error,
          background: Color(0xFFFDEBEC),
        );
      case LiveCaptureShellState.planned:
        return const _StateMeta(
          label: 'Ready',
          icon: Icons.play_circle_outline,
          foreground: AppColors.accent,
          background: Color(0xFFE8F4F5),
        );
    }
  }
}

class _StateMeta {
  const _StateMeta({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

