import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class LiveTrackingCandidateInboxStrip extends StatelessWidget {
  const LiveTrackingCandidateInboxStrip({
    super.key,
    required this.candidates,
    required this.inFlightCandidateIds,
    required this.onConfirm,
    required this.onReject,
    required this.onSnooze,
  });

  final List<TrackingCandidateRow> candidates;
  final Set<String> inFlightCandidateIds;
  final ValueChanged<String> onConfirm;
  final ValueChanged<String> onReject;
  final ValueChanged<String> onSnooze;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
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
                Icons.notifications_active,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                candidates.length == 1
                    ? '1 check-in suggestion'
                    : '${candidates.length} check-in suggestions',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final candidate in candidates.take(3))
            _buildCandidateTile(candidate: candidate),
          if (candidates.length > 3) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${candidates.length - 3} more suggestion(s) pending',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCandidateTile({
    required TrackingCandidateRow candidate,
  }) {
    final isBusy = inFlightCandidateIds.contains(candidate.id) ||
        candidate.actionState == 'queued';
    final confidence = candidate.confidence == null
        ? null
        : '${(candidate.confidence! * 100).clamp(0, 100).toStringAsFixed(0)}%';
    final title = candidate.suggestedName?.trim().isNotEmpty == true
        ? candidate.suggestedName!.trim()
        : 'Suggested stop';
    final detail = [
      if (confidence != null) 'Confidence: $confidence',
      if (candidate.notificationState == 'skipped_no_tokens')
        'Push unavailable, shown in inbox',
      if (candidate.actionState == 'queued') 'Decision syncing...',
      if (candidate.actionState == 'failed') 'Last decision failed, retry',
    ].join('  •  ');

    return Container(
      key: ValueKey('candidateTile_${candidate.id}'),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
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
          if (detail.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              detail,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              FilledButton.tonal(
                key: ValueKey('candidateConfirm_${candidate.id}'),
                onPressed: isBusy ? null : () => onConfirm(candidate.id),
                child: const Text('Confirm'),
              ),
              OutlinedButton(
                key: ValueKey('candidateReject_${candidate.id}'),
                onPressed: isBusy ? null : () => onReject(candidate.id),
                child: const Text('Dismiss'),
              ),
              TextButton(
                key: ValueKey('candidateSnooze_${candidate.id}'),
                onPressed: isBusy ? null : () => onSnooze(candidate.id),
                child: const Text('Snooze 1h'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
