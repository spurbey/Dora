import 'dart:async';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';

class LiveTrackingCaptureException implements Exception {
  const LiveTrackingCaptureException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => 'LiveTrackingCaptureException($code): $message';
}

typedef EnsureLocationAccess = Future<LocationAccessState> Function({
  required bool requestIfDenied,
});

typedef TrackingPointStreamFactory = Stream<TrackingPointSample> Function();

class LiveTrackingCaptureCoordinator {
  LiveTrackingCaptureCoordinator({
    required LiveTrackingRuntimeRepository repository,
    required TrackingSessionDao trackingSessionDao,
    required EnsureLocationAccess ensureLocationAccess,
    required TrackingPointStreamFactory pointStreamFactory,
  })  : _repository = repository,
        _trackingSessionDao = trackingSessionDao,
        _ensureLocationAccess = ensureLocationAccess,
        _pointStreamFactory = pointStreamFactory;

  final LiveTrackingRuntimeRepository _repository;
  final TrackingSessionDao _trackingSessionDao;
  final EnsureLocationAccess _ensureLocationAccess;
  final TrackingPointStreamFactory _pointStreamFactory;

  final Map<String, _ActiveTrackingSession> _activeSessions = {};
  StreamSubscription<TrackingPointSample>? _pointSubscription;
  bool _disposed = false;

  bool get isCapturing =>
      _pointSubscription != null && _activeSessions.isNotEmpty;

  Future<TrackingSessionRow> startTracking({
    required String tripId,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    await _requireLocationAccess(requestIfDenied: true);
    final session = await _repository.startSession(
      tripId: tripId,
      timezone: timezone,
      deviceContext: deviceContext,
    );
    _activeSessions[session.id] = _ActiveTrackingSession(
      sessionId: session.id,
      tripId: session.tripId,
    );
    await _syncCaptureSubscription();
    return session;
  }

  Future<TrackingSessionRow?> pauseTracking({
    required String tripId,
  }) async {
    final paused = await _repository.pauseSession(tripId: tripId);
    if (paused == null) {
      return null;
    }
    _activeSessions.remove(paused.id);
    await _syncCaptureSubscription();
    return paused;
  }

  Future<TrackingSessionRow?> resumeTracking({
    required String tripId,
  }) async {
    await _requireLocationAccess(requestIfDenied: true);
    final resumed = await _repository.resumeSession(tripId: tripId);
    if (resumed == null) {
      return null;
    }
    _activeSessions[resumed.id] = _ActiveTrackingSession(
      sessionId: resumed.id,
      tripId: resumed.tripId,
    );
    await _syncCaptureSubscription();
    return resumed;
  }

  Future<TrackingSessionRow?> stopTracking({
    required String tripId,
  }) async {
    final stopped = await _repository.stopSession(tripId: tripId);
    if (stopped == null) {
      return null;
    }
    _activeSessions.remove(stopped.id);
    await _syncCaptureSubscription();
    return stopped;
  }

  Future<int> recoverActiveSessions() async {
    final accessState = await _ensureLocationAccess(requestIfDenied: false);
    if (accessState != LocationAccessState.granted) {
      return 0;
    }
    final activeSessions =
        await _trackingSessionDao.getSessionsByStates(const {'active'});
    for (final session in activeSessions) {
      _activeSessions[session.id] = _ActiveTrackingSession(
        sessionId: session.id,
        tripId: session.tripId,
      );
    }
    await _syncCaptureSubscription();
    return activeSessions.length;
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _activeSessions.clear();
    await _pointSubscription?.cancel();
    _pointSubscription = null;
  }

  Future<void> _syncCaptureSubscription() async {
    if (_disposed) {
      return;
    }
    if (_activeSessions.isEmpty) {
      await _pointSubscription?.cancel();
      _pointSubscription = null;
      return;
    }
    if (_pointSubscription != null) {
      return;
    }
    _pointSubscription = _pointStreamFactory().listen(
      (sample) {
        final sessions = _activeSessions.values.toList(growable: false);
        for (final session in sessions) {
          unawaited(
            _repository.ingestPoint(
              tripId: session.tripId,
              sessionId: session.sessionId,
              point: sample,
            ),
          );
        }
      },
      onError: (_, __) {
        _pointSubscription = null;
        unawaited(_syncCaptureSubscription());
      },
      onDone: () {
        _pointSubscription = null;
        unawaited(_syncCaptureSubscription());
      },
      cancelOnError: false,
    );
  }

  Future<void> _requireLocationAccess({
    required bool requestIfDenied,
  }) async {
    final state = await _ensureLocationAccess(requestIfDenied: requestIfDenied);
    if (state == LocationAccessState.granted) {
      return;
    }
    if (state == LocationAccessState.serviceDisabled) {
      throw const LiveTrackingCaptureException(
        code: 'location_service_disabled',
        message: 'Location service is disabled.',
      );
    }
    if (state == LocationAccessState.deniedForever) {
      throw const LiveTrackingCaptureException(
        code: 'location_permission_denied_forever',
        message: 'Location permission is denied forever.',
      );
    }
    throw const LiveTrackingCaptureException(
      code: 'location_permission_denied',
      message: 'Location permission denied.',
    );
  }
}

class _ActiveTrackingSession {
  const _ActiveTrackingSession({
    required this.sessionId,
    required this.tripId,
  });

  final String sessionId;
  final String tripId;
}
