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
    SELECT
      (
        SELECT COUNT(*)
        FROM sync_tasks AS t
        WHERE (
            (t.entity_type = 'trip' AND t.entity_id = ?)
            OR (t.entity_type = 'place' AND t.entity_id IN (
              SELECT p.id FROM places AS p WHERE p.trip_id = ?
            ))
            OR (t.entity_type = 'route' AND t.entity_id IN (
              SELECT r.id FROM routes AS r WHERE r.trip_id = ?
            ))
          )
          AND t.status = 'blocked'
      ) AS blocked_tasks,
      (
        SELECT COUNT(*)
        FROM sync_tasks AS t
        WHERE (
            (t.entity_type = 'trip' AND t.entity_id = ?)
            OR (t.entity_type = 'place' AND t.entity_id IN (
              SELECT p.id FROM places AS p WHERE p.trip_id = ?
            ))
            OR (t.entity_type = 'route' AND t.entity_id IN (
              SELECT r.id FROM routes AS r WHERE r.trip_id = ?
            ))
          )
          AND t.status = 'failed'
      ) AS failed_tasks,
      (
        SELECT COUNT(*)
        FROM sync_tasks AS t
        WHERE (
            (t.entity_type = 'trip' AND t.entity_id = ?)
            OR (t.entity_type = 'place' AND t.entity_id IN (
              SELECT p.id FROM places AS p WHERE p.trip_id = ?
            ))
            OR (t.entity_type = 'route' AND t.entity_id IN (
              SELECT r.id FROM routes AS r WHERE r.trip_id = ?
            ))
          )
          AND t.status IN ('queued', 'pending', 'in_progress', 'deferred')
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
        SELECT t.entity_type
        FROM sync_tasks AS t
        WHERE (
            (t.entity_type = 'trip' AND t.entity_id = ?)
            OR (t.entity_type = 'place' AND t.entity_id IN (
              SELECT p.id FROM places AS p WHERE p.trip_id = ?
            ))
            OR (t.entity_type = 'route' AND t.entity_id IN (
              SELECT r.id FROM routes AS r WHERE r.trip_id = ?
            ))
          )
          AND t.status = 'blocked'
        ORDER BY t.updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_entity_type,
      (
        SELECT t.entity_id
        FROM sync_tasks AS t
        WHERE (
            (t.entity_type = 'trip' AND t.entity_id = ?)
            OR (t.entity_type = 'place' AND t.entity_id IN (
              SELECT p.id FROM places AS p WHERE p.trip_id = ?
            ))
            OR (t.entity_type = 'route' AND t.entity_id IN (
              SELECT r.id FROM routes AS r WHERE r.trip_id = ?
            ))
          )
          AND t.status = 'blocked'
        ORDER BY t.updated_at DESC
        LIMIT 1
      ) AS first_blocked_task_entity_id,
      (
        SELECT t.error_message
        FROM sync_tasks AS t
        WHERE (
            (t.entity_type = 'trip' AND t.entity_id = ?)
            OR (t.entity_type = 'place' AND t.entity_id IN (
              SELECT p.id FROM places AS p WHERE p.trip_id = ?
            ))
            OR (t.entity_type = 'route' AND t.entity_id IN (
              SELECT r.id FROM routes AS r WHERE r.trip_id = ?
            ))
          )
          AND t.status = 'blocked'
        ORDER BY t.updated_at DESC
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
        row.read<int>('unsynced_route_rows');
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
