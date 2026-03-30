import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/tracking_event_media_table.dart';

part 'tracking_event_media_dao.g.dart';

@DriftAccessor(tables: [TrackingEventMedia])
class TrackingEventMediaDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingEventMediaDaoMixin {
  TrackingEventMediaDao(super.db);

  Future<TrackingEventMediaRow?> getMediaById(String id) =>
      (select(trackingEventMedia)..where((m) => m.id.equals(id)))
          .getSingleOrNull();

  Future<List<TrackingEventMediaRow>> getMediaForEvent(String eventId) =>
      (select(trackingEventMedia)
            ..where((m) => m.eventId.equals(eventId))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Stream<List<TrackingEventMediaRow>> watchMediaForEvent(String eventId) =>
      (select(trackingEventMedia)
            ..where((m) => m.eventId.equals(eventId))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .watch();

  Future<int> upsertMedia(TrackingEventMediaCompanion row) =>
      into(trackingEventMedia).insertOnConflictUpdate(row);
}
