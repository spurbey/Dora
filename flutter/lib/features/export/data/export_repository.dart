import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/data/export_api.dart';
import 'package:dora/features/export/domain/export_error_strings.dart';
import 'package:dora/features/export/domain/export_state.dart';

/// Contract for export data operations used by providers/UI.
abstract class ExportRepositoryContract {
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId);
  Future<ExportSubmitResult> submitClassicExport(String localTripId);
}

/// Export repository that owns local pre-submit guards and create-export calls.
class ExportRepository implements ExportRepositoryContract {
  ExportRepository(this._db, this._api);

  final AppDatabase _db;
  final ExportApi _api;

  static const Set<String> _pendingMediaStatuses = {
    'queued',
    'compressing',
    'uploading',
  };

  static const Set<String> _failedMediaStatuses = {
    'failed',
    'blocked',
  };

  /// Evaluates all frozen 6A pre-submit conditions from local DB state.
  @override
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
  @override
  Future<ExportSubmitResult> submitClassicExport(String localTripId) async {
    final latestPrecheck = await evaluatePreSubmitGuards(localTripId);
    if (!latestPrecheck.canExport) {
      throw ExportRepositoryException(
        ExportErrorStrings.messageForFailure(latestPrecheck.failures.first),
      );
    }

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
      final body = await _api.createExportJob(
        serverTripId: serverTripId,
        payload: const <String, dynamic>{
          'template': 'classic',
          'aspect_ratio': '9:16',
          'duration_sec': 15,
          'quality': '720p',
          'fps': 30,
        },
      );
      final jobId = _readString(body, 'job_id');
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
      final errorPayload = _extractErrorPayload(error.response?.data);

      if (statusCode == 409 &&
          _readString(errorPayload, 'error') == 'duplicate_job') {
        final existingJobId = _readString(errorPayload, 'existing_job_id');
        if (existingJobId != null && existingJobId.isNotEmpty) {
          return ExportSubmitResult(
            jobId: existingJobId,
            deduplicated: true,
          );
        }
      }

      final message = _mapSubmitError(
        statusCode: statusCode,
        payload: errorPayload,
        fallbackMessage: error.message,
      );
      throw ExportRepositoryException(message);
    }
  }

  Future<int> _countBlockingSyncTasks(String tripId) async {
    final variables = <Variable<String>>[
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ];

    final query = '''
      SELECT COUNT(*) AS task_count
      FROM sync_tasks
      WHERE status IN ('queued', 'in_progress', 'failed', 'blocked')
        AND (
          (entity_type = 'trip' AND entity_id = ?)
          OR (depends_on_entity_type = 'trip' AND depends_on_entity_id = ?)
          OR (
            entity_type = 'place'
            AND EXISTS (
              SELECT 1
              FROM places
              WHERE places.id = sync_tasks.entity_id
                AND places.trip_id = ?
            )
          )
          OR (
            entity_type = 'route'
            AND EXISTS (
              SELECT 1
              FROM routes
              WHERE routes.id = sync_tasks.entity_id
                AND routes.trip_id = ?
            )
          )
        )
    ''';

    final row = await _db.customSelect(query, variables: variables).getSingle();
    return row.read<int>('task_count') ?? 0;
  }

  String _mapSubmitError({
    required int? statusCode,
    required Map<String, dynamic> payload,
    required String? fallbackMessage,
  }) {
    if (statusCode == 422) {
      final reason = _readString(payload, 'reason') ?? '';
      if (reason == 'trip_not_synced') {
        return 'Trip must be synced before exporting.';
      }
      if (reason == 'pending_media') {
        return 'Finish media uploads before exporting.';
      }
      if (reason == 'pending_sync') {
        return 'Wait for sync queue to finish before exporting.';
      }
      return _readString(payload, 'detail') ??
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

    return fallbackMessage ?? 'Failed to submit export job.';
  }

  Map<String, dynamic> _extractErrorPayload(dynamic responseBody) {
    final topLevel = _toStringKeyMap(responseBody);
    if (topLevel.isEmpty) {
      return const <String, dynamic>{};
    }

    final nestedDetail = _toStringKeyMap(topLevel['detail']);
    if (nestedDetail.containsKey('error') ||
        nestedDetail.containsKey('reason')) {
      return nestedDetail;
    }

    return topLevel;
  }

  Map<String, dynamic> _toStringKeyMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }
    return const <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

}

/// Repository-level export error surfaced to presentation layer.
class ExportRepositoryException implements Exception {
  const ExportRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
