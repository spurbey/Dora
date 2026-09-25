import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dora/core/media/web_capture_bytes_store.dart';
import 'package:dora/shared/widgets/memory_aware_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';

/// Default view of the V3 bottom sheet — chronological list of every
/// captured photo + note + warn + geotag for the active trip.
///
/// Day-sectioned (Today / Yesterday / older absolute dates). Each row
/// shows a type icon, primary text, time-ago, and an optional thumbnail
/// for memory items. Tap any row → notifier flips to
/// [BottomSheetDetail] (caller wires the camera fly-to in parallel).
///
/// Items WITHOUT coordinates still appear here (real captures with no
/// GPS); they show a small "Location unavailable" indicator and tapping
/// them opens the detail without a map fly-to.
class TimelineSheetContent extends ConsumerWidget {
  const TimelineSheetContent({
    super.key,
    required this.tripId,
    required this.scrollController,
    this.headerChip,
    this.onCameraFly,
  });

  final String tripId;
  final ScrollController scrollController;

  /// Optional header chip — typically the V2UnresolvedChip surfacing
  /// resolver review-required count. Null = no chip rendered.
  final Widget? headerChip;

  /// Invoked with `(latitude, longitude)` when the user taps a row whose
  /// item has coordinates. Host wires this to fly the map camera to the
  /// item's location while the bottom sheet transitions to detail mode.
  /// Items without coordinates simply don't fire this callback.
  final void Function(double lat, double lng)? onCameraFly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(tripUnifiedTimelineProvider(tripId));

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            DoraSpacing.lg,
            DoraSpacing.md,
            DoraSpacing.lg,
            DoraSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: _Header(
              count: timelineAsync.valueOrNull?.length ?? 0,
              chip: headerChip,
            ),
          ),
        ),
        timelineAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyTimeline(),
              );
            }
            return _DaySectionedList(
              items: items,
              tripId: tripId,
              onCameraFly: onCameraFly,
            );
          },
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                color: DoraColors.brandPrimary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (e, _) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(DoraSpacing.xl),
                child: Text(
                  'Could not load timeline.\n$e',
                  textAlign: TextAlign.center,
                  style: DoraTypography.bodyMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.chip});
  final int count;
  final Widget? chip;

  @override
  Widget build(BuildContext context) {
    final label = count == 0
        ? 'No captures yet'
        : count == 1
            ? '1 capture'
            : '$count captures';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(label, style: DoraTypography.displayMedium),
        ),
        if (chip != null) ...[
          const SizedBox(width: DoraSpacing.sm),
          chip!,
        ],
      ],
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DoraSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 48,
            color: DoraColors.inkTertiary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: DoraSpacing.md),
          const Text(
            "Capture a memory or jot a note —\nit'll appear here and on the map.",
            textAlign: TextAlign.center,
            style: DoraTypography.bodyMuted,
          ),
        ],
      ),
    );
  }
}

class _DaySectionedList extends StatelessWidget {
  const _DaySectionedList({
    required this.items,
    required this.tripId,
    required this.onCameraFly,
  });
  final List<TimelineItem> items;
  final String tripId;
  final void Function(double lat, double lng)? onCameraFly;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Bucket into ordered (label, items) pairs preserving most-recent-first.
    final buckets = <(String, List<TimelineItem>)>[];
    String? currentLabel;
    List<TimelineItem>? currentBucket;

    for (final item in items) {
      final localCaptured = item.capturedAt.toLocal();
      final day = DateTime(
        localCaptured.year,
        localCaptured.month,
        localCaptured.day,
      );
      final label = day == today
          ? 'Today'
          : day == yesterday
              ? 'Yesterday'
              : _absoluteDateLabel(day);
      if (label != currentLabel) {
        currentLabel = label;
        currentBucket = <TimelineItem>[];
        buckets.add((label, currentBucket));
      }
      currentBucket!.add(item);
    }

    // Flatten into sliver children: one section header + N rows per bucket.
    final children = <Widget>[];
    for (final (label, bucketItems) in buckets) {
      children.add(_SectionHeader(label: label));
      for (final item in bucketItems) {
        children.add(_TimelineRow(
          item: item,
          tripId: tripId,
          onCameraFly: onCameraFly,
        ));
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, index) => children[index],
        childCount: children.length,
      ),
    );
  }

  static String _absoluteDateLabel(DateTime day) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[day.month - 1]} ${day.day}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DoraSpacing.lg,
        DoraSpacing.lg,
        DoraSpacing.lg,
        DoraSpacing.xs,
      ),
      child: Text(
        label,
        style: DoraTypography.caption.copyWith(
          color: DoraColors.inkSecondary,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TimelineRow extends ConsumerWidget {
  const _TimelineRow({
    required this.item,
    required this.tripId,
    required this.onCameraFly,
  });
  final TimelineItem item;
  final String tripId;
  final void Function(double lat, double lng)? onCameraFly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // Camera fly first so the map is moving by the time the sheet
        // detail finishes its transition. No-coords items skip the fly
        // — detail still opens, map stays put.
        final lat = item.latitude;
        final lng = item.longitude;
        if (lat != null && lng != null) {
          onCameraFly?.call(lat, lng);
        }
        ref.read(bottomSheetStateProvider(tripId).notifier).openDetail(item);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DoraSpacing.lg,
          vertical: DoraSpacing.sm,
        ),
        child: Row(
          children: [
            _Leading(item: item),
            const SizedBox(width: DoraSpacing.md),
            Expanded(child: _Body(item: item)),
            const SizedBox(width: DoraSpacing.xs),
            const Icon(
              Icons.chevron_right_rounded,
              color: DoraColors.inkTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.item});
  final TimelineItem item;

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    final current = item;
    if (current is TimelineMediaItem) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: SizedBox(
          width: size,
          height: size,
          child: _MediaThumbnail(
            localPath: _firstNonEmpty([
              current.thumbnailLocalPath,
              current.localUri,
            ]),
            remoteUrl: _firstNonEmpty([
              current.thumbnailRemoteUrl,
              current.remoteUrl,
            ]),
          ),
        ),
      );
    }
    if (current is TimelineEventItem) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _eventColor(current.kind).withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _eventIcon(current.kind),
          color: _eventColor(current.kind),
          size: 22,
        ),
      );
    }
    return const SizedBox(width: size, height: size);
  }

  static IconData _eventIcon(TripEventMapKind kind) {
    switch (kind) {
      case TripEventMapKind.note:
        return Icons.edit_note_rounded;
      case TripEventMapKind.warn:
        return Icons.warning_amber_rounded;
      case TripEventMapKind.geotag:
        return Icons.location_on_outlined;
    }
  }

  static Color _eventColor(TripEventMapKind kind) {
    switch (kind) {
      case TripEventMapKind.note:
        return DoraColors.inkPrimary;
      case TripEventMapKind.warn:
        return DoraColors.warn;
      case TripEventMapKind.geotag:
        return DoraColors.brandPrimary;
    }
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item});
  final TimelineItem item;

  @override
  Widget build(BuildContext context) {
    final title = _titleFor(item);
    final secondary = _secondaryFor(item);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: DoraTypography.callout,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (!item.hasCoords) ...[
              const Icon(
                Icons.location_off_outlined,
                size: 14,
                color: DoraColors.inkTertiary,
              ),
              const SizedBox(width: 3),
              const Text(
                'Location unavailable',
                style: TextStyle(
                  fontSize: 12,
                  color: DoraColors.inkTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: DoraSpacing.sm),
            ],
            Text(secondary, style: DoraTypography.caption),
          ],
        ),
      ],
    );
  }

  static String _titleFor(TimelineItem item) {
    if (item is TimelineMediaItem) return 'Photo';
    if (item is TimelineEventItem) {
      final body = item.body.trim();
      if (body.isEmpty) {
        switch (item.kind) {
          case TripEventMapKind.note:
            return 'Note';
          case TripEventMapKind.warn:
            return 'Warning';
          case TripEventMapKind.geotag:
            return 'Geotag';
        }
      }
      return body;
    }
    return '';
  }

  static String _secondaryFor(TimelineItem item) {
    return _formatTimeAgo(item.capturedAt);
  }
}

class _MediaThumbnail extends StatelessWidget {
  const _MediaThumbnail({required this.localPath, required this.remoteUrl});
  final String? localPath;
  final String? remoteUrl;

  @override
  Widget build(BuildContext context) {
    if (localPath != null && localPath!.isNotEmpty) {
      if (isMemoryUri(localPath)) {
        return MemoryAwareImage(
          localUri: localPath,
          fit: BoxFit.cover,
          placeholder: const _ThumbnailFallback(),
        );
      }
      final file = _fileFromPath(localPath!);
      return Image(
        image: FileImage(file),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
      );
    }
    if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      return Image.network(
        remoteUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _ThumbnailFallback(),
      );
    }
    return const _ThumbnailFallback();
  }
}

String? _firstNonEmpty(Iterable<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

File _fileFromPath(String raw) {
  final parsed = Uri.tryParse(raw);
  if (parsed != null && parsed.scheme == 'file') {
    return File.fromUri(parsed);
  }
  return File(raw);
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DoraColors.surfaceMint,
      child: Center(
        child: Icon(
          Icons.photo_camera_outlined,
          size: 18,
          color: DoraColors.brandPrimary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

/// "12s ago", "5m ago", "2h ago", "3d ago" — same scale as Instagram /
/// most chat apps. Shifts to absolute month-day for older entries.
String _formatTimeAgo(DateTime when) {
  final now = DateTime.now();
  final diff = now.difference(when);
  if (diff.isNegative) return 'just now';
  if (diff.inSeconds < 45) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final localized = when.toLocal();
  return '${months[localized.month - 1]} ${localized.day}';
}
