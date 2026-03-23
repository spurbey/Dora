import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/tracking_sessions_table.dart';

part 'tracking_session_dao.g.dart';

@DriftAccessor(tables: [TrackingSessions])
class TrackingSessionDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingSessionDaoMixin {
  TrackingSessionDao(super.db);

  Future<TrackingSessionRow?> getSessionById(String id) =>
      (select(trackingSessions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<TrackingSessionRow>> getSessionsForTrip(String tripId) =>
      (select(trackingSessions)
            ..where((t) => t.tripId.equals(tripId))
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<TrackingSessionRow?> watchActiveOrPausedSessionForTrip(
          String tripId) =>
      (select(trackingSessions)
            ..where(
              (t) =>
                  t.tripId.equals(tripId) &
                  t.state.isIn(const ['active', 'paused']),
            )
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.localUpdatedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .watchSingleOrNull();

  Future<TrackingSessionRow?> getActiveOrPausedSessionForTrip(String tripId) =>
      (select(trackingSessions)
            ..where(
              (t) =>
                  t.tripId.equals(tripId) &
                  t.state.isIn(const ['active', 'paused']),
            )
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.localUpdatedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<int> upsertSession(TrackingSessionsCompanion row) =>
      into(trackingSessions).insertOnConflictUpdate(row);

  Future<int> updateLifecycle({
    required String sessionId,
    required String state,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? resumedAt,
    DateTime? endedAt,
    DateTime? abandonedAt,
    DateTime? lastPointAt,
    DateTime? lastFlushAt,
  }) {
    final now = DateTime.now();
    return (update(trackingSessions)..where((t) => t.id.equals(sessionId)))
        .write(
      TrackingSessionsCompanion(
        state: Value(state),
        syncStatus: const Value('pending'),
        startedAt: startedAt == null ? const Value.absent() : Value(startedAt),
        pausedAt: pausedAt == null ? const Value.absent() : Value(pausedAt),
        resumedAt: resumedAt == null ? const Value.absent() : Value(resumedAt),
        endedAt: endedAt == null ? const Value.absent() : Value(endedAt),
        abandonedAt:
            abandonedAt == null ? const Value.absent() : Value(abandonedAt),
        lastPointAt:
            lastPointAt == null ? const Value.absent() : Value(lastPointAt),
        lastFlushAt:
            lastFlushAt == null ? const Value.absent() : Value(lastFlushAt),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
