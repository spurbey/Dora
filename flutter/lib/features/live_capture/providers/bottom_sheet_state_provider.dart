import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/features/live_capture/providers/trip_unified_timeline_provider.dart';

/// Bottom-sheet state machine for the V3 live screen.
///
/// Four states, one active at a time per trip:
///   - [BottomSheetHidden] — sheet not visible (live screen at full chrome)
///   - [BottomSheetTimeline] — sheet visible, default chronological list
///   - [BottomSheetDetail] — sheet visible, single-item detail view
///   - [BottomSheetCluster] — sheet visible, carousel of items at one cluster
///
/// Transitions are user-driven: tap timeline handle → Timeline; tap pin →
/// Detail; tap cluster pin → Cluster; close button → Hidden;
/// tap row in cluster carousel → Detail.
sealed class BottomSheetState {
  const BottomSheetState();
}

class BottomSheetHidden extends BottomSheetState {
  const BottomSheetHidden();
}

class BottomSheetTimeline extends BottomSheetState {
  const BottomSheetTimeline();
}

class BottomSheetDetail extends BottomSheetState {
  const BottomSheetDetail(this.item);
  final TimelineItem item;
}

class BottomSheetCluster extends BottomSheetState {
  const BottomSheetCluster({required this.clusterId, required this.items});

  /// Stable cluster identifier so re-renders don't flicker the sheet
  /// when the same cluster is re-resolved with the same items.
  final String clusterId;
  final List<TimelineItem> items;
}

/// Live state holder for the bottom sheet, family-keyed by trip.
///
/// The widget reads the current state and dispatches on type to render
/// the appropriate content. User actions (tap pin, drag sheet, etc.)
/// call methods on the notifier to drive transitions.
class BottomSheetStateNotifier extends StateNotifier<BottomSheetState> {
  /// Defaults to hidden. The live screen renders a separate compact timeline
  /// handle, so the heavy draggable sheet never covers the map on first mount.
  BottomSheetStateNotifier() : super(const BottomSheetHidden());

  /// Open the timeline (default sheet view).
  void openTimeline() {
    state = const BottomSheetTimeline();
  }

  /// Open detail for [item]. Convenience: callers don't have to know
  /// what subtype the item is — the sheet renders the right detail
  /// content based on runtime type.
  void openDetail(TimelineItem item) {
    state = BottomSheetDetail(item);
  }

  /// Open cluster expansion with [items] — typically the memories that
  /// fall within a single cluster pin's radius.
  void openCluster(
      {required String clusterId, required List<TimelineItem> items}) {
    state = BottomSheetCluster(clusterId: clusterId, items: items);
  }

  /// Hide the sheet entirely.
  void hide() {
    state = const BottomSheetHidden();
  }

  /// From a detail or cluster view, drop back to timeline mode.
  void backToTimeline() {
    state = const BottomSheetTimeline();
  }
}

final bottomSheetStateProvider = StateNotifierProvider.autoDispose
    .family<BottomSheetStateNotifier, BottomSheetState, String>(
  (ref, tripId) => BottomSheetStateNotifier(),
);
