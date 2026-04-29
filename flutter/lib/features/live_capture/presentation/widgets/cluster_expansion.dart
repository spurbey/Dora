import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';

/// Cluster expansion view — shown when the user taps a memory cluster
/// pin on the map. Renders a horizontal carousel of the items inside
/// the cluster, with tap-to-open-detail.
///
/// Polish-only fanout: the cluster pin's `point_count` from Mapbox is
/// the count we trust for the badge; the carousel itself shows whatever
/// was passed in via [BottomSheetCluster.items]. Deciding which items
/// fall inside a cluster is the caller's responsibility (typically:
/// after a cluster tap, query the source for nearby points within the
/// cluster radius and pass them in).
class ClusterExpansion extends ConsumerWidget {
  const ClusterExpansion({
    super.key,
    required this.tripId,
    required this.cluster,
    required this.scrollController,
  });

  final String tripId;
  final BottomSheetCluster cluster;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: _Header(
            count: cluster.items.length,
            onBack: () =>
                ref.read(bottomSheetStateProvider(tripId).notifier).backToTimeline(),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: DoraSpacing.lg,
                vertical: DoraSpacing.sm,
              ),
              itemCount: cluster.items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: DoraSpacing.md),
              itemBuilder: (context, i) {
                final item = cluster.items[i];
                return _ClusterCard(
                  item: item,
                  onTap: () {
                    ref
                        .read(bottomSheetStateProvider(tripId).notifier)
                        .openDetail(item);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.onBack});
  final int count;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 capture here' : '$count captures here';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DoraSpacing.sm,
        DoraSpacing.sm,
        DoraSpacing.lg,
        DoraSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            color: DoraColors.inkPrimary,
            tooltip: 'Back to timeline',
          ),
          Expanded(
            child: Text(label, style: DoraTypography.displayMedium),
          ),
        ],
      ),
    );
  }
}

class _ClusterCard extends StatelessWidget {
  const _ClusterCard({required this.item, required this.onTap});
  final TimelineItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Material(
        color: Colors.transparent,
        borderRadius: DoraRadius.cardAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: DoraRadius.cardAll,
          child: Container(
            decoration: const BoxDecoration(
              color: DoraColors.surfaceWhite,
              borderRadius: DoraRadius.cardAll,
              boxShadow: DoraShadow.tight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: _Visual(item: item),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(DoraSpacing.sm),
                  child: Text(
                    _label(item),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DoraTypography.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _label(TimelineItem item) {
    if (item is TimelineMediaItem) return 'Photo';
    if (item is TimelineEventItem) {
      final preview = item.preview.trim();
      if (preview.isNotEmpty) return preview;
      switch (item.kind) {
        case TripEventMapKind.note:
          return 'Note';
        case TripEventMapKind.warn:
          return 'Warning';
        case TripEventMapKind.geotag:
          return 'Geotag';
      }
    }
    return '';
  }
}

class _Visual extends StatelessWidget {
  const _Visual({required this.item});
  final TimelineItem item;

  @override
  Widget build(BuildContext context) {
    if (item is TimelineMediaItem) {
      final m = item as TimelineMediaItem;
      if (m.thumbnailLocalPath != null && m.thumbnailLocalPath!.isNotEmpty) {
        return Image(
          image: FileImage(File(m.thumbnailLocalPath!)),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _Fallback(),
        );
      }
      if (m.thumbnailRemoteUrl != null && m.thumbnailRemoteUrl!.isNotEmpty) {
        return Image.network(
          m.thumbnailRemoteUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _Fallback(),
        );
      }
      return const _Fallback();
    }
    if (item is TimelineEventItem) {
      final e = item as TimelineEventItem;
      final tint = _tintFor(e.kind);
      return Container(
        color: tint.withValues(alpha: 0.12),
        alignment: Alignment.center,
        child: Icon(_iconFor(e.kind), color: tint, size: 32),
      );
    }
    return const _Fallback();
  }

  static IconData _iconFor(TripEventMapKind kind) {
    switch (kind) {
      case TripEventMapKind.note:
        return Icons.edit_note_rounded;
      case TripEventMapKind.warn:
        return Icons.warning_amber_rounded;
      case TripEventMapKind.geotag:
        return Icons.location_on_outlined;
    }
  }

  static Color _tintFor(TripEventMapKind kind) {
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

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DoraColors.surfaceMint,
      alignment: Alignment.center,
      child: Icon(
        Icons.photo_camera_outlined,
        size: 28,
        color: DoraColors.brandPrimary.withValues(alpha: 0.55),
      ),
    );
  }
}
