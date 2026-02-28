import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/data/export_repository.dart';
import 'package:dora/features/export/domain/export_state.dart';

void main() {
  group('ExportRepository pre-submit guards', () {
    late AppDatabase database;
    late ExportRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = ExportRepository(database, Dio());
    });

    tearDown(() async {
      await database.close();
    });

    test('returns tripNotFound when trip does not exist', () async {
      final result = await repository.evaluatePreSubmitGuards('missing-trip');

      expect(result.tripExists, isFalse);
      expect(result.canExport, isFalse);
      expect(result.failures, [ExportPrecheckFailure.tripNotFound]);
    });

    test('blocks export when trip has no serverTripId', () async {
      await _insertTrip(
        database,
        tripId: 'trip-local-only',
        serverTripId: null,
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-local-only');

      expect(result.tripExists, isTrue);
      expect(result.hasServerTripId, isFalse);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.tripNotSynced));
    });

    test('blocks export when media queue has pending or failed items', () async {
      await _insertTrip(
        database,
        tripId: 'trip-with-media-issues',
        serverTripId: 'server-trip-1',
      );
      await _insertMedia(
        database,
        mediaId: 'media-queued',
        tripId: 'trip-with-media-issues',
        uploadStatus: 'queued',
      );
      await _insertMedia(
        database,
        mediaId: 'media-failed',
        tripId: 'trip-with-media-issues',
        uploadStatus: 'failed',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-with-media-issues');

      expect(result.pendingMediaCount, 1);
      expect(result.failedMediaCount, 1);
      expect(result.unresolvedMediaCount, 2);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.pendingMedia));
    });

    test('blocks export when sync queue has blocking trip task', () async {
      await _insertTrip(
        database,
        tripId: 'trip-with-sync-task',
        serverTripId: 'server-trip-2',
      );
      await _insertSyncTask(
        database,
        taskId: 'task-trip-queued',
        entityType: 'trip',
        entityId: 'trip-with-sync-task',
        status: 'queued',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-with-sync-task');

      expect(result.blockingSyncTaskCount, 1);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.pendingSync));
    });

    test('counts place-linked blocking sync tasks for the trip', () async {
      await _insertTrip(
        database,
        tripId: 'trip-with-place-task',
        serverTripId: 'server-trip-3',
      );
      await _insertPlace(
        database,
        placeId: 'place-1',
        tripId: 'trip-with-place-task',
      );
      await _insertSyncTask(
        database,
        taskId: 'task-place-in-progress',
        entityType: 'place',
        entityId: 'place-1',
        status: 'in_progress',
      );

      final result =
          await repository.evaluatePreSubmitGuards('trip-with-place-task');

      expect(result.blockingSyncTaskCount, 1);
      expect(result.canExport, isFalse);
      expect(result.failures, contains(ExportPrecheckFailure.pendingSync));
    });

    test('allows export when all pre-submit guards pass', () async {
      await _insertTrip(
        database,
        tripId: 'trip-ready',
        serverTripId: 'server-trip-ready',
      );

      final result = await repository.evaluatePreSubmitGuards('trip-ready');

      expect(result.tripExists, isTrue);
      expect(result.hasServerTripId, isTrue);
      expect(result.pendingMediaCount, 0);
      expect(result.failedMediaCount, 0);
      expect(result.blockingSyncTaskCount, 0);
      expect(result.failures, isEmpty);
      expect(result.canExport, isTrue);
    });
  });
}

Future<void> _insertTrip(
  AppDatabase database, {
  required String tripId,
  required String? serverTripId,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.trips).insert(
        TripsCompanion.insert(
          id: tripId,
          userId: 'user-1',
          name: 'Test Trip',
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
          serverTripId: Value(serverTripId),
        ),
      );
}

Future<void> _insertMedia(
  AppDatabase database, {
  required String mediaId,
  required String tripId,
  required String uploadStatus,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.media).insert(
        MediaCompanion.insert(
          id: mediaId,
          tripId: tripId,
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
          createdAt: now,
          uploadStatus: Value(uploadStatus),
        ),
      );
}

Future<void> _insertPlace(
  AppDatabase database, {
  required String placeId,
  required String tripId,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.places).insert(
        PlacesCompanion.insert(
          id: placeId,
          tripId: tripId,
          name: 'Test Place',
          coordinates: const AppLatLng(latitude: 12.9716, longitude: 77.5946),
          orderIndex: 0,
          localUpdatedAt: now,
          serverUpdatedAt: now,
          syncStatus: 'synced',
        ),
      );
}

Future<void> _insertSyncTask(
  AppDatabase database, {
  required String taskId,
  required String entityType,
  required String entityId,
  required String status,
}) async {
  final now = DateTime(2026, 2, 28, 10, 0, 0);
  await database.into(database.syncTasks).insert(
        SyncTasksCompanion.insert(
          id: taskId,
          entityType: entityType,
          entityId: entityId,
          operation: 'update',
          status: Value(status),
          createdAt: now,
          updatedAt: now,
        ),
      );
}
