import 'package:flutter/material.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/core/widgets/dora_button.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';

class LiveCaptureBottomPanel extends StatelessWidget {
  const LiveCaptureBottomPanel({
    super.key,
    required this.state,
    this.isBusy = false,
    this.busyLabel,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onStop,
    this.onRetrySync,
    this.onOpenEditor,
  });

  final LiveCaptureShellState state;
  final bool isBusy;
  final String? busyLabel;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;
  final VoidCallback? onRetrySync;
  final VoidCallback? onOpenEditor;

  @override
  Widget build(BuildContext context) {
    final controls = _controls(state);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        key: const ValueKey('liveCaptureBottomPanel'),
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.94),
          borderRadius: AppRadius.borderXl,
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AnimationTokens.normal,
                    transitionBuilder: (child, anim) =>
                        FadeTransition(opacity: anim, child: child),
                    child: SizedBox(
                      key: ValueKey('headline_${state.name}'),
                      child: Text(
                        _headline(state),
                        key: const ValueKey('liveCapturePanelHeadline'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isBusy) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  ),
                  if (busyLabel != null && busyLabel!.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      busyLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            AnimatedSwitcher(
              duration: AnimationTokens.normal,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: SizedBox(
                key: ValueKey('controls_${state.name}'),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: controls,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _controls(LiveCaptureShellState state) {
    final actionEnabled = !isBusy;
    switch (state) {
      case LiveCaptureShellState.active:
        return [
          DoraButton(
            key: const ValueKey('liveCaptureControlPause'),
            label: 'Pause',
            icon: Icons.pause,
            onPressed: actionEnabled ? onPause : null,
            variant: DoraButtonVariant.outlined,
          ),
          DoraButton(
            key: const ValueKey('liveCaptureControlStop'),
            label: 'Stop',
            icon: Icons.stop,
            onPressed: actionEnabled ? onStop : null,
          ),
        ];
      case LiveCaptureShellState.paused:
        return [
          DoraButton(
            key: const ValueKey('liveCaptureControlResume'),
            label: 'Resume',
            icon: Icons.play_arrow,
            onPressed: actionEnabled ? onResume : null,
          ),
          DoraButton(
            key: const ValueKey('liveCaptureControlStop'),
            label: 'Stop',
            icon: Icons.stop,
            onPressed: actionEnabled ? onStop : null,
            variant: DoraButtonVariant.outlined,
          ),
        ];
      case LiveCaptureShellState.ended:
        return [
          DoraButton(
            key: const ValueKey('liveCaptureControlStartNew'),
            label: 'Start New Session',
            icon: Icons.play_arrow,
            onPressed: actionEnabled ? onStart : null,
          ),
          DoraButton(
            key: const ValueKey('liveCaptureControlOpenEditor'),
            label: 'Open Editor',
            icon: Icons.edit_outlined,
            onPressed: actionEnabled ? onOpenEditor : null,
            variant: DoraButtonVariant.outlined,
          ),
        ];
      case LiveCaptureShellState.blocked:
        return [
          DoraButton(
            key: const ValueKey('liveCaptureControlRetry'),
            label: 'Retry Sync',
            icon: Icons.refresh,
            onPressed: actionEnabled ? onRetrySync : null,
          ),
          DoraButton(
            key: const ValueKey('liveCaptureControlReview'),
            label: 'Review Issues',
            icon: Icons.rule_folder_outlined,
            onPressed: actionEnabled ? onOpenEditor : null,
            variant: DoraButtonVariant.outlined,
          ),
        ];
      case LiveCaptureShellState.planned:
        return [
          DoraButton(
            key: const ValueKey('liveCaptureControlStart'),
            label: 'Start Tracking',
            icon: Icons.play_arrow,
            onPressed: actionEnabled ? onStart : null,
          ),
        ];
    }
  }

  String _headline(LiveCaptureShellState state) {
    switch (state) {
      case LiveCaptureShellState.active:
        return 'Tracking active';
      case LiveCaptureShellState.paused:
        return 'Tracking paused';
      case LiveCaptureShellState.ended:
        return 'Session complete';
      case LiveCaptureShellState.blocked:
        return 'Sync needs attention';
      case LiveCaptureShellState.planned:
        return 'Ready to track';
    }
  }
}
