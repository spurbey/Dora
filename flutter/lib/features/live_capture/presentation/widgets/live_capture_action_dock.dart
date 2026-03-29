import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';

class LiveCaptureActionDock extends StatelessWidget {
  const LiveCaptureActionDock({
    super.key,
    required this.state,
    this.isBusy = false,
    this.onPhoto,
    this.onNote,
    this.onWarn,
    this.onMedia,
    this.onTag,
  });

  final LiveCaptureShellState state;
  final bool isBusy;
  final VoidCallback? onPhoto;
  final VoidCallback? onNote;
  final VoidCallback? onWarn;
  final VoidCallback? onMedia;
  final VoidCallback? onTag;

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionMeta>[
      _ActionMeta(
        key: const ValueKey('liveCaptureActionPhoto'),
        icon: Icons.photo_camera_outlined,
        label: 'Photo',
        onTap: onPhoto,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionNote'),
        icon: Icons.note_add_outlined,
        label: 'Note',
        onTap: onNote,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionWarn'),
        icon: Icons.warning_amber_rounded,
        label: 'Warn',
        onTap: onWarn,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionMedia'),
        icon: Icons.videocam_outlined,
        label: 'Media',
        onTap: onMedia,
      ),
      _ActionMeta(
        key: const ValueKey('liveCaptureActionTag'),
        icon: Icons.place_outlined,
        label: 'Tag',
        onTap: onTag,
      ),
    ];

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        key: const ValueKey('liveCaptureActionDock'),
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.88),
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.75)),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map((action) => Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: _ActionPill(
                        key: action.key,
                        icon: action.icon,
                        label: action.label,
                        enabled: _isActionEnabled(
                              state: state,
                              actionKey: action.key,
                            ) &&
                            !isBusy &&
                            action.onTap != null,
                        onTap: action.onTap,
                      ),
                    ))
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  bool _isActionEnabled({
    required LiveCaptureShellState state,
    required ValueKey<String> actionKey,
  }) {
    switch (state) {
      case LiveCaptureShellState.active:
        return true;
      case LiveCaptureShellState.paused:
        return actionKey == const ValueKey('liveCaptureActionNote');
      case LiveCaptureShellState.planned:
      case LiveCaptureShellState.ended:
      case LiveCaptureShellState.blocked:
        return false;
    }
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground =
        enabled ? AppColors.textPrimary : AppColors.textSecondary;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: AppRadius.borderLg,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.surface
              : AppColors.surface.withValues(alpha: 0.7),
          borderRadius: AppRadius.borderLg,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionMeta {
  const _ActionMeta({
    required this.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final ValueKey<String> key;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}
