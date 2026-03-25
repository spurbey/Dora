import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';

class LiveTrackingControlStrip extends StatelessWidget {
  const LiveTrackingControlStrip({
    super.key,
    required this.runtimeState,
    required this.isBusy,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    this.controlsEnabled = true,
    this.subtitle,
    this.busyLabel,
  });

  final LiveTrackingRuntimeState runtimeState;
  final bool isBusy;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final bool controlsEnabled;
  final String? subtitle;
  final String? busyLabel;

  @override
  Widget build(BuildContext context) {
    final (stateLabel, stateColor, stateIcon) =
        _statePresentation(runtimeState);
    final actions = _buildActions();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      padding: AppSpacing.allSm,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                stateIcon,
                size: 16,
                color: stateColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                stateLabel,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isBusy) ...[
                const SizedBox(width: AppSpacing.sm),
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                if (busyLabel != null && busyLabel!.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      busyLabel!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: actions,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    final actionEnabled = controlsEnabled && !isBusy;
    switch (runtimeState) {
      case LiveTrackingRuntimeState.active:
        return [
          OutlinedButton.icon(
            key: const ValueKey('liveTrackingActionPause'),
            onPressed: actionEnabled ? onPause : null,
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('Pause'),
          ),
          FilledButton.tonalIcon(
            key: const ValueKey('liveTrackingActionStop'),
            onPressed: actionEnabled ? onStop : null,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Stop'),
          ),
        ];
      case LiveTrackingRuntimeState.paused:
        return [
          FilledButton.icon(
            key: const ValueKey('liveTrackingActionResume'),
            onPressed: actionEnabled ? onResume : null,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('Resume'),
          ),
          OutlinedButton.icon(
            key: const ValueKey('liveTrackingActionStop'),
            onPressed: actionEnabled ? onStop : null,
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('Stop'),
          ),
        ];
      case LiveTrackingRuntimeState.planned:
      case LiveTrackingRuntimeState.ended:
        return [
          FilledButton.icon(
            key: const ValueKey('liveTrackingActionStart'),
            onPressed: actionEnabled ? onStart : null,
            icon: const Icon(Icons.play_arrow, size: 16),
            label: Text(
              runtimeState == LiveTrackingRuntimeState.ended
                  ? 'Start New Session'
                  : 'Start Tracking',
            ),
          ),
        ];
    }
  }

  (String, Color, IconData) _statePresentation(LiveTrackingRuntimeState state) {
    switch (state) {
      case LiveTrackingRuntimeState.active:
        return ('Tracking Active', AppColors.success, Icons.gps_fixed);
      case LiveTrackingRuntimeState.paused:
        return ('Tracking Paused', AppColors.warning, Icons.pause_circle);
      case LiveTrackingRuntimeState.ended:
        return ('Tracking Ended', AppColors.textSecondary, Icons.flag);
      case LiveTrackingRuntimeState.planned:
        return ('Tracking Not Started', AppColors.textSecondary, Icons.route);
    }
  }
}
