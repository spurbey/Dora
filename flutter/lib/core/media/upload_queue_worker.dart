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
        uploadStatus: 'compressing',
        uploadProgress: 0.05,
        workerSessionId: workerSessionId,
        errorMessage: null,
      );
      debugPrint('[MEDIA_COMPRESS] start mediaId=${task.id}');

      final compressed = await _imageCompressor.compress(
        inputPath: task.localPath,
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
        localPath: task.localPath,
        thumbnailPath: generatedThumbnailPath,
        mimeType: _guessMimeType(compressed.file.path),
        fileSizeBytes: localSize,
      );

      await _database.mediaDao.updateUploadState(
        mediaId: task.id,
        uploadStatus: 'uploading',
        uploadProgress: 0.1,
        workerSessionId: workerSessionId,
        errorMessage: null,
      );
      debugPrint('[MEDIA_UPLOAD] start mediaId=${task.id}');

      final remotePlaceId = await _placeRepository.ensureRemotePlaceId(task.placeId);
      debugPrint(
          '[PLACE_ID_BIND] resolved local=${task.placeId} remote=$remotePlaceId');

      final uploaded = await _uploader.uploadPhoto(
        UploadPhotoRequest(
          tripPlaceId: remotePlaceId,
          filePath: compressed.file.path,
          onProgress: (progress) {
            final normalized = progress.clamp(0.0, 1.0).toDouble();
            final queueProgress = 0.1 + (normalized * 0.9);
            unawaited(
              _database.mediaDao.updateUploadState(
                mediaId: task!.id,
                uploadStatus: 'uploading',
                uploadProgress: queueProgress,
                workerSessionId: workerSessionId,
              ),
            );
          },
        ),
      );

      await _database.mediaDao.markUploaded(
        mediaId: task.id,
        url: uploaded.fileUrl,
        thumbnailPath: uploaded.thumbnailUrl ?? generatedThumbnailPath,
        mimeType: uploaded.mimeType ?? _guessMimeType(compressed.file.path),
        fileSizeBytes: uploaded.fileSizeBytes ?? localSize,
        width: uploaded.width,
        height: uploaded.height,
        uploadedAt: uploaded.createdAt,
      );
      if (uploaded.mediaId != task.id) {
        await _database.mediaDao.replaceMediaId(
          oldMediaId: task.id,
          newMediaId: uploaded.mediaId,
        );
      }
      await _placeRepository.addPhotoUrlBridge(
        localPlaceId: task.placeId,
        photoUrl: uploaded.fileUrl,
      );
      debugPrint('[MEDIA_UPLOAD] success mediaId=${task.id}');

      await _cleanupTemporaryFile(temporaryCompressedPath);
    } catch (error, stackTrace) {
      debugPrint('[MEDIA_UPLOAD] failed mediaId=${row.id} error=$error');
      debugPrint('$stackTrace');
      nextRetryCount = math.min(row.retryCount + 1, _maxRetryAttempts);
      final canRetry =
          _isRetryable(error) && row.retryCount < (_maxRetryAttempts - 1);
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
        return true;
      }
      return false;
    }
    return false;
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
