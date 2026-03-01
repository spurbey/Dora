import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:dora_api/dora_api.dart' as api;

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/domain/export_error_strings.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/domain/export_template.dart';

/// Contract for export data operations used by providers/UI.
abstract class ExportRepositoryContract {
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId);

  /// 6A compat: submits with the default classic template.
  Future<ExportSubmitResult> submitClassicExport(String localTripId);

  /// 6B: submits with the user-selected template.
  Future<ExportSubmitResult> submitExport(
      String localTripId, ExportTemplate template);

  Future<ExportJob> getJobStatus(String jobId);
  Future<void> cancelJob(String jobId);
  Future<String> getDownloadUrl(String jobId);
  Future<String> getShareUrl(String jobId);
}

/// Export repository that owns local pre-submit guards and create-export calls.
class ExportRepository implements ExportRepositoryContract {
  ExportRepository(this._db, this._exportsApi, this._getToken);

  final AppDatabase _db;
  final api.ExportsApi _exportsApi;

  /// Returns the current auth bearer token, or null if the session has expired.
  final Future<String?> Function() _getToken;

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

  /// 6A compat: submits with the default classic template.
  @override
  Future<ExportSubmitResult> submitClassicExport(String localTripId) =>
      submitExport(localTripId, ExportTemplate.classic);

  /// 6B: submits with the user-selected template.
  @override
  Future<ExportSubmitResult> submitExport(
      String localTripId, ExportTemplate template) async {
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

    final authorization = await _bearerToken();

    try {
      final response = await _exportsApi.createExportApiV1TripsTripIdExportPost(
        tripId: serverTripId,
        authorization: authorization,
        exportCreateRequest: api.ExportCreateRequest(
          (b) => b..template = _mapTemplate(template),
        ),
      );

      final jobId = response.data?.jobId ?? '';
      if (jobId.isEmpty) {
        throw const ExportRepositoryException(
          'Export request was accepted but no job id was returned.',
        );
      }

      return ExportSubmitResult(jobId: jobId, deduplicated: false);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final errorPayload = _extractErrorPayload(error.response?.data);

      if (statusCode == 409 &&
          _readString(errorPayload, 'error') == 'duplicate_job') {
        final existingJobId = _readString(errorPayload, 'existing_job_id');
        if (existingJobId != null && existingJobId.isNotEmpty) {
          return ExportSubmitResult(jobId: existingJobId, deduplicated: true);
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

  @override
  Future<ExportJob> getJobStatus(String jobId) async {
    final authorization = await _bearerToken();
    try {
      final response =
          await _exportsApi.getExportStatusApiV1ExportsJobIdGet(
        jobId: jobId,
        authorization: authorization,
      );
      final data = response.data;
      if (data == null) {
        throw const ExportRepositoryException('Empty response from export status endpoint.');
      }
      return _mapStatusResponse(data);
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 404) {
        throw const ExportRepositoryException('Export job not found.');
      }
      if (statusCode == 401) {
        throw const ExportRepositoryException(
            'Session expired. Sign in again.');
      }
      throw ExportRepositoryException(
          error.message ?? 'Failed to fetch export status.');
    }
  }

  @override
  Future<void> cancelJob(String jobId) async {
    final authorization = await _bearerToken();
    try {
      await _exportsApi.cancelExportApiV1ExportsJobIdCancelPost(
        jobId: jobId,
        authorization: authorization,
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 409) {
        // Job already completed — not an error from the user's perspective.
        return;
      }
      throw ExportRepositoryException(
          error.message ?? 'Failed to cancel export job.');
    }
  }

  @override
  Future<String> getDownloadUrl(String jobId) async {
    final authorization = await _bearerToken();
    try {
      final response =
          await _exportsApi.getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet(
        jobId: jobId,
        authorization: authorization,
      );
      final url = response.data?.downloadUrl ?? '';
      if (url.isEmpty) {
        throw const ExportRepositoryException('Download URL was empty.');
      }
      return url;
    } on DioException catch (error) {
      throw ExportRepositoryException(
          error.message ?? 'Failed to get download URL.');
    }
  }

  @override
  Future<String> getShareUrl(String jobId) async {
    final authorization = await _bearerToken();
    try {
      final response =
          await _exportsApi.getExportShareUrlApiV1ExportsJobIdShareGet(
        jobId: jobId,
        authorization: authorization,
      );
      final url = response.data?.shareUrl ?? '';
      if (url.isEmpty) {
        throw const ExportRepositoryException('Share URL was empty.');
      }
      return url;
    } on DioException catch (error) {
      throw ExportRepositoryException(
          error.message ?? 'Failed to get share URL.');
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<String> _bearerToken() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw const ExportRepositoryException(
          'Session expired. Sign in again and retry export.');
    }
    return 'Bearer $token';
  }

  api.ExportTemplate _mapTemplate(ExportTemplate template) {
    switch (template) {
      case ExportTemplate.classic:
        return api.ExportTemplate.classic;
      case ExportTemplate.cinematic:
        return api.ExportTemplate.cinematic;
    }
  }

  ExportJob _mapStatusResponse(api.ExportStatusResponse data) {
    return ExportJob(
      jobId: data.jobId,
      status: _mapStatus(data.status),
      progress: data.progress.toDouble(),
      stage: _mapStage(data.stage),
      outputUrl: data.outputUrl,
      thumbnailUrl: data.thumbnailUrl,
      errorCode: data.errorCode,
      errorMessage: data.errorMessage,
    );
  }

  ExportJobStatus _mapStatus(api.ExportStatus s) {
    if (s == api.ExportStatus.queued) return ExportJobStatus.queued;
    if (s == api.ExportStatus.processing) return ExportJobStatus.processing;
    if (s == api.ExportStatus.cancelRequested) {
      return ExportJobStatus.cancelRequested;
    }
    if (s == api.ExportStatus.completed) return ExportJobStatus.completed;
    if (s == api.ExportStatus.failed) return ExportJobStatus.failed;
    if (s == api.ExportStatus.canceled) return ExportJobStatus.canceled;
    if (s == api.ExportStatus.blocked) return ExportJobStatus.blocked;
    return ExportJobStatus.failed;
  }

  ExportJobStage? _mapStage(api.ExportStage? s) {
    if (s == null) return null;
    if (s == api.ExportStage.snapshotting) return ExportJobStage.snapshotting;
    if (s == api.ExportStage.assetFetch) return ExportJobStage.assetFetch;
    if (s == api.ExportStage.rendering) return ExportJobStage.rendering;
    if (s == api.ExportStage.encoding) return ExportJobStage.encoding;
    if (s == api.ExportStage.uploading) return ExportJobStage.uploading;
    if (s == api.ExportStage.finalizing) return ExportJobStage.finalizing;
    return null;
  }

  Future<int> _countBlockingSyncTasks(String tripId) async {
    final variables = <Variable<String>>[
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
      Variable<String>(tripId),
    ];

    const query = '''
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
    return row.read<int>('task_count');
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
        return 'Finish pending media uploads before exporting.';
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
