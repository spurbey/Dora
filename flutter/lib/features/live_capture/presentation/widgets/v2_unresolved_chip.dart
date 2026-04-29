import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';

/// Compact actionable chip showing the count of unresolved captures
/// (resolver review-required) for the active trip.
///
/// Mounted in the timeline-sheet header. Replaces the visual presence
/// of the deleted V1 `_UnresolvedCaptureBanner` while keeping the
/// always-visible primary signal where it already lives — the top-bar
/// resolver badge.
///
/// **Actionable, not informational:** tap → invokes [onTap], which the
/// host wires to navigate to the existing v2 inbox/review surface
/// (typically the editor's resolver review screen). If we ship this as
/// passive we've regressed compared to the deleted banner.
///
/// Hidden entirely (zero size) when there are no unresolved items, so
/// the timeline header doesn't carry a permanent badge.
class V2UnresolvedChip extends ConsumerWidget {
  const V2UnresolvedChip({
    super.key,
    required this.tripId,
    required this.onTap,
  });

  final String tripId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(v2UnresolvedInboxProvider(tripId));
    final count = inboxAsync.valueOrNull?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return Material(
      color: DoraColors.warn.withValues(alpha: 0.15),
      borderRadius: DoraRadius.chipAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: DoraRadius.chipAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DoraSpacing.md,
            vertical: DoraSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 16,
                color: DoraColors.warn,
              ),
              const SizedBox(width: 6),
              Text(
                count == 1 ? '1 to review' : '$count to review',
                style: DoraTypography.caption.copyWith(
                  color: DoraColors.warn,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
