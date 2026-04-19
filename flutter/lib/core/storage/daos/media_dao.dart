import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/media_table.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [Media])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(AppDatabase db) : super(db);

  Future<MediaItem?> getMediaById(String id) =>
      (select(media)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<int> insertMedia(MediaCompanion item) => into(media).insert(item);

  Future<bool> updateMedia(MediaCompanion item) => update(media).replace(item);

  Future<int> deleteMedia(String id) =>
      (delete(media)..where((m) => m.id.equals(id))).go();

  Future<int> softDelete(String id, {DateTime? deletedAt}) {
    final when = (deletedAt ?? DateTime.now()).toUtc();
    return (update(media)..where((m) => m.id.equals(id))).write(
      MediaCompanion(
        deletedAt: Value(when),
        localUpdatedAt: Value(when),
        updatedAt: Value(when),
      ),
    );
  }

  Future<List<MediaItem>> listForOwner(
    String ownerUserId, {
    int? limit,
    int? offset,
  }) {
    final query = select(media)
      ..where(
        (m) => m.ownerUserId.equals(ownerUserId) & m.deletedAt.isNull(),
      )
      ..orderBy([
        (m) => OrderingTerm(expression: m.capturedAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  Stream<List<MediaItem>> watchForOwner(String ownerUserId) {
    return (select(media)
          ..where(
            (m) => m.ownerUserId.equals(ownerUserId) & m.deletedAt.isNull(),
          )
          ..orderBy([
            (m) =>
                OrderingTerm(expression: m.capturedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<List<MediaItem>> listByIds(Iterable<String> ids) {
    final idList = ids.toList();
    if (idList.isEmpty) {
      return Future.value(const <MediaItem>[]);
    }
    return (select(media)
          ..where((m) => m.id.isIn(idList) & m.deletedAt.isNull())
          ..orderBy([
            (m) =>
                OrderingTerm(expression: m.capturedAt, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Future<List<MediaItem>> listForOriginScope(
    String originScope, {
    int? limit,
  }) {
    final query = select(media)
      ..where(
        (m) => m.originScope.equals(originScope) & m.deletedAt.isNull(),
      )
      ..orderBy([
        (m) => OrderingTerm(expression: m.capturedAt, mode: OrderingMode.desc),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<MediaItem>> getPendingUploads({
    DateTime? now,
    int limit = 20,
  }) {
    final currentTime = now ?? DateTime.now();
    return (select(media)
          ..where((m) =>
              m.workerSessionId.isNull() &
              m.deletedAt.isNull() &
              (m.uploadState.equals('queued') |
                  ((m.uploadState.equals('failed') |
                          m.uploadState.equals('deferred')) &
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
            upload_state = 'compressing',
            local_updated_at = ?,
            updated_at = ?
          WHERE id = ?
            AND worker_session_id IS NULL
            AND upload_state IN ('queued', 'failed', 'deferred')
          ''',
          variables: [
            Variable<String>(workerSessionId),
            Variable<DateTime>(claimTime),
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

  Future<int> enqueueForUpload(String mediaId, {DateTime? now}) {
    final when = (now ?? DateTime.now()).toUtc();
    return (update(media)
          ..where(
            (m) => m.id.equals(mediaId) & m.uploadState.equals('local_only'),
          ))
        .write(
      MediaCompanion(
        uploadState: const Value('queued'),
        uploadProgress: const Value(0.0),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        workerSessionId: const Value(null),
        retryCount: const Value(0),
        localUpdatedAt: Value(when),
        updatedAt: Value(when),
      ),
    );
  }

  Future<int> enqueueManyForUpload(
    Iterable<String> mediaIds, {
    DateTime? now,
  }) async {
    final ids = mediaIds.toList();
    if (ids.isEmpty) {
      return 0;
    }
    final when = (now ?? DateTime.now()).toUtc();
    return (update(media)
          ..where(
            (m) =>
                m.id.isIn(ids) &
                m.uploadState.equals('local_only') &
                m.deletedAt.isNull(),
          ))
        .write(
      MediaCompanion(
        uploadState: const Value('queued'),
        uploadProgress: const Value(0.0),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        workerSessionId: const Value(null),
        retryCount: const Value(0),
        localUpdatedAt: Value(when),
        updatedAt: Value(when),
      ),
    );
  }

  Future<int> updateUploadState({
    required String mediaId,
    required String uploadState,
    double? uploadProgress,
    int? retryCount,
    String? errorMessage,
    DateTime? nextAttemptAt,
    DateTime? uploadedAt,
    String? workerSessionId,
  }) {
    final now = DateTime.now().toUtc();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        uploadState: Value(uploadState),
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
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> updateUploadProgressIfActive({
    required String mediaId,
    required String workerSessionId,
    required double uploadProgress,
  }) {
    final now = DateTime.now().toUtc();
    return customUpdate(
      '''
      UPDATE media
      SET
        upload_progress = ?,
        local_updated_at = ?,
        updated_at = ?
      WHERE id = ?
        AND worker_session_id = ?
        AND upload_state = 'uploading'
      ''',
      variables: [
        Variable<double>(uploadProgress),
        Variable<DateTime>(now),
        Variable<DateTime>(now),
        Variable<String>(mediaId),
        Variable<String>(workerSessionId),
      ],
      updates: {media},
    );
  }

  Future<int> updateLocalArtifacts({
    required String mediaId,
    String? localUri,
    String? thumbnailLocalPath,
    String? mimeType,
    int? bytesSize,
    int? widthPx,
    int? heightPx,
    int? durationMs,
    String? contentHash,
  }) {
    final now = DateTime.now().toUtc();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        localUri: localUri == null ? const Value.absent() : Value(localUri),
        thumbnailLocalPath: thumbnailLocalPath == null
            ? const Value.absent()
            : Value(thumbnailLocalPath),
        mimeType: mimeType == null ? const Value.absent() : Value(mimeType),
        bytesSize: bytesSize == null ? const Value.absent() : Value(bytesSize),
        widthPx: widthPx == null ? const Value.absent() : Value(widthPx),
        heightPx: heightPx == null ? const Value.absent() : Value(heightPx),
        durationMs:
            durationMs == null ? const Value.absent() : Value(durationMs),
        contentHash:
            contentHash == null ? const Value.absent() : Value(contentHash),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markUploaded({
    required String mediaId,
    required String remoteUrl,
    String? remoteThumbnailUrl,
    String? serverId,
    String? mimeType,
    int? bytesSize,
    int? widthPx,
    int? heightPx,
    DateTime? uploadedAt,
  }) {
    final now = DateTime.now().toUtc();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        remoteUrl: Value(remoteUrl),
        remoteThumbnailUrl: remoteThumbnailUrl == null
            ? const Value.absent()
            : Value(remoteThumbnailUrl),
        serverId: serverId == null ? const Value.absent() : Value(serverId),
        mimeType: mimeType == null ? const Value.absent() : Value(mimeType),
        bytesSize: bytesSize == null ? const Value.absent() : Value(bytesSize),
        widthPx: widthPx == null ? const Value.absent() : Value(widthPx),
        heightPx: heightPx == null ? const Value.absent() : Value(heightPx),
        uploadState: const Value('uploaded'),
        uploadProgress: const Value(1.0),
        retryCount: const Value(0),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        uploadedAt: Value(uploadedAt ?? now),
        workerSessionId: const Value(null),
        syncStatus: const Value('synced'),
        localUpdatedAt: Value(now),
        serverUpdatedAt: Value(now),
        updatedAt: Value(now),
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
    return transaction(() async {
      final rows = await customUpdate(
        'UPDATE media SET id = ? WHERE id = ?',
        variables: [
          Variable<String>(newMediaId),
          Variable<String>(oldMediaId),
        ],
        updates: {media},
      );
      if (rows > 0) {
        await customUpdate(
          'UPDATE media_attachments SET media_id = ? WHERE media_id = ?',
          variables: [
            Variable<String>(newMediaId),
            Variable<String>(oldMediaId),
          ],
          updates: {attachedDatabase.mediaAttachments},
        );
        await customUpdate(
          'UPDATE stories SET media_id = ? WHERE media_id = ?',
          variables: [
            Variable<String>(newMediaId),
            Variable<String>(oldMediaId),
          ],
          updates: {attachedDatabase.stories},
        );
      }
      return rows;
    });
  }

  Future<int> markFailed({
    required String mediaId,
    required String errorMessage,
    required int retryCount,
    DateTime? nextAttemptAt,
  }) {
    final now = DateTime.now().toUtc();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        uploadState: const Value('failed'),
        uploadProgress: const Value(0.0),
        retryCount: Value(retryCount),
        errorMessage: Value(errorMessage),
        nextAttemptAt: Value(nextAttemptAt),
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markDeferred({
    required String mediaId,
    required String message,
    required DateTime nextAttemptAt,
  }) {
    final now = DateTime.now().toUtc();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        uploadState: const Value('deferred'),
        uploadProgress: const Value(0.0),
        errorMessage: Value(message),
        nextAttemptAt: Value(nextAttemptAt),
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> markBlocked({
    required String mediaId,
    required String message,
  }) {
    final now = DateTime.now().toUtc();
    return (update(media)..where((m) => m.id.equals(mediaId))).write(
      MediaCompanion(
        uploadState: const Value('blocked'),
        uploadProgress: const Value(0.0),
        errorMessage: Value(message),
        nextAttemptAt: const Value(null),
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> clearWorkerSession({
    required String mediaId,
    String? expectedSessionId,
  }) async {
    final now = DateTime.now().toUtc();
    if (expectedSessionId == null) {
      return (update(media)..where((m) => m.id.equals(mediaId))).write(
        MediaCompanion(
          workerSessionId: const Value(null),
          localUpdatedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    return (update(media)
          ..where((m) =>
              m.id.equals(mediaId) &
              m.workerSessionId.equals(expectedSessionId)))
        .write(
      MediaCompanion(
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
