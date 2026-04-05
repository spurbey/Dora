import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:uuid/uuid.dart';

import 'package:dora/core/network/live_tracking_api.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/create/data/trip_repository.dart';

enum LiveTrackingRuntimeState {
  planned,
  active,
  paused,
  ended,
}

class LiveTrackingRuntimeSnapshot {
  const LiveTrackingRuntimeSnapshot({
    required this.tripId,
    required this.state,
    this.sessionId,
    this.remoteSessionId,
    this.startedAt,
    this.pausedAt,
    this.resumedAt,
    this.endedAt,
    this.lastPointAt,
  });

  final String tripId;
  final LiveTrackingRuntimeState state;
  final String? sessionId;
  final String? remoteSessionId;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? resumedAt;
  final DateTime? endedAt;
  final DateTime? lastPointAt;
}

class LiveTrackingBatchingPolicy {
  const LiveTrackingBatchingPolicy({
    this.maxPointsPerBatch = 25,
    this.maxBatchWindow = const Duration(seconds: 20),
    this.minPointCadence = const Duration(seconds: 4),
    this.minDistanceMeters = 8.0,
  });

  final int maxPointsPerBatch;
  final Duration maxBatchWindow;
  final Duration minPointCadence;
  final double minDistanceMeters;
}

class TrackingPointSample {
  const TrackingPointSample({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.speedMps,
  });

  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? speedMps;
}

class LiveTrackingCommandException implements Exception {
  const LiveTrackingCommandException({
    required this.code,
    required this.message,
    this.retryable = false,
  });

  final String code;
  final String message;
  final bool retryable;

  @override
  String toString() => 'LiveTrackingCommandException($code): $message';
}

class LiveTrackingRuntimeRepository {
  LiveTrackingRuntimeRepository(
    AppDatabase db, {
    TrackingSessionDao? trackingSessionDao,
    TrackingPointBatchDao? trackingPointBatchDao,
    SyncTaskDao? syncTaskDao,
    LiveTrackingApi? liveTrackingApi,
    Future<String> Function(String localTripId)? resolveRemoteTripId,
    Future<void> Function(String localTripId, {String? expectedServerTripId})?
        clearRemoteTripId,
    LiveTrackingBatchingPolicy policy = const LiveTrackingBatchingPolicy(),
    DateTime Function()? now,
    Uuid? uuid,
  })  : _db = db,
        _trackingSessionDao = trackingSessionDao ?? TrackingSessionDao(db),
        _trackingPointBatchDao =
            trackingPointBatchDao ?? TrackingPointBatchDao(db),
        _syncTaskDao = syncTaskDao ?? SyncTaskDao(db),
        _liveTrackingApi = liveTrackingApi,
        _resolveRemoteTripId = resolveRemoteTripId,
        _clearRemoteTripId = clearRemoteTripId,
        _policy = policy,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final TrackingSessionDao _trackingSessionDao;
  final TrackingPointBatchDao _trackingPointBatchDao;
  final SyncTaskDao _syncTaskDao;
  final LiveTrackingApi? _liveTrackingApi;
  final Future<String> Function(String localTripId)? _resolveRemoteTripId;
  final Future<void> Function(String localTripId,
      {String? expectedServerTripId})? _clearRemoteTripId;
  final LiveTrackingBatchingPolicy _policy;
  final DateTime Function() _now;
  final Uuid _uuid;

  Future<LiveTrackingRuntimeSnapshot> getRuntimeSnapshot(String tripId) async {
    final row = await _trackingSessionDao.getLatestSessionForTrip(tripId);
    return _snapshotFromRow(tripId: tripId, row: row);
  }

  Stream<LiveTrackingRuntimeSnapshot> watchRuntimeSnapshot(String tripId) {
    return _trackingSessionDao
        .watchLatestSessionForTrip(tripId)
        .map((row) => _snapshotFromRow(tripId: tripId, row: row));
  }

  Future<TrackingSessionRow> startSession({
    required String tripId,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    await _syncTaskDao.completeLegacyTrackingLifecycleTasksForTrip(
      tripId: tripId,
    );
    final existing = await _trackingSessionDao.getActiveOrPausedSessionForTrip(
      tripId,
    );
    final now = _now().toUtc();

    if (existing != null && _isNonEmpty(existing.remoteSessionId)) {
      return existing;
    }

    final sessionId = existing?.id ?? _uuid.v4();
    final clientSessionId = existing?.clientSessionId ?? _uuid.v4();
    final startedAt = existing?.startedAt ?? now;
    final effectiveTimezone = existing?.timezone ?? timezone;
    final effectiveDeviceContext = _mergeDeviceContext(
      existingJson: existing?.deviceContextJson,
      override: deviceContext,
    );

    final remoteTripId = await _resolveRemoteTripIdForCommand(tripId);
    final api = _requireLiveTrackingApi();
    final snapshot = await _executeLifecycleCommand(
      localTripId: tripId,
      remoteTripId: remoteTripId,
      commandName: 'start',
      request: (resolvedRemoteTripId) => api.startTracking(
        tripId: resolvedRemoteTripId,
        idempotencyKey: _idempotencyKey(operation: 'start'),
        clientSessionId: clientSessionId,
        startedAt: startedAt,
        timezone: effectiveTimezone,
        deviceContext: effectiveDeviceContext,
      ),
    );
    await _abandonOtherActiveSessions(keepSessionId: sessionId);

    return _upsertSessionSnapshot(
      localSessionId: sessionId,
      tripId: tripId,
      clientSessionId: clientSessionId,
      snapshot: snapshot,
      existing: existing,
      now: now,
    );
  }

  Future<TrackingSessionRow?> pauseSession({
    required String tripId,
  }) async {
    await _syncTaskDao.completeLegacyTrackingLifecycleTasksForTrip(
      tripId: tripId,
    );
    final session = await _trackingSessionDao.getActiveOrPausedSessionForTrip(
      tripId,
    );
    if (session == null) {
      return null;
    }
    if (session.state != 'active') {
      return session;
    }

    final now = _now().toUtc();
    final remoteTripId = await _resolveRemoteTripIdForCommand(tripId);
    final api = _requireLiveTrackingApi();
    final snapshot = await _executeLifecycleCommand(
      localTripId: tripId,
      remoteTripId: remoteTripId,
      commandName: 'pause',
      request: (resolvedRemoteTripId) => api.pauseTracking(
        tripId: resolvedRemoteTripId,
        idempotencyKey: _idempotencyKey(operation: 'pause'),
        clientEventId: _uuid.v4(),
        pausedAt: now,
        sessionId: _nonEmptyOrNull(session.remoteSessionId),
      ),
    );

    return _upsertSessionSnapshot(
      localSessionId: session.id,
      tripId: tripId,
      clientSessionId: session.clientSessionId,
      snapshot: snapshot,
      existing: session,
      now: now,
    );
  }

  Future<TrackingSessionRow?> resumeSession({
    required String tripId,
  }) async {
    await _syncTaskDao.completeLegacyTrackingLifecycleTasksForTrip(
      tripId: tripId,
    );
    final session = await _trackingSessionDao.getActiveOrPausedSessionForTrip(
      tripId,
    );
    if (session == null) {
      return null;
    }
    if (session.state == 'active') {
      return session;
    }
    if (session.state != 'paused') {
      return null;
    }

    final now = _now().toUtc();
    final remoteTripId = await _resolveRemoteTripIdForCommand(tripId);
    final api = _requireLiveTrackingApi();
    final snapshot = await _executeLifecycleCommand(
      localTripId: tripId,
      remoteTripId: remoteTripId,
      commandName: 'resume',
      request: (resolvedRemoteTripId) => api.resumeTracking(
        tripId: resolvedRemoteTripId,
        idempotencyKey: _idempotencyKey(operation: 'resume'),
        clientEventId: _uuid.v4(),
        resumedAt: now,
        sessionId: _nonEmptyOrNull(session.remoteSessionId),
      ),
    );
    await _abandonOtherActiveSessions(keepSessionId: session.id);

    return _upsertSessionSnapshot(
      localSessionId: session.id,
      tripId: tripId,
      clientSessionId: session.clientSessionId,
      snapshot: snapshot,
      existing: session,
      now: now,
    );
  }

  Future<TrackingSessionRow?> stopSession({
    required String tripId,
  }) async {
    await _syncTaskDao.completeLegacyTrackingLifecycleTasksForTrip(
      tripId: tripId,
    );
    final session = await _trackingSessionDao.getActiveOrPausedSessionForTrip(
      tripId,
    );
    if (session == null) {
      return null;
    }

    final now = _now().toUtc();
    final remoteTripId = await _resolveRemoteTripIdForCommand(tripId);
    final api = _requireLiveTrackingApi();
    final snapshot = await _executeLifecycleCommand(
      localTripId: tripId,
      remoteTripId: remoteTripId,
      commandName: 'stop',
      request: (resolvedRemoteTripId) => api.stopTracking(
        tripId: resolvedRemoteTripId,
        idempotencyKey: _idempotencyKey(operation: 'stop'),
        clientEventId: _uuid.v4(),
        stoppedAt: now,
        sessionId: _nonEmptyOrNull(session.remoteSessionId),
      ),
    );

    return _upsertSessionSnapshot(
      localSessionId: session.id,
      tripId: tripId,
      clientSessionId: session.clientSessionId,
      snapshot: snapshot,
      existing: session,
      now: now,
    );
  }

  Future<bool> ingestPoint({
    required String tripId,
    required String sessionId,
    required TrackingPointSample point,
  }) async {
    return _db.transaction(() async {
      final session = await _trackingSessionDao.getSessionById(sessionId);
      if (session == null ||
          session.tripId != tripId ||
          session.state != 'active') {
        return false;
      }

      final recordedAt = point.recordedAt.toUtc();
      final mutableBatch = await _trackingPointBatchDao
          .getLatestMutableBatchForSession(sessionId);
      final lastPoint =
          mutableBatch == null ? null : _lastPointInBatch(mutableBatch);
      if (_isDuplicatePoint(lastPoint: lastPoint, sample: point)) {
        return false;
      }

      final now = _now().toUtc();
      late final String targetBatchId;
      if (mutableBatch != null &&
          _canAppendToBatch(batch: mutableBatch, recordedAt: recordedAt)) {
        final points = _decodePointList(mutableBatch.pointsJson)
          ..add(_pointPayload(sample: point));
        final firstRecordedAt = mutableBatch.firstRecordedAt ?? recordedAt;
        final existingLast = mutableBatch.lastRecordedAt;
        final lastRecordedAt =
            existingLast == null || recordedAt.isAfter(existingLast)
                ? recordedAt
                : existingLast;
        await _trackingPointBatchDao.upsertBatch(
          TrackingPointBatchesCompanion.insert(
            id: mutableBatch.id,
            tripId: mutableBatch.tripId,
            sessionId: mutableBatch.sessionId,
            remoteSessionId: Value(mutableBatch.remoteSessionId),
            clientBatchId: mutableBatch.clientBatchId,
            firstRecordedAt: Value(firstRecordedAt),
            lastRecordedAt: Value(lastRecordedAt),
            pointCount: Value(points.length),
            pointsJson: Value(_encodeJson(points)),
            status: const Value('queued'),
            retryCount: const Value(0),
            nextAttemptAt: const Value(null),
            workerSessionId: const Value(null),
            lastError: const Value(null),
            syncStatus: const Value('pending'),
            localUpdatedAt: now,
            serverUpdatedAt: Value(mutableBatch.serverUpdatedAt),
            createdAt: mutableBatch.createdAt,
            updatedAt: now,
          ),
        );
        targetBatchId = mutableBatch.id;
      } else {
        final batchId = _uuid.v4();
        await _trackingPointBatchDao.upsertBatch(
          TrackingPointBatchesCompanion.insert(
            id: batchId,
            tripId: tripId,
            sessionId: session.id,
            remoteSessionId: Value(session.remoteSessionId),
            clientBatchId: _uuid.v4(),
            firstRecordedAt: Value(recordedAt),
            lastRecordedAt: Value(recordedAt),
            pointCount: const Value(1),
            pointsJson: Value(
              _encodeJson(<Map<String, dynamic>>[_pointPayload(sample: point)]),
            ),
            status: const Value('queued'),
            retryCount: const Value(0),
            nextAttemptAt: const Value(null),
            workerSessionId: const Value(null),
            lastError: const Value(null),
            syncStatus: const Value('pending'),
            localUpdatedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
        targetBatchId = batchId;
      }

      await _syncTaskDao.upsertQueuedTask(
        id: _uuid.v4(),
        entityType: SyncEntityTypes.trackingPointBatch,
        entityId: targetBatchId,
        operation: 'upload',
        dependsOnEntityType: SyncEntityTypes.trackingSession,
        dependsOnEntityId: session.id,
      );
      await _trackingSessionDao.markLastPointAt(
        sessionId: session.id,
        lastPointAt: recordedAt,
      );
      return true;
    });
  }

  Future<Map<String, dynamic>> _executeLifecycleCommand({
    required String localTripId,
    required String remoteTripId,
    required String commandName,
    required Future<Map<String, dynamic>> Function(String remoteTripId) request,
  }) async {
    try {
      return await request(remoteTripId);
    } on DioException catch (error) {
      if (_isTripNotFound(error)) {
        await _handleCommandTripIdentityMismatch(
          localTripId: localTripId,
          staleRemoteTripId: remoteTripId,
        );
        throw LiveTrackingCommandException(
          code: 'tracking_trip_identity_stale',
          message:
              'Trip identity is stale on server. Sync trip, then retry $commandName.',
          retryable: true,
        );
      }
      throw _mapLifecycleDioException(error, commandName: commandName);
    }
  }

  Future<String> _resolveRemoteTripIdForCommand(String localTripId) async {
    final resolver = _resolveRemoteTripId;
    if (resolver == null) {
      throw const LiveTrackingCommandException(
        code: 'tracking_trip_identity_missing',
        message: 'Sync this trip first before starting live tracking.',
        retryable: true,
      );
    }
    try {
      return await resolver(localTripId);
    } on TripIdentityException catch (error) {
      throw LiveTrackingCommandException(
        code: 'tracking_trip_identity_missing',
        message:
            'This trip is not synced to server yet. Sync trip, then retry.',
        retryable: error.retryable,
      );
    } on StateError catch (_) {
      throw const LiveTrackingCommandException(
        code: 'tracking_trip_identity_missing',
        message: 'Sync this trip first before starting live tracking.',
        retryable: true,
      );
    }
  }

  LiveTrackingApi _requireLiveTrackingApi() {
    final api = _liveTrackingApi;
    if (api == null) {
      throw const LiveTrackingCommandException(
        code: 'tracking_api_unavailable',
        message: 'Live tracking service is unavailable. Please try again.',
        retryable: true,
      );
    }
    return api;
  }

  Future<void> _handleCommandTripIdentityMismatch({
    required String localTripId,
    required String staleRemoteTripId,
  }) async {
    final clearRemoteTripId = _clearRemoteTripId;
    if (clearRemoteTripId != null) {
      await clearRemoteTripId(
        localTripId,
        expectedServerTripId: staleRemoteTripId,
      );
    } else {
      await (_db.update(_db.trips)..where((t) => t.id.equals(localTripId)))
          .write(
        const TripsCompanion(
          serverTripId: Value(null),
        ),
      );
    }
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.trip,
      entityId: localTripId,
      operation: 'create',
    );
    await _syncTaskDao.requeueIdentityBlockedTasks(tripId: localTripId);
  }

  bool _isTripNotFound(DioException error) {
    if (error.response?.statusCode != 404) {
      return false;
    }
    final detail = _dioResponseDetail(error.response?.data);
    return detail.toLowerCase().contains('trip not found');
  }

  LiveTrackingCommandException _mapLifecycleDioException(
    DioException error, {
    required String commandName,
  }) {
    final statusCode = error.response?.statusCode;
    final detail = _dioResponseDetail(error.response?.data);
    final code =
        statusCode == null ? 'tracking_network_error' : 'http_$statusCode';
    final retryable = statusCode == null ||
        statusCode == 408 ||
        statusCode == 429 ||
        statusCode >= 500;
    return LiveTrackingCommandException(
      code: code,
      message: detail.isEmpty
          ? 'Unable to $commandName tracking right now. Please retry.'
          : detail,
      retryable: retryable,
    );
  }

  String _dioResponseDetail(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return '';
  }

  Future<TrackingSessionRow> _upsertSessionSnapshot({
    required String localSessionId,
    required String tripId,
    required String clientSessionId,
    required Map<String, dynamic> snapshot,
    required TrackingSessionRow? existing,
    required DateTime now,
  }) async {
    final remoteSessionId =
        _asString(snapshot['session_id']) ?? existing?.remoteSessionId;
    final state = _asString(snapshot['state']) ?? existing?.state ?? 'planned';
    final startedAt = _parseDateTime(snapshot['started_at']) ??
        existing?.startedAt ??
        (state == 'active' ? now : null);
    final pausedAt =
        _parseDateTime(snapshot['paused_at']) ?? existing?.pausedAt;
    final resumedAt =
        _parseDateTime(snapshot['resumed_at']) ?? existing?.resumedAt;
    final endedAt = _parseDateTime(snapshot['ended_at']) ?? existing?.endedAt;
    final abandonedAt =
        _parseDateTime(snapshot['abandoned_at']) ?? existing?.abandonedAt;
    final lastPointAt =
        _parseDateTime(snapshot['last_point_at']) ?? existing?.lastPointAt;
    final timezone = _asString(snapshot['timezone']) ?? existing?.timezone;
    final deviceContext = _coerceJsonMap(snapshot['device_context']) ??
        _coerceJsonMapFromString(existing?.deviceContextJson) ??
        const <String, dynamic>{};
    final createdAt = existing?.createdAt ?? now;

    await _trackingSessionDao.upsertSession(
      TrackingSessionsCompanion.insert(
        id: localSessionId,
        tripId: tripId,
        remoteSessionId: Value(remoteSessionId),
        clientSessionId: existing?.clientSessionId ?? clientSessionId,
        state: Value(state),
        timezone: Value(timezone),
        deviceContextJson: Value(_encodeJson(deviceContext)),
        startedAt: Value(startedAt),
        pausedAt: Value(pausedAt),
        resumedAt: Value(resumedAt),
        endedAt: Value(endedAt),
        abandonedAt: Value(abandonedAt),
        lastPointAt: Value(lastPointAt),
        syncStatus: const Value('synced'),
        localUpdatedAt: now,
        serverUpdatedAt: Value(now),
        createdAt: createdAt,
        updatedAt: now,
      ),
    );

    final persisted = await _trackingSessionDao.getSessionById(localSessionId);
    if (persisted == null) {
      throw StateError('Failed to persist tracking session: $localSessionId');
    }
    return persisted;
  }

  Map<String, dynamic> _mergeDeviceContext({
    required String? existingJson,
    required Map<String, dynamic>? override,
  }) {
    final merged = <String, dynamic>{};
    final existing = _coerceJsonMapFromString(existingJson);
    if (existing != null) {
      merged.addAll(existing);
    }
    if (override != null && override.isNotEmpty) {
      merged.addAll(override);
    }
    return merged;
  }

  String _idempotencyKey({required String operation}) {
    return 'tracking:$operation:${_uuid.v4()}';
  }

  LiveTrackingRuntimeSnapshot _snapshotFromRow({
    required String tripId,
    required TrackingSessionRow? row,
  }) {
    if (row == null) {
      return LiveTrackingRuntimeSnapshot(
        tripId: tripId,
        state: LiveTrackingRuntimeState.planned,
      );
    }
    return LiveTrackingRuntimeSnapshot(
      tripId: tripId,
      state: _runtimeStateFromRow(row),
      sessionId: row.id,
      remoteSessionId: row.remoteSessionId,
      startedAt: row.startedAt,
      pausedAt: row.pausedAt,
      resumedAt: row.resumedAt,
      endedAt: row.endedAt ?? row.abandonedAt,
      lastPointAt: row.lastPointAt,
    );
  }

  Future<void> _abandonOtherActiveSessions({
    required String keepSessionId,
  }) async {
    final activeSessions =
        await _trackingSessionDao.getSessionsByStates(const {'active'});
    if (activeSessions.length > 1 ||
        (activeSessions.length == 1 &&
            activeSessions.first.id != keepSessionId)) {
      debugPrint(
        '[TRACKING_RUNTIME] invariant_violation active_sessions='
        '${activeSessions.length} keep=$keepSessionId',
      );
    }
    final abandonedAt = _now().toUtc();
    for (final row in activeSessions) {
      if (row.id == keepSessionId) {
        continue;
      }
      await _trackingSessionDao.updateLifecycle(
        sessionId: row.id,
        state: 'abandoned',
        abandonedAt: abandonedAt,
      );
    }
  }

  LiveTrackingRuntimeState _runtimeStateFromRow(TrackingSessionRow row) {
    switch (row.state) {
      case 'active':
        return LiveTrackingRuntimeState.active;
      case 'paused':
        return LiveTrackingRuntimeState.paused;
      case 'ended':
      case 'abandoned':
        return LiveTrackingRuntimeState.ended;
      case 'planned':
      default:
        return LiveTrackingRuntimeState.planned;
    }
  }

  bool _canAppendToBatch({
    required TrackingPointBatchRow batch,
    required DateTime recordedAt,
  }) {
    if (batch.pointCount >= _policy.maxPointsPerBatch) {
      return false;
    }
    final first = batch.firstRecordedAt;
    if (first == null) {
      return true;
    }
    if (recordedAt.isBefore(first)) {
      return false;
    }
    return recordedAt.difference(first) <= _policy.maxBatchWindow;
  }

  bool _isDuplicatePoint({
    required _StoredPoint? lastPoint,
    required TrackingPointSample sample,
  }) {
    if (lastPoint == null) {
      return false;
    }
    final recordedAt = sample.recordedAt.toUtc();
    final cadence = recordedAt.difference(lastPoint.recordedAt).abs();
    if (cadence > _policy.minPointCadence) {
      return false;
    }
    final distance = _distanceMeters(
      lat1: lastPoint.latitude,
      lon1: lastPoint.longitude,
      lat2: sample.latitude,
      lon2: sample.longitude,
    );
    return distance <= _policy.minDistanceMeters;
  }

  _StoredPoint? _lastPointInBatch(TrackingPointBatchRow batch) {
    final points = _decodePointList(batch.pointsJson);
    if (points.isEmpty) {
      return null;
    }
    final raw = points.last;
    final recordedAt = _parseDateTime(raw['recorded_at']);
    final latitude = _asDouble(raw['latitude']);
    final longitude = _asDouble(raw['longitude']);
    if (recordedAt == null || latitude == null || longitude == null) {
      return null;
    }
    return _StoredPoint(
      recordedAt: recordedAt,
      latitude: latitude,
      longitude: longitude,
    );
  }

  List<Map<String, dynamic>> _decodePointList(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }
      return decoded
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList(growable: true);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Map<String, dynamic> _pointPayload({
    required TrackingPointSample sample,
  }) {
    return <String, dynamic>{
      'point_id': _uuid.v4(),
      'recorded_at': sample.recordedAt.toUtc().toIso8601String(),
      'latitude': sample.latitude,
      'longitude': sample.longitude,
      if (sample.accuracyMeters != null) 'accuracy_m': sample.accuracyMeters,
      if (sample.speedMps != null) 'speed_mps': sample.speedMps,
    };
  }

  static double _distanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _radians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  static bool _isNonEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String? _nonEmptyOrNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static String? _asString(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    final trimmed = value.toString().trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Map<String, dynamic>? _coerceJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static Map<String, dynamic>? _coerceJsonMapFromString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(value);
      return _coerceJsonMap(decoded);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  static double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static String _encodeJson(Object value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      if (value is List) {
        return '[]';
      }
      if (value is Map) {
        return '{}';
      }
      return 'null';
    }
  }
}

class _StoredPoint {
  const _StoredPoint({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
  });

  final DateTime recordedAt;
  final double latitude;
  final double longitude;
}
