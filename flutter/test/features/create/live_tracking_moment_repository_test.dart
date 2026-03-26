import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/create/data/live_tracking_moment_repository.dart';

class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

void main() {
  group('LiveTrackingMomentRepository', () {
    late AppDatabase database;
    late TrackingMomentDao momentDao;
    late SyncTaskDao syncTaskDao;
    late _FakeClock clock;
    late LiveTrackingMomentRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      momentDao = TrackingMomentDao(database);
      syncTaskDao = SyncTaskDao(database);
      clock = _FakeClock(DateTime.utc(2026, 3, 26, 10, 0, 0));
      repository = LiveTrackingMomentRepository(
        trackingMomentDao: momentDao,
        syncTaskDao: syncTaskDao,
        now: clock.call,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('createMomentNow stores pending create and queues sync task',
        () async {
      final momentId = await repository.createMomentNow(
        tripId: 'trip-1',
        note: '  Sunrise point  ',
        latitude: 27.7,
        longitude: 85.3,
      );

      final row = await momentDao.getMomentById(momentId);
      expect(row, isNotNull);
      expect(row!.tripId, 'trip-1');
      expect(row.pendingOperation, 'create');
      expect(row.clientEventId, isNotNull);
      expect(row.note, 'Sunrise point');
      expect(row.syncStatus, 'pending');
      expect(row.latitude, 27.7);
      expect(row.longitude, 85.3);

      final task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.moment,
        entityId: momentId,
      );
      expect(task, isNotNull);
      expect(task!.operation, 'create');
      expect(task.status, 'queued');
    });

    test('queueNoteUpdate on synced moment switches to update operation',
        () async {
      final now = clock.now.toUtc();
      await _insertMoment(
        momentDao,
        id: 'moment-1',
        tripId: 'trip-1',
        createdAt: now,
        pendingOperation: null,
      );

      await repository.queueNoteUpdate(
        tripId: 'trip-1',
        momentId: 'moment-1',
        note: '  Updated note  ',
      );

      final row = await momentDao.getMomentById('moment-1');
      expect(row, isNotNull);
      expect(row!.pendingOperation, 'update');
      expect(row.note, 'Updated note');
      expect(row.clientEventId, isNotNull);
      expect(row.syncStatus, 'pending');

      final task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.moment,
        entityId: 'moment-1',
      );
      expect(task, isNotNull);
      expect(task!.operation, 'update');
    });

    test('queueNoteUpdate preserves create operation for unsynced moment',
        () async {
      final now = clock.now.toUtc();
      await _insertMoment(
        momentDao,
        id: 'moment-2',
        tripId: 'trip-1',
        createdAt: now,
        pendingOperation: 'create',
      );

      await repository.queueNoteUpdate(
        tripId: 'trip-1',
        momentId: 'moment-2',
        note: 'Edited before first sync',
      );

      final row = await momentDao.getMomentById('moment-2');
      expect(row, isNotNull);
      expect(row!.pendingOperation, 'create');

      final task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.moment,
        entityId: 'moment-2',
      );
      expect(task, isNotNull);
      expect(task!.operation, 'create');
    });
  });
}

Future<void> _insertMoment(
  TrackingMomentDao dao, {
  required String id,
  required String tripId,
  required DateTime createdAt,
  required String? pendingOperation,
}) async {
  await dao.upsertMoment(
    TrackingMomentsCompanion.insert(
      id: id,
      tripId: tripId,
      source: const Value('manual'),
      capturedAt: createdAt,
      note: const Value('original note'),
      pendingOperation: Value(pendingOperation),
      syncStatus: const Value('synced'),
      localUpdatedAt: createdAt,
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
  );
}
