import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:dora_api/dora_api.dart' as api;

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/export/domain/export_error_strings.dart';
import 'package:dora/features/export/domain/export_job.dart';
import 'package:dora/features/export/domain/export_job_summary.dart';
import 'package:dora/features/export/domain/export_state.dart';
import 'package:dora/features/export/domain/export_template.dart';

/// Contract for export data operations used by providers/UI.
abstract class ExportRepositoryContract {
  Future<ExportJobListResult> listExportJobs({
    int page,
    int pageSize,
    String? status,
    String? tripId,
  });

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
  ExportRepository(this._db, this._exportsApi, this._dio, this._getToken);

  final AppDatabase _db;
  final api.ExportsApi _exportsApi;
  final Dio _dio;

  /// Returns the current auth bearer token, or null if the session has expired.
  final Future<String?> Function() _getToken;

  static const Set<String> _pendingMediaStatuses = {
    'queued',
    'deferred',
    'compressing',
    'uploading',
  };

  static const Set<String> _failedMediaStatuses = {
    'failed',
    'blocked',
  };

  @override
  Future<ExportJobListResult> listExportJobs({
    int page = 1,
    int pageSize = 50,
    String? status,
    String? tripId,
  }) async {
    final authorization = await _bearerToken();
    try {
      final response = await _dio.get<dynamic>(
        '/api/v1/exports',
        queryParameters: <String, dynamic>{
          'page': page,
          'page_size': pageSize,
          if (status != null && status.isNotEmpty) 'status': status,
          if (tripId != null && tripId.isNotEmpty) 'trip_id': tripId,
        },
        options: Options(
          headers: <String, dynamic>{
            'authorization': authorization,
          },
        ),
      );

      final payload = _toStringKeyMap(response.data);
      final exportsRaw = payload['exports'];
      final exportsList = exportsRaw is List ? exportsRaw : const <dynamic>[];
      final exports = exportsList
          .map((item) => _parseExportJobSummary(_toStringKeyMap(item)))
          .toList();

      return ExportJobListResult(
        exports: exports,
        total: _toInt(payload['total']) ?? exports.length,
        page: _toInt(payload['page']) ?? page,
        pageSize: _toInt(payload['page_size']) ?? pageSize,
        totalPages: _toInt(payload['total_pages']) ?? 1,
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        throw const ExportRepositoryException(
          'Session expired. Sign in again.',
        );
      }
      throw ExportRepositoryException(
        error.message ?? 'Failed to load export history.',
      );
    }
  }

  /// Evaluates all frozen 6A pre-submit conditions from local DB state.
  @override
  Future<ExportPrecheckResult> evaluatePreSubmitGuards(String tripId) async {
    final trip = await _db.tripDao.getTripById(tripId);
    final userTrip = await _db.userTripsDao.getTripById(tripId);
    final mediaStates = await _mediaUploadStatesForTrip(tripId);
    final pendingMediaCount = mediaStates
        .where((state) => _pendingMediaStatuses.contains(state))
        .length;
    final failedMediaCount = mediaStates
        .where((state) => _failedMediaStatuses.contains(state))
        .length;

    if (trip == null) {
      final isRemoteBacked = userTrip != null && userTrip.syncStatus == 'synced';
      return ExportPrecheckResult(
        tripId: tripId,
        tripExists: userTrip != null,
        hasServerTripId: isRemoteBacked,
        pendingMediaCount: pendingMediaCount,
        failedMediaCount: failedMediaCount,
        blockingV2ConditionCount: 0,
      );
    }

    final hasServerTripId = (trip.serverTripId ?? '').trim().isNotEmpty;

    final blockingV2Count = await _countBlockingV2Conditions(tripId);

    return ExportPrecheckResult(
      tripId: tripId,
      tripExists: true,
      hasServerTripId: hasServerTripId,
      pendingMediaCount: pendingMediaCount,
      failedMediaCount: failedMediaCount,
      blockingV2ConditionCount: blockingV2Count,
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
    final userTrip = await _db.userTripsDao.getTripById(localTripId);

    var serverTripId = (trip?.serverTripId ?? '').trim();
    if (serverTripId.isEmpty &&
        trip == null &&
        userTrip != null &&
        userTrip.syncStatus == 'synced') {
      // Remote-backed trip listed from backend, but local editor row is absent.
      // In this shape, localTripId is already the backend trip UUID.
      serverTripId = localTripId;
    }

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
      final response = await _exportsApi.getExportStatusApiV1ExportsJobIdGet(
        jobId: jobId,
        authorization: authorization,
      );
      final data = response.data;
      if (data == null) {
        throw const ExportRepositoryException(
            'Empty response from export status endpoint.');
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

  ExportJobSummary _parseExportJobSummary(Map<String, dynamic> payload) {
    final createdAt = _toDateTime(payload['created_at']) ?? DateTime.now();
    return ExportJobSummary(
      jobId: _toStringValue(payload['job_id']) ?? '',
      tripId: _toStringValue(payload['trip_id']) ?? '',
      tripTitle: _toStringValue(payload['trip_title']),
      template: _toStringValue(payload['template']) ?? 'classic',
      status: _mapStatusFromString(_toStringValue(payload['status']) ?? 'failed'),
      stage: _mapStageFromString(_toStringValue(payload['stage'])),
      progress: _toDouble(payload['progress']) ?? 0.0,
      outputUrl: _toStringValue(payload['output_url']),
      thumbnailUrl: _toStringValue(payload['thumbnail_url']),
      errorCode: _toStringValue(payload['error_code']),
      errorMessage: _toStringValue(payload['error_message']),
      createdAt: createdAt,
      completedAt: _toDateTime(payload['completed_at']),
    );
  }

  ExportJobStatus _mapStatusFromString(String value) {
    switch (value) {
      case 'queued':
        return ExportJobStatus.queued;
      case 'processing':
        return ExportJobStatus.processing;
      case 'cancel_requested':
        return ExportJobStatus.cancelRequested;
      case 'completed':
        return ExportJobStatus.completed;
      case 'canceled':
        return ExportJobStatus.canceled;
      case 'blocked':
        return ExportJobStatus.blocked;
      case 'failed':
      default:
        return ExportJobStatus.failed;
    }
  }

  ExportJobStage? _mapStageFromString(String? value) {
    switch (value) {
      case 'snapshotting':
        return ExportJobStage.snapshotting;
      case 'asset_fetch':
        return ExportJobStage.assetFetch;
      case 'rendering':
        return ExportJobStage.rendering;
      case 'encoding':
        return ExportJobStage.encoding;
      case 'uploading':
        return ExportJobStage.uploading;
      case 'finalizing':
        return ExportJobStage.finalizing;
      default:
        return null;
    }
  }

  /// Collects upload states for all media attached to a trip (direct trip
  /// attachments, place attachments on trip places, and trip-event capture
  /// attachments). Used to compute pending/failed counts for the precheck.
  Future<List<String>> _mediaUploadStatesForTrip(String tripLocalId) async {
    final rows = await _db.customSelect(
      '''
      SELECT DISTINCT m.id AS id, m.upload_state AS upload_state
      FROM media m
      INNER JOIN media_attachments ma ON ma.media_id = m.id
      WHERE ma.detached_at IS NULL
        AND m.deleted_at IS NULL
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
      variables: <Variable<Object>>[
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
    return rows.map((row) => row.read<String>('upload_state')).toList(
          growable: false,
        );
  }

  /// Counts blocking V2 conditions: active sessions + in-progress publishes.
  Future<int> _countBlockingV2Conditions(String tripId) async {
    final variables = <Variable<String>>[
      Variable<String>(tripId),
      Variable<String>(tripId),
    ];

    const query = '''
      SELECT
        (
          SELECT COUNT(*)
          FROM session_journal
          WHERE trip_local_id = ?
            AND control_state IN ('active', 'paused')
        ) +
        (
          SELECT COUNT(*)
          FROM trip_publish_state
          WHERE trip_local_id = ?
            AND publish_state = 'publishing'
        ) AS blocking_count
    ''';

    final row = await _db.customSelect(query, variables: variables).getSingle();
    return row.read<int>('blocking_count');
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

  String? _toStringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  DateTime? _toDateTime(dynamic value) {
    final asString = _toStringValue(value);
    if (asString == null || asString.isEmpty) {
      return null;
    }
    return DateTime.tryParse(asString);
  }

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}

/// Repository-level export error surfaced to presentation layer.
class ExportRepositoryException implements Exception {
  const ExportRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
