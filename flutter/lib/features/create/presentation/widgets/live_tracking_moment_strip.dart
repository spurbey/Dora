import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class LiveTrackingMomentStrip extends StatelessWidget {
  const LiveTrackingMomentStrip({
    super.key,
    required this.moments,
    required this.inFlightMomentIds,
    required this.canCapture,
    required this.captureInFlight,
    required this.onCaptureNow,
    required this.onEditMoment,
  });

  final List<TrackingMomentRow> moments;
  final Set<String> inFlightMomentIds;
  final bool canCapture;
  final bool captureInFlight;
  final VoidCallback onCaptureNow;
  final ValueChanged<TrackingMomentRow> onEditMoment;

  @override
  Widget build(BuildContext context) {
    if (moments.isEmpty && !canCapture) {
      return const SizedBox.shrink();
    }

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
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  moments.isEmpty
                      ? 'Moments'
                      : '${moments.length} moment${moments.length == 1 ? '' : 's'}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              FilledButton.tonal(
                key: const ValueKey('momentCaptureNow'),
                onPressed: canCapture && !captureInFlight ? onCaptureNow : null,
                child: Text(captureInFlight ? 'Capturing...' : 'Capture now'),
              ),
            ],
          ),
          if (moments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final moment in moments.take(3))
              _buildMomentTile(moment: moment),
            if (moments.length > 3) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${moments.length - 3} more moment(s)',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMomentTile({
    required TrackingMomentRow moment,
  }) {
    final isBusy = inFlightMomentIds.contains(moment.id);
    final title = moment.note?.trim().isNotEmpty == true
        ? moment.note!.trim()
        : 'Moment at ${_formatTime(moment.capturedAt)}';
    final details = [
      _sourceLabel(moment.source),
      _formatTime(moment.capturedAt),
      if (moment.syncStatus == 'pending' || moment.pendingOperation != null)
        'Sync pending',
    ].join(' | ');

    return Container(
      key: ValueKey('momentTile_${moment.id}'),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  details,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            key: ValueKey('momentEdit_${moment.id}'),
            onPressed: isBusy ? null : () => onEditMoment(moment),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  static String _sourceLabel(String source) {
    switch (source) {
      case 'auto':
        return 'Auto';
      case 'edited_auto':
        return 'Edited';
      case 'manual':
      default:
        return 'Manual';
    }
  }

  static String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
