import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/theme/dora_theme.dart';
import 'package:dora/features/live_capture/presentation/widgets/captured_media_detail.dart';
import 'package:dora/features/live_capture/presentation/widgets/cluster_expansion.dart';
import 'package:dora/features/live_capture/presentation/widgets/event_detail.dart';
import 'package:dora/features/live_capture/presentation/widgets/timeline_sheet_content.dart';
import 'package:dora/features/live_capture/presentation/widgets/v2_unresolved_chip.dart';
import 'package:dora/features/live_capture/providers/bottom_sheet_state_provider.dart';
import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';
import 'package:dora/features/live_tracking/v2/inbox/v2_unresolved_inbox_provider.dart';

/// V3 bottom-sheet host — a single [DraggableScrollableSheet] driven by
/// [bottomSheetStateProvider]. The active state determines what content
/// renders inside the sheet:
///
/// - [BottomSheetHidden] → returns an empty box (sheet not mounted)
/// - [BottomSheetTimeline] → [TimelineSheetContent] with the V2 chip
/// - [BottomSheetDetail] → dispatches on item runtime type to the
///   correct detail content (CapturedMediaDetail / EventDetail / etc.)
/// - [BottomSheetCluster] → [ClusterExpansion]
///
/// One snap layout for every visible state — compact / half / full.
/// The sheet is hidden by default; the live screen owns a separate small
/// timeline handle so this surface never blankets the map on first mount.
class LiveCaptureBottomSheetV3 extends ConsumerWidget {
  const LiveCaptureBottomSheetV3({
    super.key,
    required this.tripId,
    required this.onUnresolvedTap,
    this.onCameraFly,
  });

  final String tripId;

  /// Wired to navigate to the existing V2 unresolved-inbox review
  /// surface (typically the editor's resolver-review screen).
  final VoidCallback onUnresolvedTap;

  /// Invoked when a timeline row is tapped and the underlying item has
  /// coordinates. Host wires this to fly the map camera to the item's
  /// location while the sheet transitions to detail mode. Items without
  /// coordinates do not fire this callback.
  final void Function(double lat, double lng)? onCameraFly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bottomSheetStateProvider(tripId));
    if (state is BottomSheetHidden) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      // Timeline opens to a useful half-sheet only after the user taps
      // the compact timeline handle. Detail / cluster open taller so the
      // selected content is immediately legible.
      initialChildSize: state is BottomSheetTimeline ? 0.45 : 0.6,
      minChildSize: 0.28,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.28, 0.45, 0.92],
      builder: (context, scrollController) {
        return _SheetSurface(
          child: Column(
            children: [
              _DragHandle(tripId: tripId),
              Expanded(
                child: _ContentSwitcher(
                  tripId: tripId,
                  state: state,
                  scrollController: scrollController,
                  onUnresolvedTap: onUnresolvedTap,
                  onCameraFly: onCameraFly,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          color: DoraColors.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: DoraColors.shadow,
              offset: Offset(0, -8),
              blurRadius: 24,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Drag handle bar at the top of the sheet — visible even at peek.
///
/// When the V2 resolver inbox has any unresolved items for this trip,
/// a small amber dot is rendered next to the handle bar. Honors the
/// plan's no-coords acceptance criterion: even when the sheet is
/// collapsed, the user gets a visible signal that there's something
/// awaiting review.
class _DragHandle extends ConsumerWidget {
  const _DragHandle({required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unresolvedAsync = ref.watch(v2UnresolvedInboxProvider(tripId));
    final hasUnresolved = (unresolvedAsync.valueOrNull?.isNotEmpty) ?? false;

    return SizedBox(
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 12,
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: DoraColors.inkTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (hasUnresolved)
            Align(
              alignment: Alignment.topCenter,
              child: Semantics(
                label: 'Items awaiting review',
                child: Transform.translate(
                  offset: const Offset(28, 10),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DoraColors.warn,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: DoraSpacing.lg,
            top: 4,
            child: Semantics(
              label: 'Close timeline',
              button: true,
              child: Material(
                color: DoraColors.surfaceMint,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => ref
                      .read(bottomSheetStateProvider(tripId).notifier)
                      .hide(),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: DoraColors.inkSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dispatches the bottom-sheet state to the right content widget.
///
/// Detail-state subtype dispatch lives here, in one place, so detail
/// widgets stay independent of the BottomSheetState type and can be
/// re-used outside the sheet (e.g. as a full-screen route in future).
class _ContentSwitcher extends StatelessWidget {
  const _ContentSwitcher({
    required this.tripId,
    required this.state,
    required this.scrollController,
    required this.onUnresolvedTap,
    required this.onCameraFly,
  });

  final String tripId;
  final BottomSheetState state;
  final ScrollController scrollController;
  final VoidCallback onUnresolvedTap;
  final void Function(double lat, double lng)? onCameraFly;

  @override
  Widget build(BuildContext context) {
    if (state is BottomSheetTimeline) {
      return TimelineSheetContent(
        tripId: tripId,
        scrollController: scrollController,
        onCameraFly: onCameraFly,
        headerChip: V2UnresolvedChip(
          tripId: tripId,
          onTap: onUnresolvedTap,
        ),
      );
    }
    if (state is BottomSheetDetail) {
      final detail = state as BottomSheetDetail;
      final item = detail.item;
      if (item is TimelineMediaItem) {
        return CapturedMediaDetail(
          tripId: tripId,
          item: item,
          scrollController: scrollController,
          onShowOnMap: onCameraFly,
        );
      }
      if (item is TimelineEventItem) {
        return EventDetail(
          tripId: tripId,
          item: item,
          scrollController: scrollController,
          onShowOnMap: onCameraFly,
        );
      }
      // PlaceDetail / advisory detail are not yet driven by the unified
      // timeline (no TimelinePlaceItem subtype). Future sprint.
      return _UnsupportedDetail(scrollController: scrollController);
    }
    if (state is BottomSheetCluster) {
      return ClusterExpansion(
        tripId: tripId,
        cluster: state as BottomSheetCluster,
        scrollController: scrollController,
      );
    }
    // Defensive fallback: keep the sheet usable even if state evolution
    // introduces an unexpected subtype in future.
    return TimelineSheetContent(
      tripId: tripId,
      scrollController: scrollController,
      onCameraFly: onCameraFly,
      headerChip: V2UnresolvedChip(
        tripId: tripId,
        onTap: onUnresolvedTap,
      ),
    );
  }
}

class _UnsupportedDetail extends StatelessWidget {
  const _UnsupportedDetail({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: const [
        Padding(
          padding: EdgeInsets.all(DoraSpacing.xl),
          child: Text(
            'Detail not available for this item yet.',
            style: DoraTypography.bodyMuted,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
