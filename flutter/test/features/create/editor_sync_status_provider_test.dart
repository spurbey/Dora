import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';

void main() {
  group('resolveEditorSyncStatus', () {
    test('returns blocked when blocked items exist', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 1,
          failedItems: 5,
          activeItems: 10,
          unsyncedRows: 3,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.blocked);
      expect(status.label, 'Sync blocked');
    });

    test('returns failed when failed items exist without blocked', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 2,
          activeItems: 10,
          unsyncedRows: 3,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.failed);
      expect(status.label, 'Sync failed');
    });

    test('returns syncing when active items exist', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 0,
          activeItems: 4,
          unsyncedRows: 5,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.syncing);
      expect(status.label, 'Syncing...');
    });

    test('returns localSaved when unsynced rows exist without active work', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 0,
          activeItems: 0,
          unsyncedRows: 2,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Saved locally');
    });

    test('returns synced when no pending or failed signals exist', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          blockedItems: 0,
          failedItems: 0,
          activeItems: 0,
          unsyncedRows: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.synced);
      expect(status.label, 'Synced');
    });
  });

  test('editorSyncStatusProvider includes blocked tracking tasks for trip',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final now = DateTime.utc(2026, 3, 26, 10, 0);
    await db.tripDao.insertTrip(
      TripsCompanion.insert(
        id: 'trip-tracking-1',
        serverTripId: const Value('remote-trip-tracking-1'),
        userId: 'user-1',
        name: 'Trip Tracking',
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'synced',
        createdAt: now,
      ),
    );
    await db.into(db.trackingSessions).insert(
          TrackingSessionsCompanion.insert(
            id: 'tracking-session-1',
            tripId: 'trip-tracking-1',
            clientSessionId: 'client-session-1',
            state: const Value('planned'),
            localUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.syncTasks).insert(
          SyncTasksCompanion.insert(
            id: 'task-tracking-session-1',
            entityType: SyncEntityTypes.trackingSession,
            entityId: 'tracking-session-1',
            operation: 'start',
            status: const Value('blocked'),
            pendingRequeue: const Value(false),
            retryCount: const Value(0),
            nextAttemptAt: const Value(null),
            errorCode: const Value('tracking_trip_remote_id_missing'),
            errorMessage: const Value('Trip identity missing'),
            workerSessionId: const Value(null),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
      ],
    );
    addTearDown(() {
      container.dispose();
    });
    addTearDown(() async {
      await db.close();
    });

    final status = await container
        .read(editorSyncStatusProvider('trip-tracking-1').future);
    expect(status.kind, EditorSyncStatusKind.blocked);
    expect(status.snapshot.firstBlockedTaskEntityType,
        SyncEntityTypes.trackingSession);
    expect(status.snapshot.firstBlockedTaskEntityId, 'tracking-session-1');
  });

  test('liveTrackingSyncStatusProvider ignores blocked non-tracking tasks',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final now = DateTime.utc(2026, 3, 30, 8, 0);
    await db.tripDao.insertTrip(
      TripsCompanion.insert(
        id: 'trip-live-scope-1',
        serverTripId: const Value('remote-trip-live-scope-1'),
        userId: 'user-1',
        name: 'Live Scope Trip',
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'synced',
        createdAt: now,
      ),
    );
    await db.placeDao.insertPlace(
      PlacesCompanion.insert(
        id: 'place-live-scope-1',
        tripId: 'trip-live-scope-1',
        name: 'Blocked Place',
        coordinates: const AppLatLng(latitude: 27.7, longitude: 85.3),
        orderIndex: 0,
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'pending',
      ),
    );
    await db.into(db.syncTasks).insert(
          SyncTasksCompanion.insert(
            id: 'task-place-blocked-1',
            entityType: SyncEntityTypes.place,
            entityId: 'place-live-scope-1',
            operation: 'update',
            status: const Value('blocked'),
            pendingRequeue: const Value(false),
            retryCount: const Value(0),
            nextAttemptAt: const Value(null),
            errorCode: const Value('place_conflict'),
            errorMessage: const Value('Place failed'),
            workerSessionId: const Value(null),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
      ],
    );
    addTearDown(() {
      container.dispose();
    });
    addTearDown(() async {
      await db.close();
    });

    final liveStatus = await container
        .read(liveTrackingSyncStatusProvider('trip-live-scope-1').future);
    expect(liveStatus.kind, EditorSyncStatusKind.synced);
    expect(liveStatus.snapshot.blockedItems, 0);
  });

  test('liveTrackingSyncStatusProvider blocks on tracking task failures',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final now = DateTime.utc(2026, 3, 30, 8, 30);
    await db.tripDao.insertTrip(
      TripsCompanion.insert(
        id: 'trip-live-scope-2',
        serverTripId: const Value('remote-trip-live-scope-2'),
        userId: 'user-1',
        name: 'Live Scope Trip 2',
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'synced',
        createdAt: now,
      ),
    );
    await db.into(db.trackingSessions).insert(
          TrackingSessionsCompanion.insert(
            id: 'tracking-session-live-scope-1',
            tripId: 'trip-live-scope-2',
            clientSessionId: 'client-session-live-scope-1',
            state: const Value('active'),
            syncStatus: const Value('pending'),
            localUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.syncTasks).insert(
          SyncTasksCompanion.insert(
            id: 'task-tracking-session-blocked-1',
            entityType: SyncEntityTypes.trackingSession,
            entityId: 'tracking-session-live-scope-1',
            operation: 'start',
            status: const Value('blocked'),
            pendingRequeue: const Value(false),
            retryCount: const Value(0),
            nextAttemptAt: const Value(null),
            errorCode: const Value('tracking_trip_remote_id_missing'),
            errorMessage: const Value('Trip identity missing'),
            workerSessionId: const Value(null),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
      ],
    );
    addTearDown(() {
      container.dispose();
    });
    addTearDown(() async {
      await db.close();
    });

    final liveStatus = await container
        .read(liveTrackingSyncStatusProvider('trip-live-scope-2').future);
    expect(liveStatus.kind, EditorSyncStatusKind.blocked);
    expect(liveStatus.snapshot.firstBlockedTaskEntityType,
        SyncEntityTypes.trackingSession);
  });

  test('liveTrackingSyncStatusProvider ignores start 409 policy blocks',
      () async {
    final db = AppDatabase(NativeDatabase.memory());
    final now = DateTime.utc(2026, 3, 30, 9, 0);
    await db.tripDao.insertTrip(
      TripsCompanion.insert(
        id: 'trip-live-scope-3',
        serverTripId: const Value('remote-trip-live-scope-3'),
        userId: 'user-1',
        name: 'Live Scope Trip 3',
        localUpdatedAt: now,
        serverUpdatedAt: now,
        syncStatus: 'synced',
        createdAt: now,
      ),
    );
    await db.into(db.trackingSessions).insert(
          TrackingSessionsCompanion.insert(
            id: 'tracking-session-live-scope-3',
            tripId: 'trip-live-scope-3',
            clientSessionId: 'client-session-live-scope-3',
            state: const Value('active'),
            syncStatus: const Value('pending'),
            localUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.into(db.syncTasks).insert(
          SyncTasksCompanion.insert(
            id: 'task-tracking-session-blocked-409',
            entityType: SyncEntityTypes.trackingSession,
            entityId: 'tracking-session-live-scope-3',
            operation: 'start',
            status: const Value('blocked'),
            pendingRequeue: const Value(false),
            retryCount: const Value(0),
            nextAttemptAt: const Value(null),
            errorCode: const Value('http_409'),
            errorMessage: const Value(
              'Tracking can only be started from planned trip status',
            ),
            workerSessionId: const Value(null),
            createdAt: now,
            updatedAt: now,
          ),
        );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) => db),
      ],
    );
    addTearDown(() {
      container.dispose();
    });
    addTearDown(() async {
      await db.close();
    });

    final liveStatus = await container
        .read(liveTrackingSyncStatusProvider('trip-live-scope-3').future);
    expect(liveStatus.kind, EditorSyncStatusKind.localSaved);
    expect(liveStatus.snapshot.blockedItems, 0);
  });
}
