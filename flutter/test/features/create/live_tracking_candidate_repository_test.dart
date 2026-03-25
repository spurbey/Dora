import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/create/data/live_tracking_candidate_repository.dart';

class _FakeClock {
  _FakeClock(this.now);

  DateTime now;

  DateTime call() => now;
}

void main() {
  group('LiveTrackingCandidateRepository', () {
    late AppDatabase database;
    late TrackingCandidateDao candidateDao;
    late SyncTaskDao syncTaskDao;
    late _FakeClock clock;
    late LiveTrackingCandidateRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      candidateDao = TrackingCandidateDao(database);
      syncTaskDao = SyncTaskDao(database);
      clock = _FakeClock(DateTime.utc(2026, 3, 25, 9, 0, 0));
      repository = LiveTrackingCandidateRepository(
        trackingCandidateDao: candidateDao,
        syncTaskDao: syncTaskDao,
        now: clock.call,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('filters inbox candidates by status/action state', () async {
      final now = clock.now.toUtc();
      await _insertCandidate(
        candidateDao,
        id: 'pending',
        tripId: 'trip-1',
        createdAt: now,
      );
      await _insertCandidate(
        candidateDao,
        id: 'confirmed',
        tripId: 'trip-1',
        createdAt: now.subtract(const Duration(minutes: 1)),
        status: 'confirmed',
      );
      await _insertCandidate(
        candidateDao,
        id: 'snoozed_future',
        tripId: 'trip-1',
        createdAt: now.subtract(const Duration(minutes: 2)),
        status: 'snoozed',
        snoozedUntil: now.add(const Duration(hours: 2)),
      );
      await _insertCandidate(
        candidateDao,
        id: 'snoozed_due',
        tripId: 'trip-1',
        createdAt: now.subtract(const Duration(minutes: 3)),
        status: 'snoozed',
        snoozedUntil: now.subtract(const Duration(minutes: 5)),
      );
      await _insertCandidate(
        candidateDao,
        id: 'queued_action',
        tripId: 'trip-1',
        createdAt: now.subtract(const Duration(minutes: 4)),
        status: 'rejected',
        actionState: 'queued',
      );

      final inbox = await repository.getInboxCandidates('trip-1');
      final ids = inbox.map((row) => row.id).toList(growable: false);

      expect(ids, contains('pending'));
      expect(ids, contains('snoozed_due'));
      expect(ids, contains('queued_action'));
      expect(ids, isNot(contains('confirmed')));
      expect(ids, isNot(contains('snoozed_future')));
    });

    test('queueDecision(confirm) marks candidate and enqueues sync task',
        () async {
      final now = clock.now.toUtc();
      await _insertCandidate(
        candidateDao,
        id: 'candidate-1',
        tripId: 'trip-1',
        createdAt: now,
      );

      await repository.queueDecision(
        tripId: 'trip-1',
        candidateId: 'candidate-1',
        action: LiveTrackingCandidateDecisionAction.confirm,
      );

      final updated = await candidateDao.getCandidateById('candidate-1');
      expect(updated, isNotNull);
      expect(updated!.actionState, 'queued');
      expect(updated.actionType, 'confirm');
      expect(updated.actionClientEventId, isNotNull);
      expect(updated.syncStatus, 'pending');

      final task = await syncTaskDao.getTaskByEntity(
        entityType: SyncEntityTypes.checkinDecision,
        entityId: 'candidate-1',
      );
      expect(task, isNotNull);
      expect(task!.operation, 'confirm');
      expect(task.status, 'queued');
    });

    test('queueDecision(snooze) stores local snooze metadata', () async {
      final now = clock.now.toUtc();
      await _insertCandidate(
        candidateDao,
        id: 'candidate-2',
        tripId: 'trip-1',
        createdAt: now,
      );

      await repository.queueDecision(
        tripId: 'trip-1',
        candidateId: 'candidate-2',
        action: LiveTrackingCandidateDecisionAction.snooze,
      );

      final updated = await candidateDao.getCandidateById('candidate-2');
      expect(updated, isNotNull);
      expect(updated!.status, 'snoozed');
      expect(updated.snoozedUntil, isNotNull);
      expect(updated.actionType, 'snooze');
    });

    test(
        'watchInboxCandidates re-emits when snoozed candidate becomes due without db writes',
        () async {
      final now = DateTime.now().toUtc();
      final realTimeRepository = LiveTrackingCandidateRepository(
        trackingCandidateDao: candidateDao,
        syncTaskDao: syncTaskDao,
      );
      await _insertCandidate(
        candidateDao,
        id: 'snoozed-delayed',
        tripId: 'trip-1',
        createdAt: now,
        status: 'snoozed',
        snoozedUntil: now.add(const Duration(seconds: 1)),
      );

      final emissions = <List<TrackingCandidateRow>>[];
      final sub = realTimeRepository
          .watchInboxCandidates('trip-1')
          .listen(emissions.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(
        emissions.isNotEmpty ? emissions.last : const <TrackingCandidateRow>[],
        isEmpty,
      );

      await Future<void>.delayed(const Duration(milliseconds: 1200));
      expect(emissions, isNotEmpty);
      expect(emissions.last.map((row) => row.id), contains('snoozed-delayed'));
    });
  });
}

Future<void> _insertCandidate(
  TrackingCandidateDao dao, {
  required String id,
  required String tripId,
  required DateTime createdAt,
  String status = 'pending',
  String actionState = 'none',
  DateTime? snoozedUntil,
}) async {
  await dao.upsertCandidate(
    TrackingCandidatesCompanion.insert(
      id: id,
      tripId: tripId,
      fingerprint: 'fp-$id',
      status: Value(status),
      actionState: Value(actionState),
      snoozedUntil: Value(snoozedUntil),
      localUpdatedAt: createdAt,
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
  );
}
