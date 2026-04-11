import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';

class V2CapturedStorylinePanel extends StatelessWidget {
  const V2CapturedStorylinePanel({
    super.key,
    required this.groups,
  });

  final List<V2TimelineDayGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return nullWidget;
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
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories, size: 16, color: AppColors.accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Captured Storyline',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: groups.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final dayGroup = groups[index];
                return _DayGroup(group: dayGroup);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.group});

  final V2TimelineDayGroup group;

  @override
  Widget build(BuildContext context) {
    final month = group.day.month.toString().padLeft(2, '0');
    final day = group.day.day.toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$day/$month/${group.day.year}',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        for (final session in group.sessions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _SessionGroup(group: session),
          ),
      ],
    );
  }
}

class _SessionGroup extends StatelessWidget {
  const _SessionGroup({required this.group});

  final V2TimelineSessionGroup group;

  @override
  Widget build(BuildContext context) {
    final shortSession = group.sessionId.length > 8
        ? group.sessionId.substring(0, 8)
        : group.sessionId;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session $shortSession',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          for (final entry in group.entries.take(4))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _iconForType(entry.eventType),
                    size: 14,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (entry.subtitle != null &&
                            entry.subtitle!.trim().isNotEmpty)
                          Text(
                            entry.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _chip(
                              label: _bucketLabel(entry.bucketType),
                              tint: _bucketTint(entry.bucketType),
                            ),
                            _chip(
                              label: _syncLabel(entry.syncChipState),
                              tint: AppColors.accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _bucketLabel(String bucketType) {
    switch (bucketType) {
      case 'place':
        return 'Bound to place';
      case 'on_route':
        return 'Geotag (On Route)';
      case 'needs_review':
      default:
        return 'Needs review';
    }
  }

  Color _bucketTint(String bucketType) {
    switch (bucketType) {
      case 'place':
        return AppColors.success;
      case 'on_route':
        return AppColors.textSecondary;
      case 'needs_review':
      default:
        return AppColors.warning;
    }
  }

  String _syncLabel(String syncChipState) {
    switch (syncChipState) {
      case 'commit_pending':
        return 'Commit pending';
      case 'committing':
        return 'Committing';
      case 'committed':
        return 'Committed';
      case 'commit_failed_retryable':
        return 'Retry';
      case 'local_only':
      default:
        return 'Local only';
    }
  }

  IconData _iconForType(String eventType) {
    switch (eventType) {
      case 'warn':
        return Icons.warning_amber_rounded;
      case 'tag':
        return Icons.bookmark_added_outlined;
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'media':
        return Icons.videocam_outlined;
      default:
        return Icons.note_alt_outlined;
    }
  }
}

const SizedBox nullWidget = SizedBox.shrink();
