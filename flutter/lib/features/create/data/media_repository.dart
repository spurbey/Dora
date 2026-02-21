import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  })  : _queueWorker = queueWorker,
        _placeRepository = placeRepository,
        _mediaUploader = mediaUploader,
        _supportDirectoryProvider =
            supportDirectoryProvider ?? getApplicationSupportDirectory;

  final AppDatabase _db;
  final UploadQueueWorker _queueWorker;
  final PlaceRepository _placeRepository;
  final AppMediaUploader _mediaUploader;
  final Future<Directory> Function() _supportDirectoryProvider;

  Stream<List<MediaItem>> watchPlaceMedia(String placeId) {
    return _db.mediaDao.watchMediaForPlace(placeId);
  }

  Stream<int> watchPendingCount(String placeId) {
    return _db.mediaDao.watchPendingCountForPlace(placeId);
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

    final insertedIds = <String>[];

    await _db.transaction(() async {
      for (final path in filePaths) {
        final id = const Uuid().v4();
        insertedIds.add(id);
        final nowForRow = DateTime.now();
        final managedPath = await _copyToManagedUploadPath(
          sourcePath: path,
          mediaId: id,
        );

        if (managedPath == null) {
          await _db.mediaDao.insertMedia(
            MediaCompanion(
              id: Value(id),
              tripId: Value(tripId),
              placeId: Value(placeId),
              localPath: Value(path),
              type: const Value('photo'),
              uploadStatus: const Value('failed'),
              uploadProgress: const Value(0.0),
              retryCount: const Value(0),
              errorMessage: const Value(
                  'Selected file is no longer available on device storage'),
              uploadedAt: const Value(null),
              nextAttemptAt: const Value(null),
              workerSessionId: const Value(null),
              localUpdatedAt: Value(nowForRow),
              serverUpdatedAt: Value(nowForRow),
              syncStatus: const Value('pending'),
              createdAt: Value(nowForRow),
            ),
          );
          continue;
        }

        await _db.mediaDao.insertMedia(
          MediaCompanion(
            id: Value(id),
            tripId: Value(tripId),
            placeId: Value(placeId),
            localPath: Value(managedPath),
            type: const Value('photo'),
            uploadStatus: const Value('queued'),
            uploadProgress: const Value(0.0),
            retryCount: const Value(0),
            errorMessage: const Value(null),
            uploadedAt: const Value(null),
            nextAttemptAt: const Value(null),
            workerSessionId: const Value(null),
            localUpdatedAt: Value(nowForRow),
            serverUpdatedAt: Value(nowForRow),
            syncStatus: const Value('pending'),
            createdAt: Value(nowForRow),
          ),
        );
      }
    });

    debugPrint('[MEDIA_QUEUE] enqueued count=${insertedIds.length}');
    await _queueWorker.startIfIdle();
    return insertedIds;
  }

  Future<void> retryUpload(String mediaId) async {
    final existing = await _db.mediaDao.getMediaById(mediaId);
    if (existing == null) {
      return;
    }
    if (existing.uploadStatus == 'uploaded') {
      return;
    }
    await _db.mediaDao.updateUploadState(
      mediaId: mediaId,
      uploadStatus: 'queued',
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
    if (existing.uploadStatus == 'uploaded') {
      return;
    }
    await _db.mediaDao.updateUploadState(
      mediaId: mediaId,
      uploadStatus: 'canceled',
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

    if (existing.uploadStatus == 'uploaded' && existing.url != null) {
      try {
        await _mediaUploader.deleteMedia(mediaId: mediaId);
      } catch (error) {
        debugPrint('[MEDIA_UPLOAD] remote delete failed mediaId=$mediaId $error');
      }

      final localPlaceId = existing.placeId;
      if (localPlaceId != null && localPlaceId.isNotEmpty) {
        await _placeRepository.removePhotoUrlBridge(
          localPlaceId: localPlaceId,
          photoUrl: existing.url!,
        );
      }
    }

    await _db.mediaDao.deleteMedia(mediaId);
    await _cleanupLocalArtifacts(existing);
  }

  Future<void> _cleanupLocalArtifacts(MediaItem item) async {
    await _deleteIfExists(item.localPath);
    await _deleteIfExists(item.thumbnailPath);
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
