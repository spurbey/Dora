import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/media/app_media_uploader.dart';
import 'package:dora/core/media/upload_queue_worker.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/place_repository.dart';

class MediaRepository {
  MediaRepository(
    this._db, {
    required UploadQueueWorker queueWorker,
    required PlaceRepository placeRepository,
    required AppMediaUploader mediaUploader,
    Future<Directory> Function()? supportDirectoryProvider,
    String Function()? resolveOwnerUserId,
  })  : _queueWorker = queueWorker,
        _placeRepository = placeRepository,
        _mediaUploader = mediaUploader,
        _supportDirectoryProvider =
            supportDirectoryProvider ?? getApplicationSupportDirectory,
        _resolveOwnerUserId = resolveOwnerUserId ?? _defaultOwnerUserId;

  final AppDatabase _db;
  final UploadQueueWorker _queueWorker;
  final PlaceRepository _placeRepository;
  final AppMediaUploader _mediaUploader;
  final Future<Directory> Function() _supportDirectoryProvider;
  final String Function() _resolveOwnerUserId;

  static String _defaultOwnerUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id ?? 'unknown';
  }

  Stream<List<MediaItem>> watchPlaceMedia(String placeLocalId) {
    final query = _db.customSelect(
      '''
      SELECT m.* FROM media m
      INNER JOIN media_attachments ma ON m.id = ma.media_id
      WHERE ma.target_kind = 'place'
        AND ma.target_local_id = ?
        AND ma.role = 'review'
        AND ma.detached_at IS NULL
        AND m.deleted_at IS NULL
      ORDER BY m.captured_at DESC
      ''',
      variables: [Variable<String>(placeLocalId)],
      readsFrom: {_db.media, _db.mediaAttachments},
    );
    return query.watch().map(
          (rows) => rows
              .map((row) => _db.media.map(row.data))
              .toList(growable: false),
        );
  }

  Stream<int> watchPendingCount(String placeLocalId) {
    final query = _db.customSelect(
      '''
      SELECT COUNT(1) AS pending FROM media m
      INNER JOIN media_attachments ma ON m.id = ma.media_id
      WHERE ma.target_kind = 'place'
        AND ma.target_local_id = ?
        AND ma.role = 'review'
        AND ma.detached_at IS NULL
        AND m.deleted_at IS NULL
        AND m.upload_state IN ('local_only', 'queued', 'deferred', 'compressing', 'uploading')
      ''',
      variables: [Variable<String>(placeLocalId)],
      readsFrom: {_db.media, _db.mediaAttachments},
    );
    return query.watchSingle().map((row) => row.read<int>('pending'));
  }

  Future<void> startQueue() => _queueWorker.startIfIdle();

  Future<List<String>> enqueueFilePaths({
    required String tripId,
    required String placeId,
    required List<String> filePaths,
  }) async {
    if (filePaths.isEmpty) {
      return const <String>[];
    }

    final ownerUserId = _resolveOwnerUserId();
    final insertedIds = <String>[];

    await _db.transaction(() async {
      for (final path in filePaths) {
        final id = const Uuid().v4();
        insertedIds.add(id);
        final now = DateTime.now().toUtc();
        final managedPath = await _copyToManagedUploadPath(
          sourcePath: path,
          mediaId: id,
        );

        final effectiveLocalUri = managedPath ?? path;
        final hasFile = managedPath != null;

        await _db.mediaDao.insertMedia(
          MediaCompanion.insert(
            id: id,
            ownerUserId: ownerUserId,
            originScope: 'editor',
            mediaType: const Value('photo'),
            localUri: Value(effectiveLocalUri),
            capturedAt: now,
            uploadState: Value(hasFile ? 'local_only' : 'failed'),
            uploadProgress: const Value(0.0),
            retryCount: const Value(0),
            errorMessage: hasFile
                ? const Value(null)
                : const Value(
                    'Selected file is no longer available on device storage',
                  ),
            nextAttemptAt: const Value(null),
            workerSessionId: const Value(null),
            syncStatus: const Value('pending'),
            localUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        await _db.mediaAttachmentsDao.insertAttachment(
          MediaAttachmentsCompanion.insert(
            id: const Uuid().v4(),
            mediaId: id,
            targetKind: 'place',
            targetLocalId: placeId,
            role: 'review',
            source: const Value('user'),
            attachedAt: now,
          ),
        );

        await _db.mediaAttachmentsDao.insertAttachment(
          MediaAttachmentsCompanion.insert(
            id: const Uuid().v4(),
            mediaId: id,
            targetKind: 'trip',
            targetLocalId: tripId,
            role: 'review',
            source: const Value('user'),
            attachedAt: now,
          ),
        );
      }
    });

    debugPrint('[MEDIA_QUEUE] added count=${insertedIds.length} '
        'origin=editor state=local_only');
    return insertedIds;
  }

  Future<int> enqueueMediaForTripPublish(String tripLocalId) async {
    final mediaIds = await _mediaIdsForTrip(tripLocalId);
    if (mediaIds.isEmpty) {
      return 0;
    }
    final queued =
        await _db.mediaDao.enqueueManyForUpload(mediaIds);
    if (queued > 0) {
      await _queueWorker.startIfIdle();
    }
    return queued;
  }

  Future<List<String>> _mediaIdsForTrip(String tripLocalId) async {
    final rows = await _db.customSelect(
      '''
      SELECT DISTINCT m.id AS id
      FROM media m
      INNER JOIN media_attachments ma ON m.id = ma.media_id
      WHERE ma.detached_at IS NULL
        AND m.deleted_at IS NULL
        AND m.upload_state = 'local_only'
        AND (
          (ma.target_kind = 'trip' AND ma.target_local_id = ?)
          OR (ma.target_kind = 'place' AND ma.target_local_id IN (
            SELECT id FROM places WHERE trip_id = ?
          ))
          OR (ma.target_kind = 'trip_event' AND ma.target_local_id IN (
            SELECT event_id FROM event_journal WHERE trip_local_id = ?
          ))
        )
      ''',
      variables: [
        Variable<String>(tripLocalId),
        Variable<String>(tripLocalId),
        Variable<String>(tripLocalId),
      ],
      readsFrom: {
        _db.media,
        _db.mediaAttachments,
        _db.places,
        _db.eventJournal,
      },
    ).get();
    return rows.map((r) => r.read<String>('id')).toList(growable: false);
  }

  Future<void> retryUpload(String mediaId) async {
    final existing = await _db.mediaDao.getMediaById(mediaId);
    if (existing == null) {
      return;
    }
    if (existing.uploadState == 'uploaded') {
      return;
    }
    await _db.mediaDao.updateUploadState(
      mediaId: mediaId,
      uploadState: 'queued',
      uploadProgress: 0.0,
      retryCount: 0,
      errorMessage: null,
      nextAttemptAt: null,
      workerSessionId: null,
    );
    await _queueWorker.startIfIdle();
  }

  Future<void> cancelUpload(String mediaId) async {
    final existing = await _db.mediaDao.getMediaById(mediaId);
    if (existing == null) {
      return;
    }
    if (existing.uploadState == 'uploaded') {
      return;
    }
    await _db.mediaDao.updateUploadState(
      mediaId: mediaId,
      uploadState: 'canceled',
      uploadProgress: 0.0,
      errorMessage: null,
      nextAttemptAt: null,
      workerSessionId: null,
    );
    await _cleanupLocalArtifacts(existing);
  }

  Future<void> removeMedia(String mediaId) async {
    final existing = await _db.mediaDao.getMediaById(mediaId);
    if (existing == null) {
      return;
    }

    if (existing.uploadState == 'uploaded' && existing.remoteUrl != null) {
      try {
        await _mediaUploader.deleteMedia(mediaId: mediaId);
      } catch (error) {
        debugPrint('[MEDIA_UPLOAD] remote delete failed mediaId=$mediaId $error');
      }

      final placeAttachments = await _db.mediaAttachmentsDao.listForMedia(
        mediaId,
      );
      for (final attachment in placeAttachments) {
        if (attachment.targetKind == 'place' && attachment.role == 'review') {
          await _placeRepository.removePhotoUrlBridge(
            localPlaceId: attachment.targetLocalId,
            photoUrl: existing.remoteUrl!,
          );
          break;
        }
      }
    }

    await _db.mediaDao.deleteMedia(mediaId);
    await _cleanupLocalArtifacts(existing);
  }

  Future<void> _cleanupLocalArtifacts(MediaItem item) async {
    await _deleteIfExists(item.localUri);
    await _deleteIfExists(item.thumbnailLocalPath);
  }

  Future<void> _deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Cleanup should not block user actions.
    }
  }

  Future<String?> _copyToManagedUploadPath({
    required String sourcePath,
    required String mediaId,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      return null;
    }

    final supportDir = await _supportDirectoryProvider();
    final uploadDir = Directory(
      p.join(supportDir.path, 'dora', 'media', 'uploads'),
    );
    if (!await uploadDir.exists()) {
      await uploadDir.create(recursive: true);
    }

    final extension = p.extension(sourcePath).toLowerCase();
    final destinationPath = p.join(
      uploadDir.path,
      extension.isEmpty ? '$mediaId.jpg' : '$mediaId$extension',
    );
    final copied = await sourceFile.copy(destinationPath);
    return copied.path;
  }
}

