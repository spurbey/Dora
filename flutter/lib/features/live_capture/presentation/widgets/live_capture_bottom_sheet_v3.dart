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
/// Drag-to-dismiss: when the sheet is dragged below the minimum size
/// (peek state), [BottomSheetStateNotifier.hide] is called so the parent
/// state remains coherent with what's on screen.
///
/// One snap layout for every state — 0.12 (peek) / 0.45 (half) / 0.92
/// (full). Detail/cluster start at 0.45 so the user can see the photo
/// or event content without dragging.
class LiveCaptureBottomSheetV3 extends ConsumerWidget {
  const LiveCaptureBottomSheetV3({
    super.key,
    required this.tripId,
    required this.onUnresolvedTap,
  });

  final String tripId;

  /// Wired to navigate to the existing V2 unresolved-inbox review
  /// surface (typically the editor's resolver-review screen).
  final VoidCallback onUnresolvedTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bottomSheetStateProvider(tripId));
    if (state is BottomSheetHidden) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: state is BottomSheetTimeline ? 0.45 : 0.6,
      minChildSize: 0.12,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.12, 0.45, 0.92],
      builder: (context, scrollController) {
        return _SheetSurface(
          child: Column(
            children: [
              const _DragHandle(),
              Expanded(
                child: _ContentSwitcher(
                  tripId: tripId,
                  state: state,
                  scrollController: scrollController,
                  onUnresolvedTap: onUnresolvedTap,
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
    return Container(
      decoration: const BoxDecoration(
        color: DoraColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: DoraColors.shadow,
            offset: Offset(0, -8),
            blurRadius: 24,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: DoraSpacing.sm),
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: DoraColors.inkTertiary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(3),
        ),
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
  });

  final String tripId;
  final BottomSheetState state;
  final ScrollController scrollController;
  final VoidCallback onUnresolvedTap;

  @override
  Widget build(BuildContext context) {
    if (state is BottomSheetTimeline) {
      return TimelineSheetContent(
        tripId: tripId,
        scrollController: scrollController,
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
        );
      }
      if (item is TimelineEventItem) {
        return EventDetail(
          tripId: tripId,
          item: item,
          scrollController: scrollController,
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
    // BottomSheetHidden was filtered upstream; this is unreachable.
    return const SizedBox.shrink();
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
