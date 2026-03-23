import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';

class TrackingSyncWorker {
  TrackingSyncWorker({
    required AppDatabase db,
    required SyncTaskDao syncTaskDao,
    required TrackingSessionDao trackingSessionDao,
    required TrackingPointBatchDao trackingPointBatchDao,
    required TrackingCandidateDao trackingCandidateDao,
    required TrackingMomentDao trackingMomentDao,
    required LiveTrackingApi liveTrackingApi,
    int maxConcurrency = 2,
  })  : _db = db,
        _syncTaskDao = syncTaskDao,
        _trackingSessionDao = trackingSessionDao,
        _trackingPointBatchDao = trackingPointBatchDao,
        _trackingCandidateDao = trackingCandidateDao,
        _trackingMomentDao = trackingMomentDao,
        _liveTrackingApi = liveTrackingApi,
        _maxConcurrency = maxConcurrency;

  final AppDatabase _db;
  final SyncTaskDao _syncTaskDao;
  final TrackingSessionDao _trackingSessionDao;
  final TrackingPointBatchDao _trackingPointBatchDao;
  final TrackingCandidateDao _trackingCandidateDao;
  final TrackingMomentDao _trackingMomentDao;
  final LiveTrackingApi _liveTrackingApi;
  final int _maxConcurrency;

  static const int _maxRetryAttempts = 3;
  static const Duration _firstRetryDelay = Duration(seconds: 15);
  static const Duration _secondRetryDelay = Duration(seconds: 60);

  bool _isRunning = false;
  final Uuid _uuid = const Uuid();

  bool get isRunning => _isRunning;

  Future<void> startIfIdle() async {
    if (_isRunning) {
      return;
    }
    _isRunning = true;
    try {
      while (true) {
        final sessionId = _newSessionId();
        final claimed = await _syncTaskDao.claimRunnableTasks(
          workerSessionId: sessionId,
          limit: _maxConcurrency,
          allowedEntityTypes: SyncEntityTypes.supportedByTrackingSyncWorker,
        );
        if (claimed.isEmpty) {
          break;
        }
        debugPrint(
          '[TRACKING_SYNC] claimed=${claimed.length} session=$sessionId',
        );
        await Future.wait(claimed.map(_processClaimedTask), eagerError: false);
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processClaimedTask(SyncTaskRow task) async {
    final sessionId = task.workerSessionId;
    try {
      switch (task.entityType) {
        case SyncEntityTypes.trackingSession:
          await _processTrackingSessionTask(
            task: task,
            sessionId: sessionId,
          );
          break;
        case SyncEntityTypes.trackingPointBatch:
          await _processTrackingPointBatchTask(
            task: task,
            sessionId: sessionId,
          );
          break;
        case SyncEntityTypes.checkinDecision:
          await _processCheckinDecisionTask(
            task: task,
            sessionId: sessionId,
          );
          break;
        case SyncEntityTypes.moment:
          await _processMomentTask(
            task: task,
            sessionId: sessionId,
          );
          break;
        default:
          throw _TrackingSyncTerminalException(
            code: 'unsupported_tracking_entity_type',
            message:
                'Unsupported tracking sync entity type: ${task.entityType}',
          );
      }
      debugPrint(
        '[TRACKING_SYNC] success entity=${task.entityType} entityId=${task.entityId} taskId=${task.id}',
      );
    } on _TrackingSyncTerminalException catch (error) {
      await _syncTaskDao.markBlocked(
        taskId: task.id,
        errorCode: error.code,
        errorMessage: error.message,
        expectedSessionId: sessionId,
      );
      debugPrint(
        '[TRACKING_SYNC] blocked taskId=${task.id} reason=${error.code}',
      );
    } on _TrackingSyncDeferredException catch (error) {
      await _syncTaskDao.markPending(
        taskId: task.id,
        errorCode: error.code,
        errorMessage: error.message,
        expectedSessionId: sessionId,
        dependsOnEntityType: error.dependsOnEntityType,
        dependsOnEntityId: error.dependsOnEntityId,
        nextAttemptAt: DateTime.now().add(_firstRetryDelay),
      );
      debugPrint(
        '[TRACKING_SYNC] pending taskId=${task.id} reason=${error.code}',
      );
    } on _TrackingSyncRetryableException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: error.code,
        message: error.message,
        retryable: true,
      );
    } on DioException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: _dioErrorCode(error),
        message: _compactError(error),
        retryable: _isRetryableDio(error),
      );
    } on TimeoutException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: 'network_timeout',
        message: _compactError(error),
        retryable: true,
      );
    } on SocketException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: 'network_unreachable',
        message: _compactError(error),
        retryable: true,
      );
    } catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: 'unknown_tracking_sync_failure',
        message: _compactError(error),
        retryable: false,
      );
    } finally {
      if (sessionId != null && sessionId.isNotEmpty) {
        await _syncTaskDao.releaseSession(
          taskId: task.id,
          expectedSessionId: sessionId,
        );
      }
    }
  }

  Future<void> _processTrackingSessionTask({
    required SyncTaskRow task,
    required String? sessionId,
  }) async {
    final row = await _trackingSessionDao.getSessionById(task.entityId);
    if (row == null) {
      await _persistSuccessAndCompleteTask(
        task: task,
        sessionId: sessionId,
        applyLocalMutation: (_) async {},
      );
      return;
    }

    final idempotencyKey = _idempotencyKey(task.id, task.operation);
    final now = DateTime.now().toUtc();
    late final Map<String, dynamic> response;
    switch (task.operation) {
      case 'start':
        response = await _liveTrackingApi.startTracking(
          tripId: row.tripId,
          idempotencyKey: idempotencyKey,
          clientSessionId: row.clientSessionId,
          startedAt: row.startedAt ?? now,
          timezone: row.timezone,
          deviceContext: _decodeJsonMap(row.deviceContextJson),
        );
        break;
      case 'pause':
        response = await _liveTrackingApi.pauseTracking(
          tripId: row.tripId,
          idempotencyKey: idempotencyKey,
          clientEventId: _clientEventId(task.id, task.operation),
          pausedAt: row.pausedAt ?? now,
          sessionId: row.remoteSessionId,
        );
        break;
      case 'resume':
        response = await _liveTrackingApi.resumeTracking(
          tripId: row.tripId,
          idempotencyKey: idempotencyKey,
          clientEventId: _clientEventId(task.id, task.operation),
          resumedAt: row.resumedAt ?? now,
          sessionId: row.remoteSessionId,
        );
        break;
      case 'stop':
        response = await _liveTrackingApi.stopTracking(
          tripId: row.tripId,
          idempotencyKey: idempotencyKey,
          clientEventId: _clientEventId(task.id, task.operation),
          stoppedAt: row.endedAt ?? now,
          sessionId: row.remoteSessionId,
        );
        break;
      default:
        throw _TrackingSyncTerminalException(
          code: 'unsupported_tracking_session_operation',
          message: 'Unsupported tracking session operation: ${task.operation}',
        );
    }

    final state = (response['state'] as String?) ?? row.state;
    final remoteSessionId =
        response['session_id']?.toString() ?? row.remoteSessionId;
    await _persistSuccessAndCompleteTask(
      task: task,
      sessionId: sessionId,
      applyLocalMutation: (shouldMarkEntitySynced) async {
        await (_db.update(_db.trackingSessions)
              ..where((t) => t.id.equals(row.id)))
            .write(
          TrackingSessionsCompanion(
            remoteSessionId: Value(remoteSessionId),
            state: Value(state),
            startedAt:
                Value(_parseDateTime(response['started_at']) ?? row.startedAt),
            pausedAt:
                Value(_parseDateTime(response['paused_at']) ?? row.pausedAt),
            resumedAt:
                Value(_parseDateTime(response['resumed_at']) ?? row.resumedAt),
            endedAt: Value(_parseDateTime(response['ended_at']) ?? row.endedAt),
            abandonedAt: Value(
                _parseDateTime(response['abandoned_at']) ?? row.abandonedAt),
            lastPointAt: Value(
                _parseDateTime(response['last_point_at']) ?? row.lastPointAt),
            syncStatus: Value(shouldMarkEntitySynced ? 'synced' : 'pending'),
            serverUpdatedAt: Value(now),
            localUpdatedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      },
    );
  }

  Future<void> _processTrackingPointBatchTask({
    required SyncTaskRow task,
    required String? sessionId,
  }) async {
    final row = await _trackingPointBatchDao.getBatchById(task.entityId);
    if (row == null) {
      await _persistSuccessAndCompleteTask(
        task: task,
        sessionId: sessionId,
        applyLocalMutation: (_) async {},
      );
      return;
    }

    var remoteSessionId = row.remoteSessionId;
    if (remoteSessionId == null || remoteSessionId.isEmpty) {
      final session = await _trackingSessionDao.getSessionById(row.sessionId);
      remoteSessionId = session?.remoteSessionId;
    }

    if (remoteSessionId == null || remoteSessionId.isEmpty) {
      throw _TrackingSyncDeferredException(
        code: 'tracking_session_remote_id_missing',
        message:
            'Tracking point batch requires remote session id before upload.',
        dependsOnEntityType: SyncEntityTypes.trackingSession,
        dependsOnEntityId: row.sessionId,
      );
    }

    final points = _decodeJsonList(row.pointsJson)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final now = DateTime.now().toUtc();
    if (points.isEmpty) {
      await _persistSuccessAndCompleteTask(
        task: task,
        sessionId: sessionId,
        applyLocalMutation: (shouldMarkEntitySynced) async {
          await _applyPointBatchSuccessMutation(
            row: row,
            resolvedRemoteSessionId: remoteSessionId!,
            now: now,
            shouldMarkEntitySynced: shouldMarkEntitySynced,
          );
        },
      );
      return;
    }

    await _liveTrackingApi.uploadPointsBatch(
      tripId: row.tripId,
      idempotencyKey: _idempotencyKey(task.id, task.operation),
      sessionId: remoteSessionId,
      clientBatchId: row.clientBatchId,
      sentAt: DateTime.now().toUtc(),
      points: points,
    );

    await _persistSuccessAndCompleteTask(
      task: task,
      sessionId: sessionId,
      applyLocalMutation: (shouldMarkEntitySynced) async {
        await _applyPointBatchSuccessMutation(
          row: row,
          resolvedRemoteSessionId: remoteSessionId!,
          now: now,
          shouldMarkEntitySynced: shouldMarkEntitySynced,
        );
      },
    );
  }

  Future<void> _processCheckinDecisionTask({
    required SyncTaskRow task,
    required String? sessionId,
  }) async {
    final row = await _trackingCandidateDao.getCandidateById(task.entityId);
    if (row == null) {
      await _persistSuccessAndCompleteTask(
        task: task,
        sessionId: sessionId,
        applyLocalMutation: (_) async {},
      );
      return;
    }

    final now = DateTime.now().toUtc();
    final action = (row.actionType ?? task.operation).toLowerCase();
    final clientEventId =
        row.actionClientEventId ?? _clientEventId(task.id, action);
    late final Map<String, dynamic> response;
    switch (action) {
      case 'confirm':
        response = await _liveTrackingApi.confirmCheckin(
          candidateId: row.id,
          idempotencyKey: _idempotencyKey(task.id, action),
          clientEventId: clientEventId,
          confirmedAt: row.actionQueuedAt ?? now,
        );
        break;
      case 'reject':
        response = await _liveTrackingApi.rejectCheckin(
          candidateId: row.id,
          idempotencyKey: _idempotencyKey(task.id, action),
          clientEventId: clientEventId,
          rejectedAt: row.actionQueuedAt ?? now,
          reason: row.rejectedReason,
        );
        break;
      case 'snooze':
        response = await _liveTrackingApi.snoozeCheckin(
          candidateId: row.id,
          idempotencyKey: _idempotencyKey(task.id, action),
          clientEventId: clientEventId,
          snoozedUntil: row.snoozedUntil ?? now.add(const Duration(hours: 1)),
        );
        break;
      default:
        throw _TrackingSyncTerminalException(
          code: 'unsupported_checkin_decision_operation',
          message: 'Unsupported checkin decision action: $action',
        );
    }

    final candidatePayload = response['candidate'];
    var nextStatus = row.status;
    if (candidatePayload is Map) {
      final mapped = Map<String, dynamic>.from(candidatePayload);
      nextStatus = mapped['status']?.toString() ?? nextStatus;
    }

    await _persistSuccessAndCompleteTask(
      task: task,
      sessionId: sessionId,
      applyLocalMutation: (shouldMarkEntitySynced) async {
        if (!shouldMarkEntitySynced) {
          return;
        }
        await _trackingCandidateDao.markDecisionSynced(
          candidateId: row.id,
          status: nextStatus,
          syncedAt: now,
        );
      },
    );
  }

  Future<void> _processMomentTask({
    required SyncTaskRow task,
    required String? sessionId,
  }) async {
    final row = await _trackingMomentDao.getMomentById(task.entityId);
    if (row == null) {
      await _persistSuccessAndCompleteTask(
        task: task,
        sessionId: sessionId,
        applyLocalMutation: (_) async {},
      );
      return;
    }

    final operation = (row.pendingOperation ?? task.operation).toLowerCase();
    final now = DateTime.now().toUtc();
    final clientEventId =
        row.clientEventId ?? _clientEventId(task.id, operation);
    final location = _locationPayload(
      latitude: row.latitude,
      longitude: row.longitude,
    );
    final mediaRefs = _decodeJsonList(row.mediaRefsJson)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final extraPayload = _decodeJsonMap(row.extraPayloadJson);

    switch (operation) {
      case 'create':
        final response = await _liveTrackingApi.createMoment(
          tripId: row.tripId,
          idempotencyKey: _idempotencyKey(task.id, operation),
          clientEventId: clientEventId,
          capturedAt: row.capturedAt,
          note: row.note,
          location: location,
          mediaRefs: mediaRefs,
          linkedTripPlaceId: row.linkedTripPlaceId,
          extraPayload: extraPayload,
        );
        final responseId = response['id']?.toString();
        await _persistSuccessAndCompleteTask(
          task: task,
          sessionId: sessionId,
          applyLocalMutation: (shouldMarkEntitySynced) async {
            var localMomentId = row.id;
            if (responseId != null &&
                responseId.isNotEmpty &&
                responseId != row.id) {
              await _trackingMomentDao.replaceMomentId(
                oldMomentId: row.id,
                newMomentId: responseId,
              );
              final replacedTaskEntity = await _syncTaskDao.replaceTaskEntityId(
                taskId: task.id,
                previousEntityId: row.id,
                newEntityId: responseId,
                expectedSessionId: sessionId,
              );
              if (replacedTaskEntity != 1) {
                throw const _TrackingSyncRetryableException(
                  code: 'sync_task_entity_id_conflict',
                  message:
                      'Failed to remap sync task entity id after moment create.',
                );
              }
              localMomentId = responseId;
            }
            if (shouldMarkEntitySynced) {
              await _trackingMomentDao.markSynced(
                momentId: localMomentId,
                serverUpdatedAt: now,
              );
              return;
            }
            await (_db.update(_db.trackingMoments)
                  ..where((m) => m.id.equals(localMomentId)))
                .write(
              TrackingMomentsCompanion(
                syncStatus: const Value('pending'),
                localUpdatedAt: Value(now),
                updatedAt: Value(now),
              ),
            );
          },
        );
        break;
      case 'update':
        await _liveTrackingApi.updateMoment(
          momentId: row.id,
          idempotencyKey: _idempotencyKey(task.id, operation),
          clientEventId: clientEventId,
          capturedAt: row.capturedAt,
          note: row.note,
          location: location,
          mediaRefs: mediaRefs,
          linkedTripPlaceId: row.linkedTripPlaceId,
          extraPayload: extraPayload,
        );
        await _persistSuccessAndCompleteTask(
          task: task,
          sessionId: sessionId,
          applyLocalMutation: (shouldMarkEntitySynced) async {
            if (!shouldMarkEntitySynced) {
              return;
            }
            await _trackingMomentDao.markSynced(
              momentId: row.id,
              serverUpdatedAt: now,
            );
          },
        );
        break;
      default:
        throw _TrackingSyncTerminalException(
          code: 'unsupported_moment_operation',
          message: 'Unsupported moment operation: $operation',
        );
    }
  }

  Future<void> _persistSuccessAndCompleteTask({
    required SyncTaskRow task,
    required String? sessionId,
    required Future<void> Function(bool shouldMarkEntitySynced)
        applyLocalMutation,
  }) async {
    await _db.transaction(() async {
      final currentTask = await _syncTaskDao.getTaskById(task.id);
      if (currentTask == null) {
        throw const _TrackingSyncRetryableException(
          code: 'sync_task_missing',
          message: 'Tracking sync task disappeared before completion.',
        );
      }
      final shouldMarkEntitySynced = !currentTask.pendingRequeue;
      await applyLocalMutation(shouldMarkEntitySynced);

      final completed = await _syncTaskDao.markCompleted(
        taskId: task.id,
        expectedSessionId: sessionId,
      );
      if (completed != 1) {
        throw const _TrackingSyncRetryableException(
          code: 'sync_task_completion_conflict',
          message:
              'Failed to complete tracking sync task due to session mismatch.',
        );
      }
    });
  }

  Future<void> _applyPointBatchSuccessMutation({
    required TrackingPointBatchRow row,
    required String resolvedRemoteSessionId,
    required DateTime now,
    required bool shouldMarkEntitySynced,
  }) async {
    if (shouldMarkEntitySynced) {
      await _trackingPointBatchDao.markCompleted(
        batchId: row.id,
        serverUpdatedAt: now,
      );
      if (row.remoteSessionId == null || row.remoteSessionId!.isEmpty) {
        await (_db.update(_db.trackingPointBatches)
              ..where((b) => b.id.equals(row.id)))
            .write(
          TrackingPointBatchesCompanion(
            remoteSessionId: Value(resolvedRemoteSessionId),
          ),
        );
      }
      return;
    }

    await (_db.update(_db.trackingPointBatches)
          ..where((b) => b.id.equals(row.id)))
        .write(
      TrackingPointBatchesCompanion(
        remoteSessionId: Value(resolvedRemoteSessionId),
        status: const Value('queued'),
        syncStatus: const Value('pending'),
        retryCount: const Value(0),
        nextAttemptAt: const Value(null),
        lastError: const Value(null),
        workerSessionId: const Value(null),
        localUpdatedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _handleRecoverableFailure({
    required SyncTaskRow task,
    required String? sessionId,
    required String code,
    required String message,
    required bool retryable,
  }) async {
    final nextRetryCount = math.min(task.retryCount + 1, _maxRetryAttempts);
    final shouldRetry = retryable && task.retryCount < (_maxRetryAttempts - 1);
    if (shouldRetry) {
      await _syncTaskDao.markFailed(
        taskId: task.id,
        retryCount: nextRetryCount,
        errorCode: code,
        errorMessage: message,
        nextAttemptAt: DateTime.now().add(_backoffForRetry(nextRetryCount)),
        expectedSessionId: sessionId,
      );
      debugPrint(
        '[TRACKING_SYNC] retry taskId=${task.id} retry=$nextRetryCount code=$code',
      );
      return;
    }

    await _syncTaskDao.markBlocked(
      taskId: task.id,
      errorCode: code,
      errorMessage: message,
      expectedSessionId: sessionId,
      dependsOnEntityType: task.dependsOnEntityType,
      dependsOnEntityId: task.dependsOnEntityId,
    );
    debugPrint('[TRACKING_SYNC] blocked taskId=${task.id} code=$code');
  }

  Duration _backoffForRetry(int retryCount) {
    if (retryCount <= 1) {
      return _firstRetryDelay;
    }
    if (retryCount == 2) {
      return _secondRetryDelay;
    }
    return _secondRetryDelay * 2;
  }

  bool _isRetryableDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        return status == 429 || status >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  static String _dioErrorCode(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      return 'http_$statusCode';
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'connection_timeout';
      case DioExceptionType.sendTimeout:
        return 'send_timeout';
      case DioExceptionType.receiveTimeout:
        return 'receive_timeout';
      case DioExceptionType.connectionError:
        return 'connection_error';
      case DioExceptionType.badCertificate:
        return 'bad_certificate';
      case DioExceptionType.cancel:
        return 'cancelled';
      case DioExceptionType.badResponse:
        return 'bad_response';
      case DioExceptionType.unknown:
        return 'unknown_dio_error';
    }
  }

  String _idempotencyKey(String taskId, String operation) {
    return '$taskId:$operation';
  }

  String _clientEventId(String taskId, String operation) {
    return _uuid.v5(
      Namespace.url.value,
      'dora-live-tracking:$taskId:$operation',
    );
  }

  static Map<String, dynamic> _decodeJsonMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Ignore invalid payload and fallback to empty map.
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _decodeJsonList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded;
      }
    } catch (_) {
      // Ignore invalid payload and fallback to empty list.
    }
    return const <dynamic>[];
  }

  static DateTime? _parseDateTime(dynamic raw) {
    if (raw is! String || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw)?.toUtc();
  }

  static Map<String, dynamic>? _locationPayload({
    required double? latitude,
    required double? longitude,
  }) {
    if (latitude == null || longitude == null) {
      return null;
    }
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static String _newSessionId() =>
      'tracking-sync-${DateTime.now().microsecondsSinceEpoch}';

  static String _compactError(Object error) {
    final raw = error.toString().trim();
    return raw.length <= 512 ? raw : raw.substring(0, 512);
  }
}

class _TrackingSyncTerminalException implements Exception {
  const _TrackingSyncTerminalException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

class _TrackingSyncRetryableException implements Exception {
  const _TrackingSyncRetryableException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

class _TrackingSyncDeferredException implements Exception {
  const _TrackingSyncDeferredException({
    required this.code,
    required this.message,
    required this.dependsOnEntityType,
    required this.dependsOnEntityId,
  });

  final String code;
  final String message;
  final String dependsOnEntityType;
  final String dependsOnEntityId;
}
