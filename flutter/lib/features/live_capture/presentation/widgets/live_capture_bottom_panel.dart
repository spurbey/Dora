import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
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
                if (isBusy) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: controls,
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
          OutlinedButton.icon(
            key: const ValueKey('liveCaptureControlPause'),
            onPressed: actionEnabled ? onPause : null,
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Pause'),
          ),
          FilledButton.tonalIcon(
            key: const ValueKey('liveCaptureControlStop'),
            onPressed: actionEnabled ? onStop : null,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Stop'),
          ),
        ];
      case LiveCaptureShellState.paused:
        return [
          FilledButton.icon(
            key: const ValueKey('liveCaptureControlResume'),
            onPressed: actionEnabled ? onResume : null,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Resume'),
          ),
          OutlinedButton.icon(
            key: const ValueKey('liveCaptureControlStop'),
            onPressed: actionEnabled ? onStop : null,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Stop'),
          ),
        ];
      case LiveCaptureShellState.ended:
        return [
          FilledButton.icon(
            key: const ValueKey('liveCaptureControlStartNew'),
            onPressed: actionEnabled ? onStart : null,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start New Session'),
          ),
          OutlinedButton.icon(
            key: const ValueKey('liveCaptureControlOpenEditor'),
            onPressed: actionEnabled ? onOpenEditor : null,
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Open Editor'),
          ),
        ];
      case LiveCaptureShellState.blocked:
        return [
          FilledButton.tonalIcon(
            key: const ValueKey('liveCaptureControlRetry'),
            onPressed: actionEnabled ? onRetrySync : null,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry Sync'),
          ),
          OutlinedButton.icon(
            key: const ValueKey('liveCaptureControlReview'),
            onPressed: actionEnabled ? onOpenEditor : null,
            icon: const Icon(Icons.rule_folder_outlined, size: 16),
            label: const Text('Review Issues'),
          ),
        ];
      case LiveCaptureShellState.planned:
        return [
          FilledButton.icon(
            key: const ValueKey('liveCaptureControlStart'),
            onPressed: actionEnabled ? onStart : null,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Start Tracking'),
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
