import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart'
    show
        LiveTrackingRuntimeSnapshot,
        LiveTrackingRuntimeState,
        TrackingPointSample;
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_command_api.dart';

class V2LiveTrackingCommandException implements Exception {
  const V2LiveTrackingCommandException({
    required this.code,
    required this.message,
    this.retryable = false,
  });

  final String code;
  final String message;
  final bool retryable;

  @override
  String toString() => 'V2LiveTrackingCommandException($code): $message';
}

class V2LiveTrackingBatchingPolicy {
  const V2LiveTrackingBatchingPolicy({
    this.minPointCadence = const Duration(seconds: 4),
    this.minDistanceMeters = 8.0,
  });

  final Duration minPointCadence;
  final double minDistanceMeters;
}

class V2LiveTrackingRuntimeRepository {
  V2LiveTrackingRuntimeRepository({
    required V2SessionJournalRepository sessionRepository,
    required V2RoutePointJournalRepository routePointRepository,
    required V2CommandApi commandApi,
    required Future<String> Function(String localTripId) resolveRemoteTripId,
    DateTime Function()? now,
    Uuid? uuid,
    V2LiveTrackingBatchingPolicy policy = const V2LiveTrackingBatchingPolicy(),
  })  : _sessionRepository = sessionRepository,
        _routePointRepository = routePointRepository,
        _commandApi = commandApi,
        _resolveRemoteTripId = resolveRemoteTripId,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid(),
        _policy = policy;

  final V2SessionJournalRepository _sessionRepository;
  final V2RoutePointJournalRepository _routePointRepository;
  final V2CommandApi _commandApi;
  final Future<String> Function(String localTripId) _resolveRemoteTripId;
  final DateTime Function() _now;
  final Uuid _uuid;
  final V2LiveTrackingBatchingPolicy _policy;

  final Map<String, String> _remoteSessionIdsByClientSessionId =
      <String, String>{};
  final Map<String, _AcceptedPoint> _lastAcceptedPointBySession =
      <String, _AcceptedPoint>{};
  final Map<String, int> _pointSeqBySession = <String, int>{};

  Stream<LiveTrackingRuntimeSnapshot> watchRuntimeSnapshot(String tripId) {
    return _sessionRepository.watchLatestSessionForTrip(tripId).map(
          (row) => _snapshotFromRow(tripId: tripId, row: row),
        );
  }

  Future<LiveTrackingRuntimeSnapshot> getRuntimeSnapshot(String tripId) async {
    final row = await _sessionRepository.getLatestSessionForTrip(tripId);
    return _snapshotFromRow(tripId: tripId, row: row);
  }

  Future<SessionJournalRow> startSession({
    required String tripId,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    final existing =
        await _sessionRepository.getActiveOrPausedSessionForTrip(tripId);
    if (existing != null) {
      return existing;
    }

    final now = _now().toUtc();
    final clientSessionId = _uuid.v4();
    final sessionSeq = await _nextSessionSeq(tripId);
    final remoteTripId = await _resolveRemoteTripIdForStart(tripId);
    const startRequestSeq = 1;
    final idempotencyKey = 'start:$tripId:$clientSessionId:$startRequestSeq';

    V2StartCommandResult startResult;
    try {
      startResult = await _commandApi.start(
        remoteTripId: remoteTripId,
        idempotencyKey: idempotencyKey,
        clientSessionId: clientSessionId,
        startedAt: now,
        timezone: timezone,
        deviceContext: deviceContext,
      );
    } catch (error) {
      throw _mapStartFailure(error);
    }

    await _sessionRepository.upsertSession(
      sessionId: clientSessionId,
      tripLocalId: tripId,
      serverTripId: remoteTripId,
      controlState: 'active',
      stopServerPending: 0,
      startAckAt: now,
      startedAt: startResult.startedAt ?? now,
      stopClientEventId: null,
      sealVersion: 0,
      startRequestSeq: startRequestSeq,
      sessionSeq: sessionSeq,
      deviceId: _deviceIdFromContext(deviceContext),
      createdAt: now,
      updatedAt: now,
    );

    await _sessionRepository.upsertActivityWindow(
      windowId: _uuid.v4(),
      sessionId: clientSessionId,
      tripLocalId: tripId,
      windowKind: 'active',
      startedAt: startResult.startedAt ?? now,
      windowSeq: 1,
    );

    _remoteSessionIdsByClientSessionId[clientSessionId] =
        startResult.remoteSessionId;

    final created = await _sessionRepository.getSessionById(clientSessionId);
    if (created == null) {
      throw const V2LiveTrackingCommandException(
        code: 'session_create_failed',
        message: 'Failed to activate local session after start.',
      );
    }
    return created;
  }

  Future<SessionJournalRow?> pauseSession({
    required String tripId,
  }) async {
    final session =
        await _sessionRepository.getActiveOrPausedSessionForTrip(tripId);
    if (session == null) {
      return null;
    }
    if (session.controlState == 'paused') {
      return session;
    }
    if (session.controlState != 'active') {
      return null;
    }
    final now = _now().toUtc();
    await _closeLatestOpenWindow(session: session, endedAt: now);
    await _sessionRepository.upsertActivityWindow(
      windowId: _uuid.v4(),
      sessionId: session.sessionId,
      tripLocalId: session.tripLocalId,
      windowKind: 'paused',
      startedAt: now,
      windowSeq: await _nextWindowSeq(session.sessionId),
    );
    await _sessionRepository.upsertSession(
      sessionId: session.sessionId,
      tripLocalId: session.tripLocalId,
      serverTripId: session.serverTripId,
      controlState: 'paused',
      stopServerPending: session.stopServerPending,
      startAckAt: session.startAckAt,
      stopAckAt: session.stopAckAt,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      stopClientEventId: session.stopClientEventId,
      sealVersion: session.sealVersion,
      startRequestSeq: session.startRequestSeq,
      sessionSeq: session.sessionSeq,
      deviceId: session.deviceId,
      createdAt: session.createdAt,
      updatedAt: now,
    );
    return _sessionRepository.getSessionById(session.sessionId);
  }

  Future<SessionJournalRow?> resumeSession({
    required String tripId,
  }) async {
    final session =
        await _sessionRepository.getActiveOrPausedSessionForTrip(tripId);
    if (session == null) {
      return null;
    }
    if (session.controlState == 'active') {
      return session;
    }
    if (session.controlState != 'paused') {
      return null;
    }
    final now = _now().toUtc();
    await _closeLatestOpenWindow(session: session, endedAt: now);
    await _sessionRepository.upsertActivityWindow(
      windowId: _uuid.v4(),
      sessionId: session.sessionId,
      tripLocalId: session.tripLocalId,
      windowKind: 'active',
      startedAt: now,
      windowSeq: await _nextWindowSeq(session.sessionId),
    );
    await _sessionRepository.upsertSession(
      sessionId: session.sessionId,
      tripLocalId: session.tripLocalId,
      serverTripId: session.serverTripId,
      controlState: 'active',
      stopServerPending: session.stopServerPending,
      startAckAt: session.startAckAt,
      stopAckAt: session.stopAckAt,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      stopClientEventId: session.stopClientEventId,
      sealVersion: session.sealVersion,
      startRequestSeq: session.startRequestSeq,
      sessionSeq: session.sessionSeq,
      deviceId: session.deviceId,
      createdAt: session.createdAt,
      updatedAt: now,
    );
    return _sessionRepository.getSessionById(session.sessionId);
  }

  Future<SessionJournalRow?> stopSession({
    required String tripId,
  }) async {
    final session =
        await _sessionRepository.getActiveOrPausedSessionForTrip(tripId);
    if (session == null) {
      return null;
    }
    final now = _now().toUtc();
    final nextSealVersion = session.sealVersion + 1;
    await _closeLatestOpenWindow(session: session, endedAt: now);
    await _sessionRepository.upsertSession(
      sessionId: session.sessionId,
      tripLocalId: session.tripLocalId,
      serverTripId: session.serverTripId,
      controlState: 'sealed',
      stopServerPending: session.stopServerPending,
      startAckAt: session.startAckAt,
      stopAckAt: session.stopAckAt,
      startedAt: session.startedAt,
      endedAt: now,
      stopClientEventId: session.stopClientEventId,
      sealVersion: nextSealVersion,
      startRequestSeq: session.startRequestSeq,
      sessionSeq: session.sessionSeq,
      deviceId: session.deviceId,
      createdAt: session.createdAt,
      updatedAt: now,
    );

    var stopAckAt = session.stopAckAt;
    var stopServerPending = 0;
    // Lock stop idempotency to the current seal-version attempt.
    // Each stop increments sealVersion, so a new stop client event id is created.
    final stopClientEventId = _uuid.v4();
    String? remoteTripId = session.serverTripId;
    try {
      remoteTripId ??= await _resolveRemoteTripIdForStart(tripId);
      final idempotencyKey =
          'stop:$tripId:${session.sessionId}:$nextSealVersion';
      await _commandApi.stop(
        remoteTripId: remoteTripId,
        idempotencyKey: idempotencyKey,
        clientSessionId: session.sessionId,
        sealVersion: nextSealVersion,
        stopClientEventId: stopClientEventId,
        stoppedAt: now,
      );
      stopAckAt = now;
    } catch (_) {
      stopServerPending = 1;
    }

    await _sessionRepository.upsertSession(
      sessionId: session.sessionId,
      tripLocalId: session.tripLocalId,
      serverTripId: remoteTripId ?? session.serverTripId,
      controlState: 'sealed',
      stopServerPending: stopServerPending,
      startAckAt: session.startAckAt,
      stopAckAt: stopAckAt,
      startedAt: session.startedAt,
      endedAt: now,
      stopClientEventId: stopClientEventId,
      sealVersion: nextSealVersion,
      startRequestSeq: session.startRequestSeq,
      sessionSeq: session.sessionSeq,
      deviceId: session.deviceId,
      createdAt: session.createdAt,
      updatedAt: _now().toUtc(),
    );

    _lastAcceptedPointBySession.remove(session.sessionId);
    _pointSeqBySession.remove(session.sessionId);
    return _sessionRepository.getSessionById(session.sessionId);
  }

  Future<bool> ingestPoint({
    required String tripId,
    required String sessionId,
    required TrackingPointSample point,
  }) async {
    final session = await _sessionRepository.getSessionById(sessionId);
    if (session == null ||
        session.tripLocalId != tripId ||
        session.controlState != 'active') {
      return false;
    }
    final normalizedPoint = _AcceptedPoint(
      recordedAt: point.recordedAt.toUtc(),
      latitude: point.latitude,
      longitude: point.longitude,
    );
    final lastPoint = _lastAcceptedPointBySession[sessionId];
    if (_isDuplicatePoint(lastPoint: lastPoint, sample: normalizedPoint)) {
      return false;
    }
    final pointSeq = await _nextPointSeq(sessionId);
    await _routePointRepository.upsertPoint(
      pointId: _uuid.v4(),
      sessionId: sessionId,
      tripLocalId: tripId,
      capturedAt: normalizedPoint.recordedAt,
      latitude: normalizedPoint.latitude,
      longitude: normalizedPoint.longitude,
      accuracyM: point.accuracyMeters,
      speedMps: point.speedMps,
      source: 'device_gps',
      pointSeq: pointSeq,
    );
    _lastAcceptedPointBySession[sessionId] = normalizedPoint;
    return true;
  }

  Future<int> recoverAndEnforceSingleActiveSession() async {
    final activeSessions =
        await _sessionRepository.listSessionsByStates(const {'active'});
    if (activeSessions.length <= 1) {
      return activeSessions.length;
    }
    final now = _now().toUtc();
    for (final stale in activeSessions.skip(1)) {
      await _sessionRepository.upsertSession(
        sessionId: stale.sessionId,
        tripLocalId: stale.tripLocalId,
        serverTripId: stale.serverTripId,
        controlState: 'sealed',
        stopServerPending: stale.stopServerPending,
        startAckAt: stale.startAckAt,
        stopAckAt: stale.stopAckAt,
        startedAt: stale.startedAt,
        endedAt: stale.endedAt ?? now,
        stopClientEventId: stale.stopClientEventId,
        sealVersion: math.max(stale.sealVersion, 1),
        startRequestSeq: stale.startRequestSeq,
        sessionSeq: stale.sessionSeq,
        deviceId: stale.deviceId,
        createdAt: stale.createdAt,
        updatedAt: now,
      );
    }
    return 1;
  }

  Future<List<SessionJournalRow>> listActiveSessions() {
    return _sessionRepository.listSessionsByStates(const {'active'});
  }

  LiveTrackingRuntimeSnapshot _snapshotFromRow({
    required String tripId,
    SessionJournalRow? row,
  }) {
    if (row == null) {
      return LiveTrackingRuntimeSnapshot(
        tripId: tripId,
        state: LiveTrackingRuntimeState.planned,
      );
    }
    return LiveTrackingRuntimeSnapshot(
      tripId: tripId,
      state: _mapControlState(row.controlState),
      sessionId: row.sessionId,
      remoteSessionId: _remoteSessionIdsByClientSessionId[row.sessionId],
      startedAt: row.startedAt,
      endedAt: row.endedAt,
    );
  }

  LiveTrackingRuntimeState _mapControlState(String controlState) {
    switch (controlState) {
      case 'active':
        return LiveTrackingRuntimeState.active;
      case 'paused':
        return LiveTrackingRuntimeState.paused;
      case 'sealed':
        return LiveTrackingRuntimeState.ended;
      case 'planned':
      default:
        return LiveTrackingRuntimeState.planned;
    }
  }

  Future<void> _closeLatestOpenWindow({
    required SessionJournalRow session,
    required DateTime endedAt,
  }) async {
    final windows = await _sessionRepository
        .listActivityWindowsForSession(session.sessionId);
    SessionActivityWindowRow? open;
    for (final row in windows) {
      if (row.endedAt == null) {
        open = row;
        break;
      }
    }
    if (open == null) {
      return;
    }
    await _sessionRepository.upsertActivityWindow(
      windowId: open.windowId,
      sessionId: open.sessionId,
      tripLocalId: open.tripLocalId,
      windowKind: open.windowKind,
      startedAt: open.startedAt,
      endedAt: endedAt,
      windowSeq: open.windowSeq,
    );
  }

  Future<int> _nextWindowSeq(String sessionId) async {
    final windows = await _sessionRepository.listActivityWindowsForSession(
      sessionId,
    );
    if (windows.isEmpty) {
      return 1;
    }
    return windows.map((row) => row.windowSeq).reduce(math.max) + 1;
  }

  Future<int> _nextSessionSeq(String tripId) async {
    final sessions = await _sessionRepository.listSessionsForTrip(tripId);
    if (sessions.isEmpty) {
      return 1;
    }
    return sessions.map((row) => row.sessionSeq).reduce(math.max) + 1;
  }

  Future<int> _nextPointSeq(String sessionId) async {
    final cached = _pointSeqBySession[sessionId];
    if (cached != null) {
      final next = cached + 1;
      _pointSeqBySession[sessionId] = next;
      return next;
    }
    final existing =
        await _routePointRepository.listPointsForSession(sessionId);
    final next = existing.isEmpty
        ? 1
        : existing.map((row) => row.pointSeq).reduce(math.max) + 1;
    _pointSeqBySession[sessionId] = next;
    return next;
  }

  Future<String> _resolveRemoteTripIdForStart(String tripId) async {
    try {
      return await _resolveRemoteTripId(tripId);
    } catch (_) {
      throw const V2LiveTrackingCommandException(
        code: 'tracking_trip_identity_missing',
        message: 'Trip is not synced on server yet. Sync trip and retry.',
        retryable: true,
      );
    }
  }

  V2LiveTrackingCommandException _mapStartFailure(Object error) {
    if (error is V2LiveTrackingCommandException) {
      return error;
    }
    if (error is V2CommandTransportException) {
      return V2LiveTrackingCommandException(
        code: error.code,
        message: error.message,
        retryable: true,
      );
    }
    return const V2LiveTrackingCommandException(
      code: 'tracking_start_failed',
      message: 'Unable to start live tracking right now.',
      retryable: true,
    );
  }

  String _deviceIdFromContext(Map<String, dynamic>? deviceContext) {
    final dynamic raw = deviceContext?['device_id'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return 'unknown_device';
  }

  bool _isDuplicatePoint({
    required _AcceptedPoint? lastPoint,
    required _AcceptedPoint sample,
  }) {
    if (lastPoint == null) {
      return false;
    }
    final delta = sample.recordedAt.difference(lastPoint.recordedAt);
    if (delta >= Duration.zero && delta < _policy.minPointCadence) {
      return true;
    }
    final distance = _distanceMeters(
      latitudeA: lastPoint.latitude,
      longitudeA: lastPoint.longitude,
      latitudeB: sample.latitude,
      longitudeB: sample.longitude,
    );
    return distance < _policy.minDistanceMeters;
  }

  double _distanceMeters({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(latitudeB - latitudeA);
    final dLon = _toRadians(longitudeB - longitudeA);
    final lat1 = _toRadians(latitudeA);
    final lat2 = _toRadians(latitudeB);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _toRadians(double degree) => degree * math.pi / 180.0;
}

class _AcceptedPoint {
  const _AcceptedPoint({
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
  });

  final DateTime recordedAt;
  final double latitude;
  final double longitude;
}
