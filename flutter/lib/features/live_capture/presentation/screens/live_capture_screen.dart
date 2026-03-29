import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/features/live_capture/domain/live_capture_shell_state.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_action_dock.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_bottom_panel.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_map_canvas.dart';
import 'package:dora/features/live_capture/presentation/widgets/live_capture_top_bar.dart';

class LiveCaptureScreen extends StatelessWidget {
  const LiveCaptureScreen({
    super.key,
    required this.tripId,
    this.previewState = LiveCaptureShellState.planned,
  });

  final String tripId;
  final LiveCaptureShellState previewState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: LiveCaptureMapCanvas(),
          ),
          SafeArea(
            child: Stack(
              children: [
                LiveCaptureTopBar(
                  tripName: 'Trip $tripId',
                  state: previewState,
                  syncLabel: _syncLabel(previewState),
                  onBack: () => context.pop(),
                ),
                const Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md + 164,
                  child: _RecentEventsPlaceholder(),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      132,
                      0,
                      180,
                    ),
                    child: LiveCaptureActionDock(state: previewState),
                  ),
                ),
                LiveCaptureBottomPanel(state: previewState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _syncLabel(LiveCaptureShellState value) {
    switch (value) {
      case LiveCaptureShellState.active:
        return 'Syncing';
      case LiveCaptureShellState.blocked:
        return 'Sync blocked';
      case LiveCaptureShellState.paused:
        return 'Up to date';
      case LiveCaptureShellState.ended:
        return 'Synced';
      case LiveCaptureShellState.planned:
        return 'Ready';
    }
  }
}

class _RecentEventsPlaceholder extends StatelessWidget {
  const _RecentEventsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        key: const ValueKey('liveCaptureRecentEventsPlaceholder'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.bolt, size: 16),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Recent captures will appear here in the next slice.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
