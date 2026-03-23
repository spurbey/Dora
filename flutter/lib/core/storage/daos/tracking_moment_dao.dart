import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/tracking_moments_table.dart';

part 'tracking_moment_dao.g.dart';

@DriftAccessor(tables: [TrackingMoments])
class TrackingMomentDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingMomentDaoMixin {
  TrackingMomentDao(super.db);

  Future<TrackingMomentRow?> getMomentById(String id) =>
      (select(trackingMoments)..where((m) => m.id.equals(id)))
          .getSingleOrNull();

  Future<List<TrackingMomentRow>> getMomentsForTrip(String tripId) =>
      (select(trackingMoments)
            ..where((m) => m.tripId.equals(tripId))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<TrackingMomentRow>> watchMomentsForTrip(String tripId) =>
      (select(trackingMoments)
            ..where((m) => m.tripId.equals(tripId))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<int> upsertMoment(TrackingMomentsCompanion row) =>
      into(trackingMoments).insertOnConflictUpdate(row);

  Future<int> markPendingWrite({
    required String momentId,
    required String operation,
    required String clientEventId,
  }) {
    final now = DateTime.now();
    return (update(trackingMoments)..where((m) => m.id.equals(momentId))).write(
      TrackingMomentsCompanion(
        pendingOperation: Value(operation),
        clientEventId: Value(clientEventId),
        syncStatus: const Value('pending'),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markSynced({
    required String momentId,
    DateTime? serverUpdatedAt,
  }) {
    final now = DateTime.now();
    return (update(trackingMoments)..where((m) => m.id.equals(momentId))).write(
      TrackingMomentsCompanion(
        pendingOperation: const Value(null),
        syncStatus: const Value('synced'),
        localUpdatedAt: Value(now),
        serverUpdatedAt: Value(serverUpdatedAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }
}
