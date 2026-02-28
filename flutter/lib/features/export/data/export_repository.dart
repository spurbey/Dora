import 'package:dio/dio.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/domain/export_state.dart';

/// Export repository that owns local pre-submit guards and create-export calls.
class ExportRepository {
  ExportRepository(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  static const Set<String> _pendingMediaStatuses = {
    'queued',
    'compressing',
    'uploading',
  };

  static const Set<String> _failedMediaStatuses = {
    'failed',
    'blocked',
  };

  static const Set<String> _blockingSyncStatuses = {
    'queued',
    'in_progress',
    'failed',
    'blocked',
  };

  /// Evaluates all frozen 6A pre-submit conditions from local DB state.
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId) async {
    final trip = await _db.tripDao.getTripById(tripId);
    if (trip == null) {
      return ExportPrecheckResult(
        tripId: tripId,
        tripExists: false,
        hasServerTripId: false,
        pendingMediaCount: 0,
        failedMediaCount: 0,
        blockingSyncTaskCount: 0,
      );
    }

    final hasServerTripId = (trip.serverTripId ?? '').trim().isNotEmpty;
    final mediaItems = await _db.mediaDao.getMediaForTrip(tripId);
    final pendingMediaCount = mediaItems
        .where((item) => _pendingMediaStatuses.contains(item.uploadStatus))
        .length;
    final failedMediaCount = mediaItems
        .where((item) => _failedMediaStatuses.contains(item.uploadStatus))
        .length;

    final blockingSyncTaskCount = await _countBlockingSyncTasks(tripId);

    return ExportPrecheckResult(
      tripId: tripId,
      tripExists: true,
      hasServerTripId: hasServerTripId,
      pendingMediaCount: pendingMediaCount,
      failedMediaCount: failedMediaCount,
      blockingSyncTaskCount: blockingSyncTaskCount,
    );
  }

  /// Submits a hardcoded 6A `classic` export request to backend control-plane.
  Future<ExportSubmitResult> submitClassicExport(String localTripId) async {
    final trip = await _db.tripDao.getTripById(localTripId);
    if (trip == null) {
      throw const ExportRepositoryException(
        'Trip was not found. Refresh and try again.',
      );
    }

    final serverTripId = (trip.serverTripId ?? '').trim();
    if (serverTripId.isEmpty) {
      throw const ExportRepositoryException(
        'Trip must be synced before exporting.',
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/trips/$serverTripId/export',
        data: const <String, dynamic>{
          'template': 'classic',
          'aspect_ratio': '9:16',
          'duration_sec': 15,
          'quality': '720p',
          'fps': 30,
        },
      );

      final body = response.data ?? const <String, dynamic>{};
      final jobId = body['job_id'] as String?;
      if (jobId == null || jobId.isEmpty) {
        throw const ExportRepositoryException(
          'Export request was accepted but no job id was returned.',
        );
      }

      return ExportSubmitResult(
        jobId: jobId,
        deduplicated: false,
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final body = error.response?.data;

      if (statusCode == 409 &&
          body is Map<String, dynamic> &&
          body['error'] == 'duplicate_job') {
        final existingJobId = body['existing_job_id'] as String?;
        if (existingJobId != null && existingJobId.isNotEmpty) {
          return ExportSubmitResult(
            jobId: existingJobId,
            deduplicated: true,
          );
        }
      }

      final message = _mapSubmitError(error);
      throw ExportRepositoryException(message);
    }
  }

  Future<int> _countBlockingSyncTasks(String tripId) async {
    final places = await _db.placeDao.getPlacesForTrip(tripId);
    final routes = await _db.routeDao.getRoutesForTrip(tripId);
    final placeIds = places.map((place) => place.id).toSet();
    final routeIds = routes.map((route) => route.id).toSet();

    final activeTasks = await _db.syncTaskDao.getActiveTasks(limit: 500);
    var count = 0;

    for (final task in activeTasks) {
      if (!_blockingSyncStatuses.contains(task.status)) {
        continue;
      }
      if (_taskBelongsToTrip(
        task: task,
        tripId: tripId,
        placeIds: placeIds,
        routeIds: routeIds,
      )) {
        count += 1;
      }
    }

    return count;
  }

  bool _taskBelongsToTrip({
    required SyncTaskRow task,
    required String tripId,
    required Set<String> placeIds,
    required Set<String> routeIds,
  }) {
    if (task.entityType == 'trip' && task.entityId == tripId) {
      return true;
    }
    if (task.entityType == 'place' && placeIds.contains(task.entityId)) {
      return true;
    }
    if (task.entityType == 'route' && routeIds.contains(task.entityId)) {
      return true;
    }
    return task.dependsOnEntityType == 'trip' &&
        task.dependsOnEntityId == tripId;
  }

  String _mapSubmitError(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = error.response?.data;
    if (statusCode == 422 && body is Map<String, dynamic>) {
      final reason = (body['reason'] as String?) ?? '';
      if (reason == 'trip_not_synced') {
        return 'Trip must be synced before exporting.';
      }
      if (reason == 'pending_media') {
        return 'Finish media uploads before exporting.';
      }
      if (reason == 'pending_sync') {
        return 'Wait for sync queue to finish before exporting.';
      }
      return (body['detail'] as String?) ??
          'Export preconditions failed. Resolve pending work and retry.';
    }

    if (statusCode == 401) {
      return 'Session expired. Sign in again and retry export.';
    }
    if (statusCode == 403) {
      return 'You do not have permission to export this trip.';
    }
    if (statusCode == 404) {
      return 'Trip not found on backend. Sync and retry export.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Export service is temporarily unavailable. Please retry.';
    }

    return error.message ?? 'Failed to submit export job.';
  }
}

/// Repository-level export error surfaced to presentation layer.
class ExportRepositoryException implements Exception {
  const ExportRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
