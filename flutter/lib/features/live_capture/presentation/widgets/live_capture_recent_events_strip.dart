import 'package:flutter/material.dart';

import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class LiveCaptureRecentEventItem {
  const LiveCaptureRecentEventItem({
    required this.id,
    required this.eventType,
    required this.note,
    required this.capturedAt,
    required this.syncLabel,
  });

  final String id;
  final String eventType;
  final String? note;
  final DateTime capturedAt;
  final String syncLabel;
}

class LiveCaptureRecentEventsStrip extends StatelessWidget {
  const LiveCaptureRecentEventsStrip({
    super.key,
    required this.events,
    this.loading = false,
  });

  final List<LiveCaptureRecentEventItem> events;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _Shell(
        child: Text(
          'Loading recent captures...',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    if (events.isEmpty) {
      return _Shell(
        child: Text(
          'Recent captures will appear here.',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    final visible = events.take(3).toList(growable: false);
    return _Shell(
      child: AnimatedSwitcher(
        duration: AnimationTokens.normal,
        transitionBuilder: (child, anim) =>
            FadeTransition(opacity: anim, child: child),
        // Key by ids so switcher triggers on list change
        child: SingleChildScrollView(
          key: ValueKey(visible.map((e) => e.id).join(',')),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final event in visible) ...[
                _EventChip(event: event),
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('liveCaptureRecentEventsStrip'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.event});

  final LiveCaptureRecentEventItem event;

  @override
  Widget build(BuildContext context) {
    final accentColor = _eventTypeColor(event.eventType);
    return Container(
      key: ValueKey('liveCaptureEvent_${event.id}'),
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 196),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_eventTypeIcon(event.eventType),
                        size: 11, color: accentColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _title(event),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_time(event.capturedAt)} | ${event.syncLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _eventTypeColor(String eventType) {
    switch (eventType) {
      case 'photo':
        return AppColors.accent;
      case 'warn':
        return AppColors.warning;
      case 'tag':
        return AppColors.success;
      case 'media':
        return AppColors.primary;
      case 'note':
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _eventTypeIcon(String eventType) {
    switch (eventType) {
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'warn':
        return Icons.warning_amber_rounded;
      case 'tag':
        return Icons.place_outlined;
      case 'media':
        return Icons.videocam_outlined;
      case 'note':
      default:
        return Icons.note_add_outlined;
    }
  }

  String _title(LiveCaptureRecentEventItem row) {
    final note = row.note?.trim();
    if (note != null && note.isNotEmpty) {
      return note;
    }
    switch (row.eventType) {
      case 'note':
        return 'Note';
      case 'warn':
        return 'Warning';
      case 'tag':
        return 'Tag';
      case 'photo':
        return 'Photo';
      case 'media':
        return 'Media';
      default:
        return 'Capture';
    }
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
