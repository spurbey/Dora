import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Variable;

import 'package:dora/core/storage/database_provider.dart';

enum EditorSyncStatusKind {
  localSaved,
  syncing,
  synced,
  failed,
  blocked,
  activeSession,
  publishing,
}

class EditorSyncStatus {
  const EditorSyncStatus({
    required this.kind,
    required this.label,
    required this.snapshot,
  });

  final EditorSyncStatusKind kind;
  final String label;
  final EditorSyncSnapshot snapshot;
}

@visibleForTesting
EditorSyncStatus resolveEditorSyncStatus(EditorSyncSnapshot snapshot) {
  // V2 session states take priority
  if (snapshot.hasActiveSession) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.activeSession,
      label: 'Live session active',
      snapshot: snapshot,
    );
  }
  if (snapshot.hasPendingPublish) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.publishing,
      label: 'Publishing...',
      snapshot: snapshot,
    );
  }

  // Media states
  if (snapshot.blockedMediaCount > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.blocked,
      label: 'Upload blocked',
      snapshot: snapshot,
    );
  }
  if (snapshot.failedMediaCount > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.failed,
      label: 'Upload failed',
      snapshot: snapshot,
    );
  }
  if (snapshot.pendingMediaCount > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.syncing,
      label: 'Uploading...',
      snapshot: snapshot,
    );
  }

  // Entity sync states
  if (snapshot.unsyncedPlaceCount > 0 || snapshot.unsyncedRouteCount > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.localSaved,
      label: 'Saved locally',
      snapshot: snapshot,
    );
  }
  if (!snapshot.tripSynced) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.localSaved,
      label: 'Saved locally',
      snapshot: snapshot,
    );
  }

  // V2 uncommitted sessions (sealed but not published)
  if (snapshot.uncommittedSessionCount > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.localSaved,
      label: 'Unpublished captures',
      snapshot: snapshot,
    );
  }

  return EditorSyncStatus(
    kind: EditorSyncStatusKind.synced,
    label: 'Synced',
    snapshot: snapshot,
  );
}

/// Main editor sync status provider - monitors trip/place/route/media sync
/// and V2 session state.
final editorSyncStatusProvider =
    StreamProvider.family<EditorSyncStatus, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT
      -- Trip sync status
      (
        SELECT CASE
          WHEN t.sync_status = 'synced' OR (t.server_trip_id IS NOT NULL AND t.server_trip_id != '')
          THEN 1 ELSE 0
        END
        FROM trips AS t
        WHERE t.id = ?
      ) AS trip_synced,

      -- Place sync status
      (
        SELECT COUNT(*)
        FROM places AS p
        WHERE p.trip_id = ? AND p.sync_status != 'synced'
      ) AS unsynced_place_count,

      -- Route sync status
      (
        SELECT COUNT(*)
        FROM routes AS r
        WHERE r.trip_id = ? AND r.sync_status != 'synced'
      ) AS unsynced_route_count,

      -- Media upload states
      (
        SELECT COUNT(*)
        FROM media AS m
        WHERE m.trip_id = ? AND m.upload_status IN ('queued', 'compressing', 'uploading', 'deferred')
      ) AS pending_media_count,
      (
        SELECT COUNT(*)
        FROM media AS m
        WHERE m.trip_id = ? AND m.upload_status = 'failed'
      ) AS failed_media_count,
      (
        SELECT COUNT(*)
        FROM media AS m
        WHERE m.trip_id = ? AND m.upload_status = 'blocked'
      ) AS blocked_media_count,

      -- V2 session state: active or paused sessions
      (
        SELECT COUNT(*)
        FROM session_journal AS sj
        WHERE sj.trip_local_id = ? AND sj.control_state IN ('active', 'paused')
      ) AS active_session_count,

      -- V2 session state: uncommitted sealed sessions
      (
        SELECT COUNT(*)
        FROM session_journal AS sj
        WHERE sj.trip_local_id = ? AND sj.control_state = 'sealed'
      ) AS uncommitted_session_count,

      -- V2 publish state
      (
        SELECT CASE
          WHEN tps.publish_state = 'publishing' THEN 1 ELSE 0
        END
        FROM trip_publish_state AS tps
        WHERE tps.trip_local_id = ?
      ) AS is_publishing,

      -- First blocked media place for UI hint
      (
        SELECT m.place_id
        FROM media AS m
        WHERE m.trip_id = ?
          AND m.upload_status = 'blocked'
          AND m.place_id IS NOT NULL
        ORDER BY m.local_updated_at DESC
        LIMIT 1
      ) AS first_blocked_media_place_id
    ''',
    variables: [
      Variable<String>(tripId), // trip_synced
      Variable<String>(tripId), // unsynced_place_count
      Variable<String>(tripId), // unsynced_route_count
      Variable<String>(tripId), // pending_media_count
      Variable<String>(tripId), // failed_media_count
      Variable<String>(tripId), // blocked_media_count
      Variable<String>(tripId), // active_session_count
      Variable<String>(tripId), // uncommitted_session_count
      Variable<String>(tripId), // is_publishing
      Variable<String>(tripId), // first_blocked_media_place_id
    ],
    readsFrom: {
      db.trips,
      db.places,
      db.routes,
      db.media,
      db.sessionJournal,
      db.tripPublishState,
    },
  );

  return query.watchSingle().map((row) {
    final tripSynced = (row.read<int?>('trip_synced') ?? 0) == 1;
    final unsyncedPlaceCount = row.read<int?>('unsynced_place_count') ?? 0;
    final unsyncedRouteCount = row.read<int?>('unsynced_route_count') ?? 0;
    final pendingMediaCount = row.read<int?>('pending_media_count') ?? 0;
    final failedMediaCount = row.read<int?>('failed_media_count') ?? 0;
    final blockedMediaCount = row.read<int?>('blocked_media_count') ?? 0;
    final activeSessionCount = row.read<int?>('active_session_count') ?? 0;
    final uncommittedSessionCount =
        row.read<int?>('uncommitted_session_count') ?? 0;
    final isPublishing = (row.read<int?>('is_publishing') ?? 0) == 1;
    final firstBlockedMediaPlaceId =
        row.data['first_blocked_media_place_id'] as String?;

    return resolveEditorSyncStatus(
      EditorSyncSnapshot(
        tripSynced: tripSynced,
        unsyncedPlaceCount: unsyncedPlaceCount,
        unsyncedRouteCount: unsyncedRouteCount,
        pendingMediaCount: pendingMediaCount,
        failedMediaCount: failedMediaCount,
        blockedMediaCount: blockedMediaCount,
        hasActiveSession: activeSessionCount > 0,
        hasPendingPublish: isPublishing,
        uncommittedSessionCount: uncommittedSessionCount,
        firstBlockedMediaPlaceId: firstBlockedMediaPlaceId,
      ),
    );
  });
});

/// Snapshot of editor sync state for UI display.
class EditorSyncSnapshot {
  const EditorSyncSnapshot({
    required this.tripSynced,
    required this.unsyncedPlaceCount,
    required this.unsyncedRouteCount,
    required this.pendingMediaCount,
    required this.failedMediaCount,
    required this.blockedMediaCount,
    required this.hasActiveSession,
    required this.hasPendingPublish,
    required this.uncommittedSessionCount,
    this.firstBlockedMediaPlaceId,
  });

  final bool tripSynced;
  final int unsyncedPlaceCount;
  final int unsyncedRouteCount;
  final int pendingMediaCount;
  final int failedMediaCount;
  final int blockedMediaCount;
  final bool hasActiveSession;
  final bool hasPendingPublish;
  final int uncommittedSessionCount;
  final String? firstBlockedMediaPlaceId;

  /// True if all entities are synced and no media is pending.
  bool get isSynced =>
      tripSynced &&
      unsyncedPlaceCount == 0 &&
      unsyncedRouteCount == 0 &&
      pendingMediaCount == 0 &&
      failedMediaCount == 0 &&
      blockedMediaCount == 0 &&
      !hasActiveSession &&
      !hasPendingPublish;

  /// Legacy compatibility getters for tests that use old field names.
  @Deprecated('Use specific counters instead')
  int get blockedItems => blockedMediaCount;

  @Deprecated('Use specific counters instead')
  int get failedItems => failedMediaCount;

  @Deprecated('Use specific counters instead')
  int get activeItems => pendingMediaCount;

  @Deprecated('Use unsyncedPlaceCount + unsyncedRouteCount instead')
  int get unsyncedRows =>
      (tripSynced ? 0 : 1) + unsyncedPlaceCount + unsyncedRouteCount;
}
