import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Why a Dora speech bubble appeared. Drives the visual treatment
/// (purple for advisory voice, success-tinted for captures, amber for
/// warnings) and the tap behavior (advisory taps open the side panel
/// with the relevant message focused; capture acks just dismiss).
enum DoraBubbleSource {
  /// Advisory delivered — Dora has something to say. Tap opens the
  /// side panel with the message thread.
  advisory,

  /// User just captured a memory (photo/video). Acknowledgement.
  memoryCaptured,

  /// User just added a note/warn/geotag. Acknowledgement.
  eventAdded,

  /// Resolver finished review — Dora figured out where you were.
  resolverResolved,
}

/// One queued or active speech bubble.
@immutable
class DoraBubble {
  const DoraBubble({
    required this.id,
    required this.source,
    required this.message,
    this.actionAdvisoryId,
  });

  /// Stable id used as the AnimatedSwitcher key. UUIDs are fine; for
  /// system-generated bubbles a `<source>:<timestamp>` string also
  /// works.
  final String id;
  final DoraBubbleSource source;

  /// Body text displayed inside the bubble. Keep short — the bubble's
  /// max width is 280 and we don't want it wrapping more than 2 lines.
  final String message;

  /// When the user taps this bubble, open the side panel and focus the
  /// matching advisory. Only set when [source] is `advisory`.
  final String? actionAdvisoryId;
}

/// Queue + visibility state for the Dora speech bubble overlay.
///
/// **Invariant:** at most one bubble is visible at a time. Calls to
/// [enqueue] either show immediately (when nothing's visible) or queue
/// behind the active bubble. [dismiss] surfaces the next queued one if
/// any.
///
/// Auto-dismiss timer is 8 seconds. Calls to [enqueue] for a NEW bubble
/// do not interrupt the active one — they queue. The widget's tap
/// handler can call [dismiss] eagerly to advance the queue.
class DoraBubbleNotifier extends StateNotifier<DoraBubbleState> {
  DoraBubbleNotifier() : super(const DoraBubbleState());

  static const Duration _autoDismissAfter = Duration(seconds: 8);

  Timer? _autoDismissTimer;

  void enqueue(DoraBubble bubble) {
    final active = state.active;
    if (active == null) {
      state = state.copyWith(active: bubble);
      _scheduleAutoDismiss(bubble.id);
      return;
    }
    if (active.id == bubble.id) return; // dedupe re-enqueues
    final queue = [...state.queue, bubble];
    state = state.copyWith(queue: queue);
  }

  /// Dismiss the currently active bubble (or the bubble matching [id]
  /// if it's still active — guards against a stale tap on a bubble
  /// that the auto-timer already retired).
  void dismiss({String? id}) {
    final active = state.active;
    if (active == null) return;
    if (id != null && active.id != id) return;

    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    final queue = state.queue;
    if (queue.isEmpty) {
      state = state.copyWith(clearActive: true);
      return;
    }
    final next = queue.first;
    state = DoraBubbleState(
      active: next,
      queue: List.unmodifiable(queue.skip(1)),
    );
    _scheduleAutoDismiss(next.id);
  }

  /// Drop everything. Useful when the trip ends or the screen exits.
  void clear() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    state = const DoraBubbleState();
  }

  void _scheduleAutoDismiss(String forId) {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(_autoDismissAfter, () {
      // Only dismiss if the bubble is still the one we scheduled for.
      final active = state.active;
      if (active != null && active.id == forId) {
        dismiss(id: forId);
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }
}

/// Snapshot of the bubble queue. Widget reads `active` for what to
/// render; `queue` is informational (could drive a "+N more" badge).
@immutable
class DoraBubbleState {
  const DoraBubbleState({this.active, this.queue = const []});

  final DoraBubble? active;
  final List<DoraBubble> queue;

  DoraBubbleState copyWith({
    DoraBubble? active,
    List<DoraBubble>? queue,
    bool clearActive = false,
  }) {
    return DoraBubbleState(
      active: clearActive ? null : (active ?? this.active),
      queue: queue ?? this.queue,
    );
  }
}

final doraBubbleProvider = StateNotifierProvider.autoDispose
    .family<DoraBubbleNotifier, DoraBubbleState, String>(
  (ref, tripId) => DoraBubbleNotifier(),
);
