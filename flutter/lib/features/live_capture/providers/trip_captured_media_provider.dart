import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';

/// Marker rendered on the live-screen map for a single captured photo
/// or video tied to the active trip.
///
/// Distinct from the raw [MediaItem] row — this is a UI-shaped projection
/// the map controller hands to its GeoJSON source. The polaroid sprite
/// is shared (one generic frame registered via `style.addStyleImage`)
/// so per-feature data is only what the cluster + callout need:
/// `mediaId`, `lat/lng`, `thumbnail` for the callout, `capturedAt` for
/// time-ago, and a deterministic `rotation` for the polaroid tilt.
class TripCapturedMediaMarker {
  const TripCapturedMediaMarker({
    required this.mediaId,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.rotationDegrees,
    required this.thumbnailLocalPath,
    required this.thumbnailRemoteUrl,
  });

  final String mediaId;
  final double latitude;
  final double longitude;
  final DateTime capturedAt;

  /// Deterministic random rotation for the polaroid look, in [-3, +3]
  /// degrees, seeded by the media UUID so it's stable across rebuilds.
  final double rotationDegrees;

  /// Local thumbnail path (preferred — works offline). Null if the
  /// thumbnail hasn't been generated locally yet.
  final String? thumbnailLocalPath;

  /// Remote thumbnail URL — used when [thumbnailLocalPath] isn't available.
  /// Null until the media has finished uploading.
  final String? thumbnailRemoteUrl;
}

/// Streams the list of map-pinnable captured media for [tripId].
///
/// Driven by the join of:
///   - `media_attachments` rows where `targetKind='trip' AND targetLocalId=tripId`
///     AND `detachedAt IS NULL`
///   - the `media` rows referenced by those attachments, filtered by:
///     - `originScope = 'live_capture'` (primary gate — vault-origin media
///       can have NULL coords and isn't relevant to the live trip's map)
///     - `latitude IS NOT NULL AND longitude IS NOT NULL` (defense-in-depth)
///     - NOT (`latitude == 0 AND longitude == 0`) — null-island guard
///     - `deletedAt IS NULL`
///
/// The composition is done in Dart (watching attachments stream and
/// reading media rows by id on each emission). For trips with hundreds
/// of attachments this is fine — the map only renders what's on screen
/// anyway via clustering.
final tripCapturedMediaProvider =
    StreamProvider.autoDispose.family<List<TripCapturedMediaMarker>, String>(
  (ref, tripId) {
    final attachmentsDao = ref.watch(mediaAttachmentsDaoProvider);
    final mediaDao = ref.watch(mediaDaoProvider);

    final attachmentStream = attachmentsDao.watchForTarget(
      targetKind: 'trip',
      targetLocalId: tripId,
    );

    return attachmentStream.asyncMap((attachments) async {
      if (attachments.isEmpty) return const <TripCapturedMediaMarker>[];

      final mediaIds = attachments.map((a) => a.mediaId).toList();
      final mediaRows = await mediaDao.listByIds(mediaIds);

      final markers = <TripCapturedMediaMarker>[];
      for (final m in mediaRows) {
        if (m.deletedAt != null) continue;
        if (m.originScope != 'live_capture') continue;
        final lat = m.latitude;
        final lng = m.longitude;
        if (lat == null || lng == null) continue;
        if (lat.isNaN || lng.isNaN) continue;
        if (lat == 0 && lng == 0) continue;

        markers.add(
          TripCapturedMediaMarker(
            mediaId: m.id,
            latitude: lat,
            longitude: lng,
            capturedAt: m.capturedAt,
            rotationDegrees: _rotationFor(m.id),
            thumbnailLocalPath: m.thumbnailLocalPath,
            thumbnailRemoteUrl: m.remoteThumbnailUrl,
          ),
        );
      }

      // Most-recent first so cluster detail carousels show newest captures
      // at the top when a stack is expanded.
      markers.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      return markers;
    });
  },
);

/// Returns a stable rotation in [-3.0, +3.0] degrees seeded by the media
/// UUID. Same UUID always produces the same rotation — so a memory pin
/// doesn't visibly "jump" between rebuilds.
double _rotationFor(String mediaId) {
  // Cheap hash → 0..6 → -3..+3
  int hash = 0;
  for (final code in mediaId.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return (hash % 600) / 100 - 3.0;
}
