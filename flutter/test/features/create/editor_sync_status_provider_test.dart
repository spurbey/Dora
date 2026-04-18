import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/presentation/providers/editor_sync_status_provider.dart';

void main() {
  group('resolveEditorSyncStatus', () {
    test('returns activeSession when session is active', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: true,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.activeSession);
      expect(status.label, 'Live session active');
    });

    test('returns publishing when publish is in progress', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: true,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.publishing);
      expect(status.label, 'Publishing...');
    });

    test('returns blocked when media is blocked', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 2,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.blocked);
      expect(status.label, 'Upload blocked');
    });

    test('returns failed when media upload failed', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 3,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.failed);
      expect(status.label, 'Upload failed');
    });

    test('returns syncing when media is uploading', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 5,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.syncing);
      expect(status.label, 'Uploading...');
    });

    test('returns localSaved when places are unsynced', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 2,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Saved locally');
    });

    test('returns localSaved when routes are unsynced', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 1,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Saved locally');
    });

    test('returns localSaved when trip is not synced', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: false,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Saved locally');
    });

    test('returns localSaved with uncommitted sessions', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 2,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Unpublished captures');
    });

    test('returns synced when everything is synced', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 0,
          hasActiveSession: false,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.synced);
      expect(status.label, 'Synced');
    });

    test('activeSession takes priority over blocked media', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 5,
          hasActiveSession: true,
          hasPendingPublish: false,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.activeSession);
    });

    test('publishing takes priority over blocked media', () {
      final status = resolveEditorSyncStatus(
        const EditorSyncSnapshot(
          tripSynced: true,
          unsyncedPlaceCount: 0,
          unsyncedRouteCount: 0,
          pendingMediaCount: 0,
          failedMediaCount: 0,
          blockedMediaCount: 5,
          hasActiveSession: false,
          hasPendingPublish: true,
          uncommittedSessionCount: 0,
        ),
      );

      expect(status.kind, EditorSyncStatusKind.publishing);
    });
  });

  group('editorSyncStatusProvider integration', () {
    test('shows active session status when V2 session is active', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.utc(2026, 4, 17, 10, 0);

      await db.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-1',
          serverTripId: const Value('remote-trip-1'),
          userId: 'user-1',
          name: 'Test Trip',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
        ),
      );

      await db.into(db.sessionJournal).insert(
            SessionJournalCompanion.insert(
              sessionId: 'session-1',
              tripLocalId: 'trip-1',
              controlState: 'active',
              sessionSeq: 1,
              deviceId: 'device-1',
              startedAt: Value(now),
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

      final status =
          await container.read(editorSyncStatusProvider('trip-1').future);
      expect(status.kind, EditorSyncStatusKind.activeSession);
      expect(status.snapshot.hasActiveSession, isTrue);
    });

    test('shows publishing status when V2 publish is in progress', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.utc(2026, 4, 17, 10, 0);

      await db.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-2',
          serverTripId: const Value('remote-trip-2'),
          userId: 'user-1',
          name: 'Test Trip 2',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
        ),
      );

      await db.into(db.tripPublishState).insert(
            TripPublishStateCompanion.insert(
              tripLocalId: 'trip-2',
              publishState: const Value('publishing'),
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

      final status =
          await container.read(editorSyncStatusProvider('trip-2').future);
      expect(status.kind, EditorSyncStatusKind.publishing);
      expect(status.snapshot.hasPendingPublish, isTrue);
    });

    test('shows blocked when media upload is blocked', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.utc(2026, 4, 17, 10, 0);

      await db.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-3',
          serverTripId: const Value('remote-trip-3'),
          userId: 'user-1',
          name: 'Test Trip 3',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
        ),
      );

      await db.placeDao.insertPlace(
        PlacesCompanion.insert(
          id: 'place-1',
          tripId: 'trip-3',
          name: 'Test Place',
          coordinates: const AppLatLng(latitude: 27.7, longitude: 85.3),
          orderIndex: 0,
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
        ),
      );

      await db.into(db.media).insert(
            MediaCompanion.insert(
              id: 'media-1',
              tripId: 'trip-3',
              placeId: const Value('place-1'),
              localUpdatedAt: now,
              serverUpdatedAt: now,
              syncStatus: 'synced',
              createdAt: now,
              uploadStatus: const Value('blocked'),
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

      final status =
          await container.read(editorSyncStatusProvider('trip-3').future);
      expect(status.kind, EditorSyncStatusKind.blocked);
      expect(status.snapshot.blockedMediaCount, 1);
      expect(status.snapshot.firstBlockedMediaPlaceId, 'place-1');
    });

    test('shows localSaved with uncommitted sealed sessions', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.utc(2026, 4, 17, 10, 0);

      await db.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-4',
          serverTripId: const Value('remote-trip-4'),
          userId: 'user-1',
          name: 'Test Trip 4',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
        ),
      );

      await db.into(db.sessionJournal).insert(
            SessionJournalCompanion.insert(
              sessionId: 'session-2',
              tripLocalId: 'trip-4',
              controlState: 'sealed',
              sessionSeq: 1,
              deviceId: 'device-1',
              startedAt: Value(now),
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

      final status =
          await container.read(editorSyncStatusProvider('trip-4').future);
      expect(status.kind, EditorSyncStatusKind.localSaved);
      expect(status.label, 'Unpublished captures');
      expect(status.snapshot.uncommittedSessionCount, 1);
    });

    test('shows synced when all conditions are met', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final now = DateTime.utc(2026, 4, 17, 10, 0);

      await db.tripDao.insertTrip(
        TripsCompanion.insert(
          id: 'trip-5',
          serverTripId: const Value('remote-trip-5'),
          userId: 'user-1',
          name: 'Test Trip 5',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
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

      final status =
          await container.read(editorSyncStatusProvider('trip-5').future);
      expect(status.kind, EditorSyncStatusKind.synced);
      expect(status.snapshot.isSynced, isTrue);
    });
  });
}
