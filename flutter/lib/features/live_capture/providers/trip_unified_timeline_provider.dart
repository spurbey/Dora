import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/features/live_capture/providers/trip_captured_media_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';

/// One row in the unified live-screen timeline.
///
/// The timeline merges everything the user has done during the trip
/// (captured photos, notes, warns, geotags) into a single chronologically
/// ordered list. Each subtype carries the data the row + detail screen
/// need; the bottom sheet dispatches on runtime type to choose detail
/// content.
///
/// **Invariant:** items without coordinates STILL appear in the timeline
/// (they're real captures, just lacking location). They simply can't be
/// flown to on the map. The map providers filter null-island, the
/// timeline does not.
sealed class TimelineItem {
  const TimelineItem();

  /// Stable identifier — `media:<uuid>` or `event:<uuid>`. Used as the
  /// row key and as the active-item marker for callout / sheet state.
  String get id;
  DateTime get capturedAt;

  /// Null when the underlying capture had no GPS lock. Detail view
  /// still opens; map fly-to is a no-op for these items.
  double? get latitude;
  double? get longitude;

  bool get hasCoords => latitude != null && longitude != null;
}

class TimelineMediaItem extends TimelineItem {
  const TimelineMediaItem({
    required this.mediaId,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.thumbnailLocalPath,
    required this.thumbnailRemoteUrl,
    required this.rotationDegrees,
  });

  final String mediaId;
  @override
  final DateTime capturedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;

  final String? thumbnailLocalPath;
  final String? thumbnailRemoteUrl;
  final double rotationDegrees;

  @override
  String get id => 'media:$mediaId';
}

class TimelineEventItem extends TimelineItem {
  const TimelineEventItem({
    required this.eventId,
    required this.kind,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.preview,
  });

  final String eventId;
  final TripEventMapKind kind;
  @override
  final DateTime capturedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;

  /// First ~80 chars of the event's text payload — used in the timeline
  /// row as the visible content. Detail screen reads the full payload.
  final String preview;

  @override
  String get id => 'event:$eventId';
}

/// Merges captured-media and trip-event streams into a single
/// chronologically-ordered timeline for [tripId].
///
/// Sort: most recent first. The widget groups by day (Today / Yesterday /
/// older absolute dates) at render time.
///
/// V1 scope: media + events. Saved advisories and saved places will be
/// merged in a follow-up — the [TimelineItem] sealed hierarchy is set
/// up to accept new subtypes additively.
final tripUnifiedTimelineProvider = Provider.autoDispose
    .family<AsyncValue<List<TimelineItem>>, String>(
  (ref, tripId) {
    final mediaAsync = ref.watch(tripCapturedMediaProvider(tripId));
    final eventsAsync = ref.watch(tripEventsMapProvider(tripId));

    // Combine the two AsyncValues. If either is loading and we have no
    // prior data, we surface loading. If either errors and we have no
    // prior data, we surface the error. Once both have any value (even
    // empty) we render — partial data is fine on a real trip.
    if (mediaAsync.isLoading && !mediaAsync.hasValue) {
      return const AsyncValue.loading();
    }
    if (eventsAsync.isLoading && !eventsAsync.hasValue) {
      return const AsyncValue.loading();
    }

    final mediaError = mediaAsync.hasError ? mediaAsync.error : null;
    final eventsError = eventsAsync.hasError ? eventsAsync.error : null;
    if (mediaError != null && !mediaAsync.hasValue) {
      return AsyncValue.error(
        mediaError,
        mediaAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (eventsError != null && !eventsAsync.hasValue) {
      return AsyncValue.error(
        eventsError,
        eventsAsync.stackTrace ?? StackTrace.current,
      );
    }

    final items = <TimelineItem>[];

    final media = mediaAsync.valueOrNull ?? const <TripCapturedMediaMarker>[];
    for (final m in media) {
      items.add(
        TimelineMediaItem(
          mediaId: m.mediaId,
          capturedAt: m.capturedAt,
          latitude: m.latitude,
          longitude: m.longitude,
          thumbnailLocalPath: m.thumbnailLocalPath,
          thumbnailRemoteUrl: m.thumbnailRemoteUrl,
          rotationDegrees: m.rotationDegrees,
        ),
      );
    }

    final events = eventsAsync.valueOrNull ?? const <TripEventMapMarker>[];
    for (final e in events) {
      items.add(
        TimelineEventItem(
          eventId: e.eventId,
          kind: e.kind,
          capturedAt: e.capturedAt,
          latitude: e.latitude,
          longitude: e.longitude,
          preview: e.preview,
        ),
      );
    }

    items.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return AsyncValue.data(items);
  },
);
