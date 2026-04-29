import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_provider.dart'
    show v2LiveCaptureEventsProvider;

/// Marker rendered on the live-screen map for a single trip event
/// (note / warn / geotag).
///
/// Distinct from [EventJournalRow] — this is a UI-shaped projection that
/// strips fields the map layer doesn't need (resolver state, place bind
/// metadata, payload JSON) and adds a normalized `kind` enum the map
/// controller switches on to choose the sprite layer.
class TripEventMapMarker {
  const TripEventMapMarker({
    required this.eventId,
    required this.kind,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.preview,
  });

  final String eventId;
  final TripEventMapKind kind;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  /// First ~80 chars of the event's text payload — used in the callout.
  /// Empty string if the event has no text content.
  final String preview;
}

/// Visual-kind enum the map switches on to choose the sprite layer.
///
/// Mirrors [LiveTrackingEventType] but only the 3 types that V3 renders
/// as map pins. `photo` and `media` events are surfaced via the
/// captured-media polaroid layer instead, not via this provider.
enum TripEventMapKind { note, warn, geotag }

/// Streams the list of map-pinnable events for [tripId] as an
/// `AsyncValue<List<TripEventMapMarker>>`.
///
/// Emits a separate marker for each note / warn / geotag (`tag`) row in
/// the local [EventJournal], filtered by:
///   - `eventType IN ('note', 'warn', 'tag')`
///   - non-null `latitude` and `longitude`
///   - NOT (`latitude == 0 AND longitude == 0`) — null-island guard
///
/// Photo and media events are intentionally excluded — those are rendered
/// via the polaroid layer (driven by `tripCapturedMediaProvider`).
///
/// Implemented as a derived `Provider` mapping the upstream
/// [v2LiveCaptureEventsProvider]'s `AsyncValue` rather than going through
/// the deprecated `.stream` accessor — keeps us forward-compatible with
/// Riverpod 3.
final tripEventsMapProvider = Provider.autoDispose
    .family<AsyncValue<List<TripEventMapMarker>>, String>(
  (ref, tripId) {
    return ref.watch(v2LiveCaptureEventsProvider(tripId)).whenData((events) {
      final markers = <TripEventMapMarker>[];
      for (final row in events) {
        final kind = _kindOf(row.eventType);
        if (kind == null) continue;
        if (!_hasUsableCoords(row.latitude, row.longitude)) continue;
        markers.add(
          TripEventMapMarker(
            eventId: row.eventId,
            kind: kind,
            latitude: row.latitude,
            longitude: row.longitude,
            capturedAt: row.capturedAt,
            preview: _previewFor(row),
          ),
        );
      }
      return markers;
    });
  },
);

/// Returns true when both coordinates are non-zero finite numbers.
///
/// [EventJournal.latitude] / [EventJournal.longitude] are non-nullable in
/// the schema and the journal repository rejects inserts with null coords,
/// so this filter is defense-in-depth — but the (0, 0) "null island"
/// guard is meaningful: any code path that bypasses the journal repo and
/// writes (0, 0) sentinels would otherwise render a pin off the coast of
/// Africa.
bool _hasUsableCoords(double lat, double lng) {
  if (lat.isNaN || lng.isNaN) return false;
  if (lat == 0 && lng == 0) return false;
  return true;
}

TripEventMapKind? _kindOf(String eventType) {
  switch (eventType) {
    case 'note':
      return TripEventMapKind.note;
    case 'warn':
      return TripEventMapKind.warn;
    case 'tag':
      return TripEventMapKind.geotag;
    default:
      // photo / media are rendered via the polaroid layer.
      return null;
  }
}

String _previewFor(EventJournalRow row) {
  final payload = row.payloadJson;
  if (payload == null || payload.isEmpty) return '';
  // Keep the parser dumb-simple — payload is JSON but we want a short
  // preview. The payload schema isn't strictly typed across event kinds
  // so we surface the raw text up to the first newline / ~80 chars.
  // Detail screens parse this properly later; this is just for the
  // callout teaser.
  final firstLine = payload.split('\n').first;
  return firstLine.length > 80 ? firstLine.substring(0, 80) : firstLine;
}
