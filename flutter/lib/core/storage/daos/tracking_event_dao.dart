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

  Future<List<TrackingEventRow>> getUnresolvedEventsForTrip(
    String tripId, {
    int limit = 20,
  }) =>
      (select(trackingEvents)
            ..where(
              (e) =>
                  e.tripId.equals(tripId) &
                  (e.resolverState.equals('review_required') |
                      e.resolverState.equals('on_route_unresolved')),
            )
            ..orderBy([
              (e) => OrderingTerm(
                    expression: e.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .get();

  Future<List<TrackingEventRow>> getRecentResolvedAnchors(
    String tripId, {
    int limit = 40,
  }) =>
      (select(trackingEvents)
            ..where(
              (e) =>
                  e.tripId.equals(tripId) &
                  e.resolverState.equals('resolved') &
                  e.resolvedPlaceId.isNotNull() &
                  e.latitude.isNotNull() &
                  e.longitude.isNotNull(),
            )
            ..orderBy([
              (e) => OrderingTerm(
                    expression: e.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .get();

  Stream<int> watchUnresolvedCountForTrip(String tripId) {
    final countExpression = trackingEvents.id.count();
    final query = selectOnly(trackingEvents)
      ..addColumns([countExpression])
      ..where(
        trackingEvents.tripId.equals(tripId) &
            (trackingEvents.resolverState.equals('review_required') |
                trackingEvents.resolverState.equals('on_route_unresolved')),
      );
    return query.watchSingle().map(
          (row) => row.read(countExpression) ?? 0,
        );
  }

  Future<int> updateResolverDecision({
    required String eventId,
    String? resolvedPlaceId,
    double? bindConfidence,
    String? resolverReasonCode,
    required String resolverState,
    int resolverVersion = 1,
    String? resolutionHintJson,
    DateTime? resolvedAt,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEvents)..where((e) => e.id.equals(eventId))).write(
      TrackingEventsCompanion(
        resolvedPlaceId: Value(resolvedPlaceId),
        bindConfidence: Value(bindConfidence),
        resolverReasonCode: Value(resolverReasonCode),
        resolverState: Value(resolverState),
        resolverVersion: Value(resolverVersion),
        resolvedAt: Value(resolvedAt ?? now),
        resolutionHintJson: Value(resolutionHintJson),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

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
