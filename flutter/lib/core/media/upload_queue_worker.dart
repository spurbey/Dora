import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'package:dora/core/media/app_media_uploader.dart';
import 'package:dora/core/media/image_compressor.dart';
import 'package:dora/core/media/models/queued_media_task.dart';
import 'package:dora/core/media/thumbnail_generator.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/place_repository.dart';

class UploadQueueWorker {
  UploadQueueWorker({
    required AppDatabase database,
    required PlaceRepository placeRepository,
    required AppMediaUploader uploader,
    required ImageCompressor imageCompressor,
    required ThumbnailGenerator thumbnailGenerator,
    int maxConcurrency = 2,
  })  : _database = database,
        _placeRepository = placeRepository,
        _uploader = uploader,
        _imageCompressor = imageCompressor,
        _thumbnailGenerator = thumbnailGenerator,
        _maxConcurrency = maxConcurrency;

  final AppDatabase _database;
  final PlaceRepository _placeRepository;
  final AppMediaUploader _uploader;
  final ImageCompressor _imageCompressor;
  final ThumbnailGenerator _thumbnailGenerator;
  final int _maxConcurrency;

  static const int _maxRetryAttempts = 3;
  static const Duration _firstRetryDelay = Duration(seconds: 10);
  static const Duration _secondRetryDelay = Duration(seconds: 30);

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  Future<void> startIfIdle() async {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    try {
      while (true) {
        final sessionId = const Uuid().v4();
        final claimed = await _database.mediaDao.claimPendingUploads(
          workerSessionId: sessionId,
          limit: _maxConcurrency,
        );
        if (claimed.isEmpty) {
          break;
        }

        debugPrint(
            '[MEDIA_QUEUE] claimed=${claimed.length} session=$sessionId');
        await Future.wait(
          claimed.map(_processClaimedItem),
          eagerError: false,
        );
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processClaimedItem(MediaItem row) async {
    String? workerSessionId = row.workerSessionId;
    QueuedMediaTask? task;
    String? temporaryCompressedPath;
    String? generatedThumbnailPath;
    int nextRetryCount = row.retryCount;

    try {
      task = QueuedMediaTask.fromRow(row);
      workerSessionId = task.workerSessionId;

      await _database.mediaDao.updateUploadState(
        mediaId: task.id,
        uploadState: 'compressing',
        uploadProgress: 0.05,
        workerSessionId: workerSessionId,
        errorMessage: null,
      );
      debugPrint('[MEDIA_COMPRESS] start mediaId=${task.id}');

      final compressed = await _imageCompressor.compress(
        inputPath: task.localUri,
        mediaId: task.id,
      );
      if (compressed.isTemporary) {
        temporaryCompressedPath = compressed.file.path;
      }

      generatedThumbnailPath = await _thumbnailGenerator.generate(
        sourcePath: compressed.file.path,
        mediaId: task.id,
      );
      final localSize = await compressed.file.length();
      await _database.mediaDao.updateLocalArtifacts(
        mediaId: task.id,
        localUri: task.localUri,
        thumbnailLocalPath: generatedThumbnailPath,
        mimeType: _guessMimeType(compressed.file.path),
        bytesSize: localSize,
      );

      await _database.mediaDao.updateUploadState(
        mediaId: task.id,
        uploadState: 'uploading',
        uploadProgress: 0.1,
        workerSessionId: workerSessionId,
        errorMessage: null,
      );
      debugPrint('[MEDIA_UPLOAD] start mediaId=${task.id}');

      final latestBeforeUpload = await _database.mediaDao.getMediaById(task.id);
      if (!_isTaskActive(
        latestBeforeUpload,
        workerSessionId: workerSessionId,
      )) {
        await _cleanupTemporaryFile(temporaryCompressedPath);
        return;
      }

      final placeAttachment = await _requirePlaceAttachment(task.id);
      final remotePlaceId = await _placeRepository.ensureRemotePlaceId(
        placeAttachment.targetLocalId,
      );
      debugPrint(
          '[PLACE_ID_BIND] resolved local=${placeAttachment.targetLocalId} remote=$remotePlaceId');

      final uploaded = await _uploader.uploadPhoto(
        UploadPhotoRequest(
          tripPlaceId: remotePlaceId,
          filePath: compressed.file.path,
          onProgress: (progress) {
            final normalized = progress.clamp(0.0, 1.0).toDouble();
            final queueProgress = 0.1 + (normalized * 0.9);
            final session = workerSessionId;
            if (session == null || session.isEmpty) {
              return;
            }
            unawaited(
              _database.mediaDao.updateUploadProgressIfActive(
                mediaId: task!.id,
                workerSessionId: session,
                uploadProgress: queueProgress,
              ),
            );
          },
        ),
      );

      final latestBeforeFinalize =
          await _database.mediaDao.getMediaById(task.id);
      if (!_shouldFinalizeSuccess(
        latestBeforeFinalize,
        workerSessionId: workerSessionId,
      )) {
        await _safeDeleteRemoteMedia(uploaded.mediaId);
        await _cleanupTemporaryFile(temporaryCompressedPath);
        return;
      }

      final updatedRows = await _database.mediaDao.markUploaded(
        mediaId: task.id,
        remoteUrl: uploaded.fileUrl,
        remoteThumbnailUrl: uploaded.thumbnailUrl ?? generatedThumbnailPath,
        serverId: uploaded.mediaId,
        mimeType: uploaded.mimeType ?? _guessMimeType(compressed.file.path),
        bytesSize: uploaded.fileSizeBytes ?? localSize,
        widthPx: uploaded.width,
        heightPx: uploaded.height,
        uploadedAt: uploaded.createdAt,
      );
      if (updatedRows == 0) {
        await _safeDeleteRemoteMedia(uploaded.mediaId);
        await _cleanupTemporaryFile(temporaryCompressedPath);
        return;
      }
      if (uploaded.mediaId != task.id) {
        await _database.mediaDao.replaceMediaId(
          oldMediaId: task.id,
          newMediaId: uploaded.mediaId,
        );
      }
      await _database.mediaAttachmentsDao.setTargetServerId(
        targetKind: 'place',
        targetLocalId: placeAttachment.targetLocalId,
        targetServerId: remotePlaceId,
      );
      await _placeRepository.addPhotoUrlBridge(
        localPlaceId: placeAttachment.targetLocalId,
        photoUrl: uploaded.fileUrl,
      );
      debugPrint('[MEDIA_UPLOAD] success mediaId=${task.id}');

      await _cleanupTemporaryFile(temporaryCompressedPath);
    } on _MissingAttachmentException catch (error) {
      debugPrint(
        '[MEDIA_UPLOAD] blocked_missing_attachment mediaId=${row.id} reason=${error.message}',
      );
      final latest = await _database.mediaDao.getMediaById(row.id);
      if (!_shouldPersistFailure(
        latest,
        workerSessionId: workerSessionId,
      )) {
        return;
      }
      await _database.mediaDao.markBlocked(
        mediaId: row.id,
        message: error.message,
      );
    } on PlaceIdentityException catch (error, stackTrace) {
      debugPrint(
          '[MEDIA_UPLOAD] blocked mediaId=${row.id} error=${error.message}');
      debugPrint('$stackTrace');
      final latestBeforeFailure = await _database.mediaDao.getMediaById(row.id);
      if (!_shouldPersistFailure(
        latestBeforeFailure,
        workerSessionId: workerSessionId,
      )) {
        return;
      }

      if (error.retryable) {
        final currentRetryCount =
            latestBeforeFailure?.retryCount ?? row.retryCount;
        nextRetryCount = math.min(currentRetryCount + 1, _maxRetryAttempts);
        final canRetry = currentRetryCount < (_maxRetryAttempts - 1);
        final nextAttemptAt = canRetry
            ? DateTime.now().add(_backoffForRetry(nextRetryCount))
            : null;
        await _database.mediaDao.markFailed(
          mediaId: row.id,
          errorMessage: error.message,
          retryCount: nextRetryCount,
          nextAttemptAt: nextAttemptAt,
        );
      } else {
        await _database.mediaDao.markBlocked(
          mediaId: row.id,
          message: error.message,
        );
      }
    } catch (error, stackTrace) {
      debugPrint('[MEDIA_UPLOAD] failed mediaId=${row.id} error=$error');
      debugPrint('$stackTrace');
      final latestBeforeFailure = await _database.mediaDao.getMediaById(row.id);
      if (!_shouldPersistFailure(
        latestBeforeFailure,
        workerSessionId: workerSessionId,
      )) {
        return;
      }

      final currentRetryCount =
          latestBeforeFailure?.retryCount ?? row.retryCount;
      nextRetryCount = math.min(currentRetryCount + 1, _maxRetryAttempts);
      final canRetry =
          _isRetryable(error) && currentRetryCount < (_maxRetryAttempts - 1);
      final nextAttemptAt = canRetry
          ? DateTime.now().add(_backoffForRetry(nextRetryCount))
          : null;
      await _database.mediaDao.markFailed(
        mediaId: row.id,
        errorMessage: _compactError(error),
        retryCount: nextRetryCount,
        nextAttemptAt: nextAttemptAt,
      );
    } finally {
      if (workerSessionId != null && workerSessionId.isNotEmpty) {
        await _database.mediaDao.clearWorkerSession(
          mediaId: row.id,
          expectedSessionId: workerSessionId,
        );
      }
      if (nextRetryCount >= _maxRetryAttempts) {
        await _cleanupTemporaryFile(temporaryCompressedPath);
        await _cleanupTemporaryFile(generatedThumbnailPath);
      }
    }
  }

  bool _shouldFinalizeSuccess(
    MediaItem? latest, {
    required String? workerSessionId,
  }) {
    if (latest == null) {
      return false;
    }
    if (latest.uploadState == 'canceled') {
      return false;
    }
    final activeSession = latest.workerSessionId;
    if (workerSessionId == null) {
      return false;
    }
    return activeSession == workerSessionId;
  }

  bool _shouldPersistFailure(
    MediaItem? latest, {
    required String? workerSessionId,
  }) {
    if (latest == null) {
      return false;
    }
    if (latest.uploadState == 'canceled') {
      return false;
    }
    final activeSession = latest.workerSessionId;
    if (workerSessionId == null) {
      return false;
    }
    return activeSession == workerSessionId;
  }

  bool _isTaskActive(
    MediaItem? latest, {
    required String? workerSessionId,
  }) {
    if (latest == null) {
      return false;
    }
    if (latest.uploadState == 'canceled') {
      return false;
    }
    if (workerSessionId == null) {
      return false;
    }
    return latest.workerSessionId == workerSessionId;
  }

  Future<MediaAttachmentRow> _requirePlaceAttachment(String mediaId) async {
    final attachments = await _database.mediaAttachmentsDao.listForMedia(
      mediaId,
    );
    for (final attachment in attachments) {
      if (attachment.targetKind == 'place' && attachment.role == 'review') {
        return attachment;
      }
    }
    throw _MissingAttachmentException(
      'Media $mediaId was queued for upload without a place-review attachment. '
      'The publisher must call enqueueMediaForTripPublish only after '
      'attachments are in place.',
    );
  }

  Duration _backoffForRetry(int retryCount) {
    if (retryCount <= 1) {
      return _firstRetryDelay;
    }
    return _secondRetryDelay;
  }

  bool _isRetryable(Object error) {
    if (error is TimeoutException || error is SocketException) {
      return true;
    }
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == null) {
        return true;
      }
      if (status == 408 || status == 429) {
        return true;
      }
      if (status >= 500) {
        if (_isNonRetryableServerConfigError(error)) {
          return false;
        }
        return true;
      }
      return false;
    }
    return false;
  }

  bool _isNonRetryableServerConfigError(DioException error) {
    final status = error.response?.statusCode;
    if (status == null || status < 500) {
      return false;
    }

    final detail = _extractDioErrorDetail(error.response?.data).toLowerCase();
    return detail.contains('storage service misconfigured') ||
        detail.contains('supabase_service_role_key') ||
        detail.contains('invalid api key');
  }

  String _extractDioErrorDetail(Object? payload) {
    if (payload is Map) {
      final detail = payload['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
    }
    if (payload is String && payload.isNotEmpty) {
      return payload;
    }
    return '';
  }

  String _compactError(Object error) {
    final message = error.toString().trim();
    if (message.length <= 500) {
      return message;
    }
    return message.substring(0, 500);
  }

  Future<void> _cleanupTemporaryFile(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Cleanup failures are intentionally non-fatal.
    }
  }

  Future<void> _safeDeleteRemoteMedia(String mediaId) async {
    if (mediaId.isEmpty) {
      return;
    }
    try {
      await _uploader.deleteMedia(mediaId: mediaId);
    } catch (_) {
      // Best-effort cleanup for uploads canceled/removed mid-flight.
    }
  }

  String _guessMimeType(String pathValue) {
    final extension = p.extension(pathValue).toLowerCase();
    return switch (extension) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      '.heic' || '.heif' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}

class _MissingAttachmentException implements Exception {
  const _MissingAttachmentException(this.message);

  final String message;

  @override
  String toString() => message;
}
