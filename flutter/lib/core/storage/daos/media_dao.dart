import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/media_table.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(AppDatabase db) : super(db);

  Future<MediaItem?> getMediaById(String id) =>
      (select(media)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<List<MediaItem>> getMediaForTrip(String tripId) => (select(media)
        ..where((m) => m.tripId.equals(tripId))
        ..orderBy([
          (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        ]))
      .get();

  Future<List<MediaItem>> getMediaForPlace(String placeId) => (select(media)
        ..where((m) => m.placeId.equals(placeId))
        ..orderBy([
          (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        ]))
      .get();

  Stream<List<MediaItem>> watchMediaForPlace(String placeId) => (select(media)
        ..where((m) => m.placeId.equals(placeId))
        ..orderBy([
          (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();

  Stream<int> watchPendingCountForPlace(String placeId) {
    final countExpression = media.id.count();
    final query = selectOnly(media)
      ..addColumns([countExpression])
      ..where(
        media.placeId.equals(placeId) &
            media.uploadStatus
                .isIn(const ['queued', 'compressing', 'uploading']),
      );
    return query.watchSingle().map(
          (row) => row.read(countExpression) ?? 0,
        );
  }

  Future<List<MediaItem>> getFailedUploadsForPlace(String placeId) => (select(
          media)
        ..where(
            (m) => m.placeId.equals(placeId) & m.uploadStatus.equals('failed'))
        ..orderBy([
          (m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc),
        ]))
      .get();

  Future<List<MediaItem>> getPendingUploads({
    DateTime? now,
    int limit = 20,
  }) {
    final currentTime = now ?? DateTime.now();
    return (select(media)
          ..where((m) =>
              m.workerSessionId.isNull() &
              (m.uploadStatus.equals('queued') |
                  (m.uploadStatus.equals('failed') &
                      m.nextAttemptAt.isNotNull() &
                      m.nextAttemptAt.isSmallerOrEqualValue(currentTime))))
          ..orderBy([
            (m) =>
                OrderingTerm(expression: m.createdAt, mode: OrderingMode.asc),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<MediaItem>> claimPendingUploads({
    required String workerSessionId,
    DateTime? now,
    int limit = 2,
  }) async {
    final claimTime = now ?? DateTime.now();
    return transaction(() async {
      final candidates = await getPendingUploads(now: claimTime, limit: limit);
      if (candidates.isEmpty) {
        return const <MediaItem>[];
      }

      final claimedIds = <String>[];
      for (final item in candidates) {
        final affected = await customUpdate(
          '''
          UPDATE media
          SET
            worker_session_id = ?,
            upload_status = 'compressing',
            local_updated_at = ?
          WHERE id = ?
            AND worker_session_id IS NULL
            AND upload_status IN ('queued', 'failed')
          ''',
          variables: [
            Variable<String>(workerSessionId),
            Variable<DateTime>(claimTime),
            Variable<String>(item.id),
          ],
          updates: {media},
        );

        if (affected == 1) {
          claimedIds.add(item.id);
        }
      }

      if (claimedIds.isEmpty) {
        return const <MediaItem>[];
      }

      return (select(media)
            ..where((m) => m.id.isIn(claimedIds))
            ..orderBy([
              (m) =>
                  OrderingTerm(expression: m.createdAt, mode: OrderingMode.asc),
            ]))
          .get();
    });
  }

  Future<int> updateUploadState({
    required String mediaId,
    required String uploadStatus,
    double? uploadProgress,
    int? retryCount,
    String? errorMessage,
    DateTime? nextAttemptAt,
    DateTime? uploadedAt,
    String? workerSessionId,
  }) {
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        uploadStatus: Value(uploadStatus),
        uploadProgress: uploadProgress == null
            ? const Value.absent()
            : Value(uploadProgress),
        retryCount:
            retryCount == null ? const Value.absent() : Value(retryCount),
        errorMessage: Value(errorMessage),
        nextAttemptAt:
            nextAttemptAt == null ? const Value.absent() : Value(nextAttemptAt),
        uploadedAt:
            uploadedAt == null ? const Value.absent() : Value(uploadedAt),
        workerSessionId: Value(workerSessionId),
      ),
    );
  }

  Future<int> updateUploadProgressIfActive({
    required String mediaId,
    required String workerSessionId,
    required double uploadProgress,
  }) {
    return customUpdate(
      '''
      UPDATE media
      SET
        upload_progress = ?,
        local_updated_at = ?
      WHERE id = ?
        AND worker_session_id = ?
        AND upload_status = 'uploading'
      ''',
      variables: [
        Variable<double>(uploadProgress),
        Variable<DateTime>(DateTime.now()),
        Variable<String>(mediaId),
        Variable<String>(workerSessionId),
      ],
      updates: {media},
    );
  }

  Future<int> updateLocalArtifacts({
    required String mediaId,
    String? localPath,
    String? thumbnailPath,
    String? mimeType,
    int? fileSizeBytes,
    int? width,
    int? height,
  }) {
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        localPath: Value(localPath),
        thumbnailPath: Value(thumbnailPath),
        mimeType: Value(mimeType),
        fileSizeBytes: fileSizeBytes == null
            ? const Value.absent()
            : Value(fileSizeBytes),
        width: width == null ? const Value.absent() : Value(width),
        height: height == null ? const Value.absent() : Value(height),
      ),
    );
  }

  Future<int> markUploaded({
    required String mediaId,
    required String url,
    String? thumbnailPath,
    String? mimeType,
    int? fileSizeBytes,
    int? width,
    int? height,
    DateTime? uploadedAt,
  }) {
    final now = DateTime.now();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        url: Value(url),
        thumbnailPath: Value(thumbnailPath),
        mimeType: Value(mimeType),
        fileSizeBytes: fileSizeBytes == null
            ? const Value.absent()
            : Value(fileSizeBytes),
        width: width == null ? const Value.absent() : Value(width),
        height: height == null ? const Value.absent() : Value(height),
        uploadStatus: const Value('uploaded'),
        uploadProgress: const Value(1.0),
        retryCount: const Value(0),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        uploadedAt: Value(uploadedAt ?? now),
        workerSessionId: const Value(null),
        syncStatus: const Value('synced'),
        localUpdatedAt: Value(now),
        serverUpdatedAt: Value(now),
      ),
    );
  }

  Future<int> replaceMediaId({
    required String oldMediaId,
    required String newMediaId,
  }) async {
    if (oldMediaId == newMediaId) {
      return 0;
    }
    return customUpdate(
      'UPDATE media SET id = ? WHERE id = ?',
      variables: [
        Variable<String>(newMediaId),
        Variable<String>(oldMediaId),
      ],
      updates: {media},
    );
  }

  Future<int> markFailed({
    required String mediaId,
    required String errorMessage,
    required int retryCount,
    DateTime? nextAttemptAt,
  }) {
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        uploadStatus: const Value('failed'),
        uploadProgress: const Value(0.0),
        retryCount: Value(retryCount),
        errorMessage: Value(errorMessage),
        nextAttemptAt: Value(nextAttemptAt),
        workerSessionId: const Value(null),
      ),
    );
  }

  Future<int> clearWorkerSession({
    required String mediaId,
    String? expectedSessionId,
  }) async {
    if (expectedSessionId == null) {
      return (update(media)..where((m) => m.id.equals(mediaId))).write(
        const MediaCompanion(workerSessionId: Value(null)),
      );
    }

    return (update(media)
          ..where((m) =>
              m.id.equals(mediaId) &
              m.workerSessionId.equals(expectedSessionId)))
        .write(const MediaCompanion(workerSessionId: Value(null)));
  }

  Future<int> insertMedia(MediaCompanion item) => into(media).insert(item);

  Future<bool> updateMedia(MediaCompanion item) => update(media).replace(item);

  Future<int> deleteMedia(String id) =>
      (delete(media)..where((m) => m.id.equals(id))).go();
}
