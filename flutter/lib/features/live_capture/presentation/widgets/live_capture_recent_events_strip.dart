import 'package:flutter/material.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/theme/animation_tokens.dart';
import 'package:dora/core/theme/app_colors.dart';
import 'package:dora/core/theme/app_radius.dart';
import 'package:dora/core/theme/app_spacing.dart';
import 'package:dora/core/theme/app_typography.dart';

class LiveCaptureRecentEventsStrip extends StatelessWidget {
  const LiveCaptureRecentEventsStrip({
    super.key,
    required this.events,
    this.loading = false,
  });

  final List<TrackingEventRow> events;
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

  final TrackingEventRow event;

  @override
  Widget build(BuildContext context) {
    final accentColor = _eventTypeColor(event.eventType);
    return Container(
      key: ValueKey('liveCaptureEvent_${event.id}'),
      constraints: const BoxConstraints(maxWidth: 196),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          top: BorderSide(color: AppColors.divider),
          right: BorderSide(color: AppColors.divider),
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_eventTypeIcon(event.eventType), size: 11, color: accentColor),
              const SizedBox(width: 4),
              Flexible(
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
            '${_time(event.createdAt)} · ${event.syncStatus}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
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

  String _title(TrackingEventRow row) {
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
