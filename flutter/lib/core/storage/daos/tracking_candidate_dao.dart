import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/tracking_candidates_table.dart';

part 'tracking_candidate_dao.g.dart';

@DriftAccessor(tables: [TrackingCandidates])
class TrackingCandidateDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingCandidateDaoMixin {
  TrackingCandidateDao(super.db);

  Future<TrackingCandidateRow?> getCandidateById(String id) =>
      (select(trackingCandidates)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  Future<List<TrackingCandidateRow>> getCandidatesForTrip(String tripId) =>
      (select(trackingCandidates)
            ..where((c) => c.tripId.equals(tripId))
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<TrackingCandidateRow>> watchCandidatesForTrip(String tripId) =>
      (select(trackingCandidates)
            ..where((c) => c.tripId.equals(tripId))
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<List<TrackingCandidateRow>> getInboxCandidatesForTrip(
    String tripId, {
    int limit = 200,
  }) =>
      (select(trackingCandidates)
            ..where((c) =>
                c.tripId.equals(tripId) &
                (c.status.equals('pending') |
                    c.status.equals('snoozed') |
                    c.actionState.equals('queued') |
                    c.actionState.equals('failed')))
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .get();

  Stream<List<TrackingCandidateRow>> watchInboxCandidatesForTrip(
    String tripId, {
    int limit = 200,
  }) =>
      (select(trackingCandidates)
            ..where((c) =>
                c.tripId.equals(tripId) &
                (c.status.equals('pending') |
                    c.status.equals('snoozed') |
                    c.actionState.equals('queued') |
                    c.actionState.equals('failed')))
            ..orderBy([
              (c) => OrderingTerm(
                    expression: c.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .watch();

  Future<int> upsertCandidate(TrackingCandidatesCompanion row) =>
      into(trackingCandidates).insertOnConflictUpdate(row);

  Future<int> markDecisionQueued({
    required String candidateId,
    required String actionType,
    required String clientEventId,
    required DateTime queuedAt,
    String? status,
    String? rejectedReason,
    DateTime? snoozedUntil,
  }) {
    return (update(trackingCandidates)..where((c) => c.id.equals(candidateId)))
        .write(
      TrackingCandidatesCompanion(
        status: status == null ? const Value.absent() : Value(status),
        rejectedReason: rejectedReason == null
            ? const Value.absent()
            : Value(rejectedReason),
        snoozedUntil:
            snoozedUntil == null ? const Value.absent() : Value(snoozedUntil),
        actionState: const Value('queued'),
        actionType: Value(actionType),
        actionClientEventId: Value(clientEventId),
        actionQueuedAt: Value(queuedAt),
        actionSyncedAt: const Value(null),
        syncStatus: const Value('pending'),
        localUpdatedAt: Value(queuedAt),
        updatedAt: Value(queuedAt),
      ),
    );
  }

  Future<int> markDecisionSynced({
    required String candidateId,
    required String status,
    DateTime? syncedAt,
  }) {
    final now = syncedAt ?? DateTime.now();
    return (update(trackingCandidates)..where((c) => c.id.equals(candidateId)))
        .write(
      TrackingCandidatesCompanion(
        status: Value(status),
        actionState: const Value('synced'),
        actionSyncedAt: Value(now),
        syncStatus: const Value('synced'),
        localUpdatedAt: Value(now),
        serverUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markDecisionFailed({
    required String candidateId,
    required DateTime failedAt,
  }) {
    final now = failedAt.toUtc();
    return (update(trackingCandidates)..where((c) => c.id.equals(candidateId)))
        .write(
      TrackingCandidatesCompanion(
        actionState: const Value('failed'),
        actionSyncedAt: const Value(null),
        syncStatus: const Value('pending'),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
