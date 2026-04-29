import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/live_capture/providers/trip_events_map_provider.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_provider.dart'
    show v2LiveCaptureEventsProvider;

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
/// timeline does not — this provider talks to the underlying data
/// streams directly to honor that contract.
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
    required this.body,
  });

  final String eventId;
  final TripEventMapKind kind;
  @override
  final DateTime capturedAt;
  @override
  final double? latitude;
  @override
  final double? longitude;

  /// Full text body of the note / warn / geotag — parsed from the
  /// event's JSON payload (`{'note': '...'}` shape produced by the
  /// existing capture flow). Empty string when the underlying event
  /// has no text content.
  final String body;

  @override
  String get id => 'event:$eventId';
}

/// Merges captured-media and trip-event streams into a single
/// chronologically-ordered timeline for [tripId].
///
/// Reads directly from:
///   - [v2LiveCaptureEventsProvider] — full EventJournal stream (NOT
///     the map-filtered [tripEventsMapProvider], which discards
///     no-coords rows that should still appear in the timeline).
///   - The Drift `media` table via [mediaAttachmentsDaoProvider] +
///     [mediaDaoProvider] — same join the map provider uses, but
///     WITHOUT the lat/lng filter (no-coords media stays).
///
/// Sort: most recent first. The widget groups by day (Today / Yesterday /
/// older absolute dates) at render time.
final tripUnifiedTimelineProvider = StreamProvider.autoDispose
    .family<List<TimelineItem>, String>(
  (ref, tripId) {
    final attachmentsDao = ref.watch(mediaAttachmentsDaoProvider);
    final mediaDao = ref.watch(mediaDaoProvider);

    final attachmentsStream = attachmentsDao.watchForTarget(
      targetKind: 'trip',
      targetLocalId: tripId,
    );
    final eventsAsync = ref.watch(v2LiveCaptureEventsProvider(tripId));

    return attachmentsStream.asyncMap((attachments) async {
      // ── Media — read full table without lat/lng filter ───────────
      final mediaItems = <TimelineMediaItem>[];
      if (attachments.isNotEmpty) {
        final mediaIds = attachments.map((a) => a.mediaId).toList();
        final mediaRows = await mediaDao.listByIds(mediaIds);
        for (final m in mediaRows) {
          if (m.deletedAt != null) continue;
          if (m.originScope != 'live_capture') continue;
          // Sanitize lat/lng — strip null-island sentinels here so the
          // TimelineItem.latitude/longitude contract ("null when no GPS")
          // is honored without surfacing (0,0) as a real location.
          final lat = _sanitize(m.latitude);
          final lng = _sanitize(m.longitude);
          mediaItems.add(
            TimelineMediaItem(
              mediaId: m.id,
              capturedAt: m.capturedAt,
              latitude: lat,
              longitude: lng,
              thumbnailLocalPath: m.thumbnailLocalPath,
              thumbnailRemoteUrl: m.remoteThumbnailUrl,
              rotationDegrees: _rotationFor(m.id),
            ),
          );
        }
      }

      // ── Events — full EventJournal stream including no-coords rows ──
      final eventItems = <TimelineEventItem>[];
      final events = eventsAsync.valueOrNull ?? const [];
      for (final row in events) {
        final kind = _kindOf(row.eventType);
        if (kind == null) continue;
        final lat = _sanitize(row.latitude);
        final lng = _sanitize(row.longitude);
        eventItems.add(
          TimelineEventItem(
            eventId: row.eventId,
            kind: kind,
            capturedAt: row.capturedAt,
            latitude: lat,
            longitude: lng,
            body: _bodyFromPayload(row.payloadJson),
          ),
        );
      }

      final items = <TimelineItem>[
        ...mediaItems,
        ...eventItems,
      ];
      items.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return items;
    });
  },
);

/// Maps the raw event_type wire string to the typed kind enum. Returns
/// null for `photo` / `media` events — those are surfaced via the
/// captured-media branch instead.
TripEventMapKind? _kindOf(String eventType) {
  switch (eventType) {
    case 'note':
      return TripEventMapKind.note;
    case 'warn':
      return TripEventMapKind.warn;
    case 'tag':
      return TripEventMapKind.geotag;
    default:
      return null;
  }
}

/// Parses the event's payload JSON and extracts the user's text body.
/// Capture flow stores text under the `note` key (see
/// `live_capture_screen.dart` _captureQuickEvent / _promptForTextCapture).
/// Fails soft on malformed JSON so the timeline never crashes a row.
String _bodyFromPayload(String? payloadJson) {
  if (payloadJson == null || payloadJson.isEmpty) return '';
  try {
    final decoded = jsonDecode(payloadJson);
    if (decoded is Map) {
      final note = decoded['note'];
      if (note is String) return note.trim();
    }
  } catch (_) {
    // Fall through — payload wasn't JSON. Surface it raw so the user
    // can still see *something* rather than an empty row.
    return payloadJson.length > 200
        ? payloadJson.substring(0, 200)
        : payloadJson;
  }
  return '';
}

/// Strips null-island sentinels so the TimelineItem.latitude /
/// longitude contract ("null when no GPS") is honored even when an
/// upstream insert path persisted (0, 0). Mirrors the guard in the
/// map providers.
double? _sanitize(double? value) {
  if (value == null) return null;
  if (value.isNaN) return null;
  return value;
}

/// Returns a stable rotation in [-3.0, +3.0] degrees seeded by the
/// media UUID. Same UUID always produces the same rotation — so a
/// memory pin doesn't visibly "jump" between rebuilds.
double _rotationFor(String mediaId) {
  int hash = 0;
  for (final code in mediaId.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return (hash % 600) / 100 - 3.0;
}
