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

  Future<List<TrackingEventMediaRow>> getMediaForTrip(String tripId) =>
      (select(trackingEventMedia)
            ..where((m) => m.tripId.equals(tripId))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<TrackingEventMediaRow>> watchMediaForTrip(String tripId) =>
      (select(trackingEventMedia)
            ..where((m) => m.tripId.equals(tripId))
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<List<TrackingEventMediaRow>> getSyncedRouteMediaForEvent(
    String eventId,
  ) =>
      (select(trackingEventMedia)
            ..where(
              (m) =>
                  m.eventId.equals(eventId) &
                  m.bindMode.equals('route') &
                  m.syncStatus.equals('synced'),
            )
            ..orderBy([
              (m) => OrderingTerm(
                    expression: m.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<int> upsertMedia(TrackingEventMediaCompanion row) =>
      into(trackingEventMedia).insertOnConflictUpdate(row);

  Future<int> markPendingUpload({
    required String mediaId,
    required String bindState,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)..where((m) => m.id.equals(mediaId)))
        .write(
      TrackingEventMediaCompanion(
        bindState: Value(bindState),
        uploadStatus: Value(bindState),
        syncStatus: const Value('pending'),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> promotePendingMediaToPlace({
    required String eventId,
    required String tripPlaceId,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)
          ..where(
            (m) =>
                m.eventId.equals(eventId) &
                m.bindMode.equals('route') &
                m.syncStatus.isIn(const ['pending', 'failed']),
          ))
        .write(
      TrackingEventMediaCompanion(
        bindMode: const Value('place'),
        bindState: const Value('queued_place_upload'),
        tripPlaceId: Value(tripPlaceId),
        uploadStatus: const Value('queued_place_upload'),
        syncStatus: const Value('pending'),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> forcePendingMediaOnRoute({
    required String eventId,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)
          ..where(
            (m) =>
                m.eventId.equals(eventId) &
                m.syncStatus.isIn(const ['pending', 'failed']),
          ))
        .write(
      TrackingEventMediaCompanion(
        bindMode: const Value('route'),
        bindState: const Value('queued_route_upload'),
        tripPlaceId: const Value(null),
        uploadStatus: const Value('queued_route_upload'),
        syncStatus: const Value('pending'),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markUploadRef({
    required String mediaId,
    required String uploadRef,
    String? mimeType,
    int? fileSizeBytes,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)..where((m) => m.id.equals(mediaId)))
        .write(
      TrackingEventMediaCompanion(
        uploadRef: Value(uploadRef),
        mimeType: Value(mimeType),
        fileSizeBytes: Value(fileSizeBytes),
        uploadStatus: const Value('uploading'),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markRetryableFailure({
    required String mediaId,
    required String message,
    required int retryCount,
    DateTime? nextAttemptAt,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)..where((m) => m.id.equals(mediaId)))
        .write(
      TrackingEventMediaCompanion(
        bindState: const Value('failed_retryable'),
        uploadStatus: const Value('failed_retryable'),
        syncStatus: const Value('failed'),
        retryCount: Value(retryCount),
        errorMessage: Value(message),
        nextAttemptAt: Value(nextAttemptAt),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markBlockedValidation({
    required String mediaId,
    required String message,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)..where((m) => m.id.equals(mediaId)))
        .write(
      TrackingEventMediaCompanion(
        bindState: const Value('blocked_validation'),
        uploadStatus: const Value('blocked_validation'),
        syncStatus: const Value('blocked'),
        errorMessage: Value(message),
        nextAttemptAt: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markSynced({
    required String mediaId,
    required String remoteMediaId,
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.now().toUtc();
    return (update(trackingEventMedia)..where((m) => m.id.equals(mediaId)))
        .write(
      TrackingEventMediaCompanion(
        remoteMediaId: Value(remoteMediaId),
        bindState: const Value('linked_to_event'),
        uploadStatus: const Value('linked_to_event'),
        syncStatus: const Value('synced'),
        retryCount: const Value(0),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
