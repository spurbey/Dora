import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/tracking_events_table.dart';

part 'tracking_event_dao.g.dart';

@DriftAccessor(tables: [TrackingEvents])
class TrackingEventDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingEventDaoMixin {
  TrackingEventDao(super.db);

  Future<TrackingEventRow?> getEventById(String id) =>
      (select(trackingEvents)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<List<TrackingEventRow>> getEventsForTrip(String tripId) =>
      (select(trackingEvents)
            ..where((e) => e.tripId.equals(tripId))
            ..orderBy([
              (e) => OrderingTerm(
                    expression: e.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<TrackingEventRow>> watchEventsForTrip(String tripId) =>
      (select(trackingEvents)
            ..where((e) => e.tripId.equals(tripId))
            ..orderBy([
              (e) => OrderingTerm(
                    expression: e.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<int> upsertEvent(TrackingEventsCompanion row) =>
      into(trackingEvents).insertOnConflictUpdate(row);

  Future<int> markPending({
    required String eventId,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEvents)..where((e) => e.id.equals(eventId))).write(
      TrackingEventsCompanion(
        syncStatus: const Value('pending'),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markSynced({
    required String eventId,
    DateTime? serverUpdatedAt,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEvents)..where((e) => e.id.equals(eventId))).write(
      TrackingEventsCompanion(
        syncStatus: const Value('synced'),
        serverUpdatedAt: Value(serverUpdatedAt ?? now),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markBlocked({
    required String eventId,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEvents)..where((e) => e.id.equals(eventId))).write(
      TrackingEventsCompanion(
        syncStatus: const Value('blocked'),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
