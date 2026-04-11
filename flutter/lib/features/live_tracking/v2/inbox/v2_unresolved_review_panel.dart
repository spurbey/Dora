import 'package:flutter/material.dart';

import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';

class V2UnresolvedReviewPanel extends StatelessWidget {
  const V2UnresolvedReviewPanel({
    super.key,
    required this.items,
    required this.interactive,
    required this.onReviewInEditor,
    this.onAcceptCandidate,
    this.onAddPlace,
    this.onKeepGeotag,
    this.busyEventIds = const <String>{},
    this.title = 'Capture review',
  });

  final List<V2UnresolvedInboxItem> items;
  final bool interactive;
  final VoidCallback? onReviewInEditor;
  final void Function(String eventId, V2ResolverCandidate candidate)?
      onAcceptCandidate;
  final void Function(String eventId)? onAddPlace;
  final void Function(String eventId)? onKeepGeotag;
  final Set<String> busyEventIds;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final reviewRequiredCount =
        items.where((item) => item.resolverState == 'review_required').length;
    final headline = reviewRequiredCount <= 1
        ? '1 capture needs place review'
        : '$reviewRequiredCount captures need place review';
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xs,
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
              const Icon(
                Icons.place_outlined,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (!interactive)
                TextButton(
                  onPressed: onReviewInEditor,
                  child: const Text('Review in editor'),
                ),
            ],
          ),
          Text(
            headline,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final item in items.take(interactive ? 5 : 2))
            _ReviewRow(
              item: item,
              interactive: interactive,
              busy: busyEventIds.contains(item.eventId),
              onAcceptCandidate: onAcceptCandidate,
              onAddPlace: onAddPlace,
              onKeepGeotag: onKeepGeotag,
            ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.item,
    required this.interactive,
    required this.busy,
    required this.onAcceptCandidate,
    required this.onAddPlace,
    required this.onKeepGeotag,
  });

  final V2UnresolvedInboxItem item;
  final bool interactive;
  final bool busy;
  final void Function(String eventId, V2ResolverCandidate candidate)?
      onAcceptCandidate;
  final void Function(String eventId)? onAddPlace;
  final void Function(String eventId)? onKeepGeotag;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconForType(item.eventType),
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _title(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (item.topCandidates.isNotEmpty) ...[
            const SizedBox(height: 4),
            for (final candidate in item.topCandidates.take(3))
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${candidate.name} (${(candidate.confidenceScore * 100).round()}%)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (interactive)
                    TextButton(
                      onPressed: busy || onAcceptCandidate == null
                          ? null
                          : () => onAcceptCandidate!(item.eventId, candidate),
                      child: const Text('Accept'),
                    ),
                ],
              ),
          ],
          if (interactive)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                OutlinedButton(
                  onPressed: busy || onAddPlace == null
                      ? null
                      : () => onAddPlace!(item.eventId),
                  child: const Text('Add place manually'),
                ),
                TextButton(
                  onPressed: busy || onKeepGeotag == null
                      ? null
                      : () => onKeepGeotag!(item.eventId),
                  child: const Text('Geo-Tag'),
                ),
              ],
            )
          else
            Text(
              'Resolve in editor',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconForType(String eventType) {
    switch (eventType) {
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'media':
        return Icons.videocam_outlined;
      case 'warn':
        return Icons.warning_amber_rounded;
      case 'tag':
        return Icons.bookmark_added_outlined;
      case 'note':
      default:
        return Icons.note_alt_outlined;
    }
  }

  String _title(V2UnresolvedInboxItem item) {
    final local = item.capturedAt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final stateLabel =
        item.resolverState == 'review_required' ? 'Needs review' : 'Unresolved';
    return '$stateLabel • $hour:$minute';
  }
}
