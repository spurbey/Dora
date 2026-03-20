import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/entity_sync_receipt.dart';
import 'package:dora/features/create/data/place_repository.dart';
import 'package:dora/features/create/data/route_repository.dart';
import 'package:dora/features/create/data/trip_repository.dart';

class EntitySyncWorker {
  EntitySyncWorker({
    required AppDatabase db,
    required SyncTaskDao syncTaskDao,
    required TripRepository tripRepository,
    required PlaceRepository placeRepository,
    required RouteRepository routeRepository,
    int maxConcurrency = 2,
  })  : _db = db,
        _syncTaskDao = syncTaskDao,
        _tripRepository = tripRepository,
        _placeRepository = placeRepository,
        _routeRepository = routeRepository,
        _maxConcurrency = maxConcurrency;

  final AppDatabase _db;
  final SyncTaskDao _syncTaskDao;
  final TripRepository _tripRepository;
  final PlaceRepository _placeRepository;
  final RouteRepository _routeRepository;
  final int _maxConcurrency;

  static const int _maxRetryAttempts = 3;
  static const Duration _firstRetryDelay = Duration(seconds: 15);
  static const Duration _secondRetryDelay = Duration(seconds: 60);

  bool _isRunning = false;

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
        );
        if (claimed.isEmpty) {
          break;
        }
        debugPrint(
            '[ENTITY_SYNC] claimed=${claimed.length} session=$sessionId');
        await Future.wait(claimed.map(_processClaimedTask), eagerError: false);
      }
    } finally {
      _isRunning = false;
    }
  }

  Future<void> _processClaimedTask(SyncTaskRow task) async {
    final sessionId = task.workerSessionId;
    try {
      EntitySyncReceipt? receipt;
      switch (task.entityType) {
        case 'trip':
          receipt = await _processTripTask(task);
          break;
        case 'place':
          receipt = await _processPlaceTask(task);
          break;
        case 'route':
          receipt = await _processRouteTask(task);
          break;
        default:
          throw _EntitySyncTerminalException(
            code: 'unsupported_entity_type',
            message: 'Unsupported sync entity type: ${task.entityType}',
          );
      }

      await _persistReceiptAndCompleteTask(
        task: task,
        sessionId: sessionId,
        receipt: receipt,
      );
      debugPrint(
        '[ENTITY_SYNC] success entity=${task.entityType} '
        'entityId=${task.entityId} taskId=${task.id}',
      );
    } on _EntitySyncTerminalException catch (error) {
      await _syncTaskDao.markBlocked(
        taskId: task.id,
        errorCode: error.code,
        errorMessage: error.message,
        expectedSessionId: sessionId,
        dependsOnEntityType: task.dependsOnEntityType,
        dependsOnEntityId: task.dependsOnEntityId,
      );
      debugPrint(
          '[ENTITY_SYNC] blocked taskId=${task.id} reason=${error.code}');
    } on _EntitySyncRetryableException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: error.code,
        message: error.message,
        retryable: true,
      );
    } on TripIdentityException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: 'trip_identity_failure',
        message: error.message,
        retryable: error.retryable,
      );
    } on PlaceIdentityException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: 'place_identity_failure',
        message: error.message,
        retryable: error.retryable,
      );
    } on RouteIdentityException catch (error) {
      await _handleRecoverableFailure(
        task: task,
        sessionId: sessionId,
        code: 'route_identity_failure',
        message: error.message,
        retryable: error.retryable,
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
        code: 'unknown_sync_failure',
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

  Future<EntitySyncReceipt?> _processTripTask(SyncTaskRow task) async {
    switch (task.operation) {
      case 'create':
      case 'update':
        return _tripRepository.syncTripForTask(
          task.entityId,
          operation: task.operation,
        );
      case 'delete':
        final remoteTripId = task.remoteEntityId;
        if (remoteTripId == null || remoteTripId.isEmpty) {
          return null;
        }
        await _tripRepository.deleteRemoteTripById(remoteTripId);
        return null;
      default:
        throw _EntitySyncTerminalException(
          code: 'unsupported_trip_operation',
          message: 'Unsupported trip sync operation: ${task.operation}',
        );
    }
  }

  Future<EntitySyncReceipt?> _processPlaceTask(SyncTaskRow task) async {
    switch (task.operation) {
      case 'create':
      case 'update':
        return _placeRepository.syncPlaceForTask(
          task.entityId,
          operation: task.operation,
        );
      case 'delete':
        final remotePlaceId = task.remoteEntityId;
        if (remotePlaceId == null || remotePlaceId.isEmpty) {
          return null;
        }
        await _placeRepository.deleteRemotePlaceById(remotePlaceId);
        return null;
      default:
        throw _EntitySyncTerminalException(
          code: 'unsupported_place_operation',
          message: 'Unsupported place sync operation: ${task.operation}',
        );
    }
  }

  Future<EntitySyncReceipt?> _processRouteTask(SyncTaskRow task) async {
    switch (task.operation) {
      case 'create':
      case 'update':
        return _routeRepository.syncRouteForTask(
          task.entityId,
          operation: task.operation,
        );
      case 'delete':
        final remoteRouteId = task.remoteEntityId;
        if (remoteRouteId == null || remoteRouteId.isEmpty) {
          return null;
        }
        await _routeRepository.deleteRemoteRouteById(remoteRouteId);
        return null;
      default:
        throw _EntitySyncTerminalException(
          code: 'unsupported_route_operation',
          message: 'Unsupported route sync operation: ${task.operation}',
        );
    }
  }

  Future<void> _persistReceiptAndCompleteTask({
    required SyncTaskRow task,
    required String? sessionId,
    required EntitySyncReceipt? receipt,
  }) async {
    if (receipt == null) {
      final completed = await _syncTaskDao.markCompleted(
        taskId: task.id,
        expectedSessionId: sessionId,
      );
      if (completed != 1) {
        throw const _EntitySyncRetryableException(
          code: 'sync_task_completion_conflict',
          message: 'Failed to complete sync task due to session mismatch.',
        );
      }
      return;
    }

    await _db.transaction(() async {
      final currentTask = await _syncTaskDao.getTaskById(task.id);
      if (currentTask == null) {
        throw const _EntitySyncRetryableException(
          code: 'sync_task_missing',
          message: 'Sync task disappeared before completion.',
        );
      }

      final shouldMarkEntitySynced = !currentTask.pendingRequeue;
      await _applyReceiptToLocalRows(
        receipt: receipt,
        shouldMarkEntitySynced: shouldMarkEntitySynced,
      );

      final completed = await _syncTaskDao.markCompleted(
        taskId: task.id,
        expectedSessionId: sessionId,
      );
      if (completed != 1) {
        throw const _EntitySyncRetryableException(
          code: 'sync_task_completion_conflict',
          message: 'Failed to complete sync task due to session mismatch.',
        );
      }
    });
  }

  Future<void> _applyReceiptToLocalRows({
    required EntitySyncReceipt receipt,
    required bool shouldMarkEntitySynced,
  }) async {
    switch (receipt.entityType) {
      case 'trip':
        await _applyTripReceipt(
          receipt: receipt,
          shouldMarkEntitySynced: shouldMarkEntitySynced,
        );
        return;
      case 'place':
        await _applyPlaceReceipt(
          receipt: receipt,
          shouldMarkEntitySynced: shouldMarkEntitySynced,
        );
        return;
      case 'route':
        await _applyRouteReceipt(
          receipt: receipt,
          shouldMarkEntitySynced: shouldMarkEntitySynced,
        );
        return;
      default:
        throw _EntitySyncTerminalException(
          code: 'unsupported_receipt_entity_type',
          message: 'Unsupported receipt entity type: ${receipt.entityType}',
        );
    }
  }

  Future<void> _applyTripReceipt({
    required EntitySyncReceipt receipt,
    required bool shouldMarkEntitySynced,
  }) async {
    final syncStatus = shouldMarkEntitySynced ? 'synced' : 'pending';
    await (_db.update(_db.trips)
          ..where((t) => t.id.equals(receipt.localEntityId)))
        .write(
      TripsCompanion(
        serverTripId: Value(receipt.remoteEntityId),
        serverUpdatedAt: Value(receipt.serverUpdatedAt),
        syncStatus: Value(syncStatus),
      ),
    );
    await (_db.update(_db.userTrips)
          ..where((t) => t.id.equals(receipt.localEntityId)))
        .write(
      UserTripsCompanion(
        serverUpdatedAt: Value(receipt.serverUpdatedAt),
        syncStatus: Value(syncStatus),
      ),
    );
  }

  Future<void> _applyPlaceReceipt({
    required EntitySyncReceipt receipt,
    required bool shouldMarkEntitySynced,
  }) async {
    final syncStatus = shouldMarkEntitySynced ? 'synced' : 'pending';
    await (_db.update(_db.places)
          ..where((p) => p.id.equals(receipt.localEntityId)))
        .write(
      PlacesCompanion(
        serverPlaceId: Value(receipt.remoteEntityId),
        serverUpdatedAt: Value(receipt.serverUpdatedAt),
        syncStatus: Value(syncStatus),
      ),
    );
  }

  Future<void> _applyRouteReceipt({
    required EntitySyncReceipt receipt,
    required bool shouldMarkEntitySynced,
  }) async {
    final syncStatus = shouldMarkEntitySynced ? 'synced' : 'pending';
    await (_db.update(_db.routes)
          ..where((r) => r.id.equals(receipt.localEntityId)))
        .write(
      RoutesCompanion(
        serverRouteId: Value(receipt.remoteEntityId),
        serverUpdatedAt: Value(receipt.serverUpdatedAt),
        syncStatus: Value(syncStatus),
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
        '[ENTITY_SYNC] retry taskId=${task.id} retry=$nextRetryCount code=$code',
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
    debugPrint('[ENTITY_SYNC] blocked taskId=${task.id} code=$code');
  }

  Duration _backoffForRetry(int retryCount) {
    if (retryCount <= 1) {
      return _firstRetryDelay;
    }
    return _secondRetryDelay;
  }

  bool _isRetryableDio(DioException error) {
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

  String _dioErrorCode(DioException error) {
    final status = error.response?.statusCode;
    if (status == null) {
      return 'network_error';
    }
    return 'http_$status';
  }

  String _compactError(Object error) {
    final message = error.toString().trim();
    if (message.length <= 500) {
      return message;
    }
    return message.substring(0, 500);
  }

  String _newSessionId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'sync-$now';
  }
}

class _EntitySyncTerminalException implements Exception {
  const _EntitySyncTerminalException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}

class _EntitySyncRetryableException implements Exception {
  const _EntitySyncRetryableException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}
