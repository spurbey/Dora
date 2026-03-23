import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';

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

class LiveTrackingRuntimeRepository {
  LiveTrackingRuntimeRepository(
    AppDatabase db, {
    TrackingSessionDao? trackingSessionDao,
    TrackingPointBatchDao? trackingPointBatchDao,
    SyncTaskDao? syncTaskDao,
    LiveTrackingBatchingPolicy policy = const LiveTrackingBatchingPolicy(),
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingSessionDao = trackingSessionDao ?? TrackingSessionDao(db),
        _trackingPointBatchDao =
            trackingPointBatchDao ?? TrackingPointBatchDao(db),
        _syncTaskDao = syncTaskDao ?? SyncTaskDao(db),
        _policy = policy,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingSessionDao _trackingSessionDao;
  final TrackingPointBatchDao _trackingPointBatchDao;
  final SyncTaskDao _syncTaskDao;
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
    final existing =
        await _trackingSessionDao.getActiveOrPausedSessionForTrip(tripId);
    if (existing != null) {
      return existing;
    }

    final now = _now().toUtc();
    final sessionId = _uuid.v4();
    final clientSessionId = _uuid.v4();
    await _trackingSessionDao.upsertSession(
      TrackingSessionsCompanion.insert(
        id: sessionId,
        tripId: tripId,
        clientSessionId: clientSessionId,
        state: const Value('active'),
        timezone: Value(timezone),
        deviceContextJson: Value(_encodeJson(deviceContext ?? const {})),
        startedAt: Value(now),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _enqueueSessionTask(sessionId: sessionId, operation: 'start');
    final persisted = await _trackingSessionDao.getSessionById(sessionId);
    if (persisted == null) {
      throw StateError('Failed to persist tracking session: $sessionId');
    }
    return persisted;
  }

  Future<TrackingSessionRow?> pauseSession({
    required String tripId,
  }) async {
    final session =
        await _trackingSessionDao.getActiveOrPausedSessionForTrip(tripId);
    if (session == null) {
      return null;
    }
    if (session.state != 'active') {
      return session;
    }

    final now = _now().toUtc();
    await _trackingSessionDao.updateLifecycle(
      sessionId: session.id,
      state: 'paused',
      pausedAt: now,
    );
    await _enqueueSessionTask(sessionId: session.id, operation: 'pause');
    return _trackingSessionDao.getSessionById(session.id);
  }

  Future<TrackingSessionRow?> resumeSession({
    required String tripId,
  }) async {
    final session =
        await _trackingSessionDao.getActiveOrPausedSessionForTrip(tripId);
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
    await _trackingSessionDao.updateLifecycle(
      sessionId: session.id,
      state: 'active',
      resumedAt: now,
    );
    await _enqueueSessionTask(sessionId: session.id, operation: 'resume');
    return _trackingSessionDao.getSessionById(session.id);
  }

  Future<TrackingSessionRow?> stopSession({
    required String tripId,
  }) async {
    final session =
        await _trackingSessionDao.getActiveOrPausedSessionForTrip(tripId);
    if (session == null) {
      return null;
    }

    final now = _now().toUtc();
    await _trackingSessionDao.updateLifecycle(
      sessionId: session.id,
      state: 'ended',
      endedAt: now,
    );
    await _enqueueSessionTask(sessionId: session.id, operation: 'stop');
    return _trackingSessionDao.getSessionById(session.id);
  }

  Future<bool> ingestPoint({
    required String tripId,
    required String sessionId,
    required TrackingPointSample point,
  }) async {
    final session = await _trackingSessionDao.getSessionById(sessionId);
    if (session == null ||
        session.tripId != tripId ||
        session.state != 'active') {
      return false;
    }

    final recordedAt = point.recordedAt.toUtc();
    final mutableBatch =
        await _trackingPointBatchDao.getLatestMutableBatchForSession(sessionId);
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
  }

  Future<void> _enqueueSessionTask({
    required String sessionId,
    required String operation,
  }) {
    return _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.trackingSession,
      entityId: sessionId,
      operation: operation,
    );
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
