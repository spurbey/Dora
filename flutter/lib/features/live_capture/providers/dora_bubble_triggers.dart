import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/features/live_capture/providers/dora_bubble_provider.dart';

/// Call-site helpers for enqueuing Dora bubbles at the four trigger
/// points described in the plan. Centralizing these here means call
/// sites just do:
///
///     DoraBubbleTriggers.acknowledgeMemoryCapture(ref, tripId);
///
/// instead of constructing [DoraBubble] instances inline. Keeps the
/// copy in one place — easy to A/B test phrasing later without
/// chasing strings through scattered widgets.
///
/// **Wiring:** these are fired from the live screen's existing capture
/// flow callbacks (the camera/note/warn submit paths) and from a
/// listener on advisory delivery. The V3 widget mount adds those
/// listener subscriptions in a follow-up phase. For now this file is
/// a stable surface call sites can target.
class DoraBubbleTriggers {
  DoraBubbleTriggers._();

  /// Fire after a photo/video capture succeeds. Brief acknowledgement.
  static void acknowledgeMemoryCapture(WidgetRef ref, String tripId) {
    ref.read(doraBubbleProvider(tripId).notifier).enqueue(
          DoraBubble(
            id: 'memory:${DateTime.now().microsecondsSinceEpoch}',
            source: DoraBubbleSource.memoryCaptured,
            message: 'Saved! That moment is on your map now.',
          ),
        );
  }

  /// Fire after a note/warn/geotag is added.
  static void acknowledgeEventAdd(
    WidgetRef ref,
    String tripId, {
    required String kind, // 'note' | 'warn' | 'geotag'
  }) {
    ref.read(doraBubbleProvider(tripId).notifier).enqueue(
          DoraBubble(
            id: '$kind:${DateTime.now().microsecondsSinceEpoch}',
            source: DoraBubbleSource.eventAdded,
            message: _eventAckCopy(kind),
          ),
        );
  }

  /// Fire when an advisory has been delivered and is unread. The
  /// bubble's tap action opens the side panel focused on this advisory.
  static void announceAdvisory(
    WidgetRef ref,
    String tripId, {
    required String advisoryId,
    required String teaser,
  }) {
    ref.read(doraBubbleProvider(tripId).notifier).enqueue(
          DoraBubble(
            id: 'advisory:$advisoryId',
            source: DoraBubbleSource.advisory,
            message: teaser,
            actionAdvisoryId: advisoryId,
          ),
        );
  }

  /// Fire when the resolver finishes a review-required event and
  /// auto-resolves it.
  static void announceResolverResolved(
    WidgetRef ref,
    String tripId, {
    required String placeName,
  }) {
    ref.read(doraBubbleProvider(tripId).notifier).enqueue(
          DoraBubble(
            id: 'resolver:${DateTime.now().microsecondsSinceEpoch}',
            source: DoraBubbleSource.resolverResolved,
            message: 'Got it — that was at $placeName.',
          ),
        );
  }

  static String _eventAckCopy(String kind) {
    switch (kind) {
      case 'warn':
        return "Noted — I'll flag this spot on the map.";
      case 'geotag':
        return "Pinned. We'll remember this place.";
      case 'note':
      default:
        return "Got it — added to your trip.";
    }
  }
}
