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
  if (snapshot.blockedItems > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.blocked,
      label: 'Sync blocked',
      snapshot: snapshot,
    );
  }
  if (snapshot.failedItems > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.failed,
      label: 'Sync failed',
      snapshot: snapshot,
    );
  }
  if (snapshot.activeItems > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.syncing,
      label: 'Syncing...',
      snapshot: snapshot,
    );
  }
  if (snapshot.unsyncedRows > 0) {
    return EditorSyncStatus(
      kind: EditorSyncStatusKind.localSaved,
      label: 'Saved locally',
      snapshot: snapshot,
    );
  }
  return EditorSyncStatus(
    kind: EditorSyncStatusKind.synced,
    label: 'Synced',
    snapshot: snapshot,
  );
}

final editorSyncStatusProvider =
    StreamProvider.family<EditorSyncStatus, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    WITH scoped_sync_tasks AS (
      SELECT
        t.entity_type,
        t.entity_id,
        t.status,
        t.updated_at,
        t.error_message
      FROM sync_tasks AS t
      WHERE (
          (t.entity_type = 'trip' AND t.entity_id = ?)
          OR (t.entity_type = 'place' AND t.entity_id IN (
            SELECT p.id FROM places AS p WHERE p.trip_id = ?
          ))
          OR (t.entity_type = 'route' AND t.entity_id IN (
            SELECT r.id FROM routes AS r WHERE r.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_session' AND t.entity_id IN (
            SELECT s.id FROM tracking_sessions AS s WHERE s.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_point_batch' AND t.entity_id IN (
            SELECT b.id FROM tracking_point_batches AS b WHERE b.trip_id = ?
          ))
          OR (t.entity_type = 'moment' AND t.entity_id IN (
            SELECT m.id FROM tracking_moments AS m WHERE m.trip_id = ?
          ))
          OR (t.entity_type = 'checkin_decision' AND t.entity_id IN (
            SELECT c.id FROM tracking_candidates AS c WHERE c.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_event' AND t.entity_id IN (
            SELECT e.id FROM tracking_events AS e WHERE e.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_event_media' AND t.entity_id IN (
            SELECT em.id FROM tracking_event_media AS em WHERE em.trip_id = ?
          ))
      )
    )
    SELECT
      (
        SELECT COUNT(*) FROM scoped_sync_tasks
        WHERE status = 'blocked'
      ) AS blocked_tasks,
      (
        SELECT COUNT(*) FROM scoped_sync_tasks
        WHERE status = 'failed'
      ) AS failed_tasks,
      (
        SELECT COUNT(*) FROM scoped_sync_tasks
        WHERE status IN ('queued', 'pending', 'in_progress', 'deferred')
      ) AS active_tasks,
      (
        SELECT COUNT(*)
        FROM media AS m
        WHERE m.trip_id = ? AND m.upload_status = 'blocked'
      ) AS blocked_media,
      (
        SELECT COUNT(*)
        FROM media AS m
        WHERE m.trip_id = ? AND m.upload_status = 'failed'
      ) AS failed_media,
      (
        SELECT COUNT(*)
        FROM media AS m
        WHERE m.trip_id = ?
          AND m.upload_status IN ('queued', 'compressing', 'uploading', 'deferred')
      ) AS active_media,
      (
        SELECT COUNT(*)
        FROM trips AS t
        WHERE t.id = ? AND t.sync_status <> 'synced'
      ) AS unsynced_trip_rows,
      (
        SELECT COUNT(*)
        FROM places AS p
        WHERE p.trip_id = ? AND p.sync_status <> 'synced'
      ) AS unsynced_place_rows,
      (
        SELECT COUNT(*)
        FROM routes AS r
        WHERE r.trip_id = ? AND r.sync_status <> 'synced'
      ) AS unsynced_route_rows,
      (
        SELECT COUNT(*)
        FROM tracking_event_media AS em
        WHERE em.trip_id = ? AND em.sync_status <> 'synced'
      ) AS unsynced_tracking_media_rows,
      (
        SELECT entity_type
        FROM scoped_sync_tasks
        WHERE status = 'blocked'
        ORDER BY updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_entity_type,
      (
        SELECT entity_id
        FROM scoped_sync_tasks
        WHERE status = 'blocked'
        ORDER BY updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_entity_id,
      (
        SELECT error_message
        FROM scoped_sync_tasks
        WHERE status = 'blocked'
        ORDER BY updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_error_message,
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
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ],
    readsFrom: {
      db.syncTasks,
      db.media,
      db.trips,
      db.places,
      db.routes,
      db.trackingSessions,
      db.trackingPointBatches,
      db.trackingMoments,
      db.trackingCandidates,
      db.trackingEvents,
      db.trackingEventMedia,
    },
  );

  return query.watchSingle().map((row) {
    final blockedItems =
        row.read<int>('blocked_tasks') + row.read<int>('blocked_media');
    final failedItems =
        row.read<int>('failed_tasks') + row.read<int>('failed_media');
    final activeItems =
        row.read<int>('active_tasks') + row.read<int>('active_media');
    final unsyncedRows = row.read<int>('unsynced_trip_rows') +
        row.read<int>('unsynced_place_rows') +
        row.read<int>('unsynced_route_rows') +
        row.read<int>('unsynced_tracking_media_rows');
    final blockedMediaItems = row.read<int>('blocked_media');
    final failedMediaItems = row.read<int>('failed_media');
    final firstBlockedTaskEntityType =
        row.data['first_blocked_task_entity_type'] as String?;
    final firstBlockedTaskEntityId =
        row.data['first_blocked_task_entity_id'] as String?;
    final firstBlockedTaskErrorMessage =
        row.data['first_blocked_task_error_message'] as String?;
    final firstBlockedMediaPlaceId =
        row.data['first_blocked_media_place_id'] as String?;

    return resolveEditorSyncStatus(
      EditorSyncSnapshot(
        blockedItems: blockedItems,
        failedItems: failedItems,
        activeItems: activeItems,
        unsyncedRows: unsyncedRows,
        blockedMediaItems: blockedMediaItems,
        failedMediaItems: failedMediaItems,
        firstBlockedTaskEntityType: firstBlockedTaskEntityType,
        firstBlockedTaskEntityId: firstBlockedTaskEntityId,
        firstBlockedTaskErrorMessage: firstBlockedTaskErrorMessage,
        firstBlockedMediaPlaceId: firstBlockedMediaPlaceId,
      ),
    );
  });
});

final liveTrackingSyncStatusProvider =
    StreamProvider.family<EditorSyncStatus, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    WITH scoped_tracking_tasks AS (
      SELECT
        t.entity_type,
        t.entity_id,
        t.operation,
        t.status,
        t.error_code,
        t.updated_at,
        t.error_message
      FROM sync_tasks AS t
      WHERE (
          (t.entity_type = 'trip' AND t.entity_id = ?)
          OR
          (t.entity_type = 'tracking_session' AND t.entity_id IN (
            SELECT s.id FROM tracking_sessions AS s WHERE s.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_point_batch' AND t.entity_id IN (
            SELECT b.id FROM tracking_point_batches AS b WHERE b.trip_id = ?
          ))
          OR (t.entity_type = 'moment' AND t.entity_id IN (
            SELECT m.id FROM tracking_moments AS m WHERE m.trip_id = ?
          ))
          OR (t.entity_type = 'checkin_decision' AND t.entity_id IN (
            SELECT c.id FROM tracking_candidates AS c WHERE c.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_event' AND t.entity_id IN (
            SELECT e.id FROM tracking_events AS e WHERE e.trip_id = ?
          ))
          OR (t.entity_type = 'tracking_event_media' AND t.entity_id IN (
            SELECT em.id FROM tracking_event_media AS em WHERE em.trip_id = ?
          ))
      )
    )
    SELECT
      (
        SELECT COUNT(*) FROM scoped_tracking_tasks
        WHERE status = 'blocked'
          AND NOT (
            entity_type = 'tracking_session'
            AND operation = 'start'
            AND error_code = 'http_409'
          )
      ) AS blocked_tasks,
      (
        SELECT COUNT(*) FROM scoped_tracking_tasks
        WHERE status = 'failed'
      ) AS failed_tasks,
      (
        SELECT COUNT(*) FROM scoped_tracking_tasks
        WHERE status IN ('queued', 'pending', 'in_progress', 'deferred')
      ) AS active_tasks,
      (
        SELECT COUNT(*)
        FROM trips AS t
        WHERE t.id = ? AND t.sync_status <> 'synced'
      ) AS unsynced_trip_rows,
      (
        SELECT COUNT(*)
        FROM tracking_sessions AS s
        WHERE s.trip_id = ? AND s.sync_status <> 'synced'
      ) AS unsynced_session_rows,
      (
        SELECT COUNT(*)
        FROM tracking_point_batches AS b
        WHERE b.trip_id = ? AND b.sync_status <> 'synced'
      ) AS unsynced_batch_rows,
      (
        SELECT COUNT(*)
        FROM tracking_moments AS m
        WHERE m.trip_id = ? AND m.sync_status <> 'synced'
      ) AS unsynced_moment_rows,
      (
        SELECT COUNT(*)
        FROM tracking_candidates AS c
        WHERE c.trip_id = ? AND c.sync_status <> 'synced'
      ) AS unsynced_candidate_rows,
      (
        SELECT COUNT(*)
        FROM tracking_events AS e
        WHERE e.trip_id = ? AND e.sync_status <> 'synced'
      ) AS unsynced_event_rows,
      (
        SELECT COUNT(*)
        FROM tracking_event_media AS em
        WHERE em.trip_id = ? AND em.sync_status <> 'synced'
      ) AS unsynced_tracking_media_rows,
      (
        SELECT entity_type
        FROM scoped_tracking_tasks
        WHERE status = 'blocked'
          AND NOT (
            entity_type = 'tracking_session'
            AND operation = 'start'
            AND error_code = 'http_409'
          )
        ORDER BY updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_entity_type,
      (
        SELECT entity_id
        FROM scoped_tracking_tasks
        WHERE status = 'blocked'
          AND NOT (
            entity_type = 'tracking_session'
            AND operation = 'start'
            AND error_code = 'http_409'
          )
        ORDER BY updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_entity_id,
      (
        SELECT error_message
        FROM scoped_tracking_tasks
        WHERE status = 'blocked'
          AND NOT (
            entity_type = 'tracking_session'
            AND operation = 'start'
            AND error_code = 'http_409'
          )
        ORDER BY updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_error_message
    ''',
    variables: [
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ],
    readsFrom: {
      db.syncTasks,
      db.trips,
      db.trackingSessions,
      db.trackingPointBatches,
      db.trackingMoments,
      db.trackingCandidates,
      db.trackingEvents,
      db.trackingEventMedia,
    },
  );

  return query.watchSingle().map((row) {
    final blockedItems = row.read<int>('blocked_tasks');
    final failedItems = row.read<int>('failed_tasks');
    final activeItems = row.read<int>('active_tasks');
    final unsyncedRows = row.read<int>('unsynced_trip_rows') +
        row.read<int>('unsynced_session_rows') +
        row.read<int>('unsynced_batch_rows') +
        row.read<int>('unsynced_moment_rows') +
        row.read<int>('unsynced_candidate_rows') +
        row.read<int>('unsynced_event_rows') +
        row.read<int>('unsynced_tracking_media_rows');
    final firstBlockedTaskEntityType =
        row.data['first_blocked_task_entity_type'] as String?;
    final firstBlockedTaskEntityId =
        row.data['first_blocked_task_entity_id'] as String?;
    final firstBlockedTaskErrorMessage =
        row.data['first_blocked_task_error_message'] as String?;

    return resolveEditorSyncStatus(
      EditorSyncSnapshot(
        blockedItems: blockedItems,
        failedItems: failedItems,
        activeItems: activeItems,
        unsyncedRows: unsyncedRows,
        blockedMediaItems: 0,
        failedMediaItems: 0,
        firstBlockedTaskEntityType: firstBlockedTaskEntityType,
        firstBlockedTaskEntityId: firstBlockedTaskEntityId,
        firstBlockedTaskErrorMessage: firstBlockedTaskErrorMessage,
        firstBlockedMediaPlaceId: null,
      ),
    );
  });
});

class EditorSyncSnapshot {
  const EditorSyncSnapshot({
    required this.blockedItems,
    required this.failedItems,
    required this.activeItems,
    required this.unsyncedRows,
    this.blockedMediaItems = 0,
    this.failedMediaItems = 0,
    this.firstBlockedTaskEntityType,
    this.firstBlockedTaskEntityId,
    this.firstBlockedTaskErrorMessage,
    this.firstBlockedMediaPlaceId,
  });

  final int blockedItems;
  final int failedItems;
  final int activeItems;
  final int unsyncedRows;
  final int blockedMediaItems;
  final int failedMediaItems;
  final String? firstBlockedTaskEntityType;
  final String? firstBlockedTaskEntityId;
  final String? firstBlockedTaskErrorMessage;
  final String? firstBlockedMediaPlaceId;
}
