import 'dart:async';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:flutter/foundation.dart' show debugPrint;

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
    Duration restartInitialDelay = const Duration(seconds: 1),
    Duration restartMaxDelay = const Duration(seconds: 30),
  })  : _repository = repository,
        _trackingSessionDao = trackingSessionDao,
        _ensureLocationAccess = ensureLocationAccess,
        _pointStreamFactory = pointStreamFactory,
        _restartInitialDelay = restartInitialDelay,
        _restartMaxDelay = restartMaxDelay;

  final LiveTrackingRuntimeRepository _repository;
  final TrackingSessionDao _trackingSessionDao;
  final EnsureLocationAccess _ensureLocationAccess;
  final TrackingPointStreamFactory _pointStreamFactory;
  final Duration _restartInitialDelay;
  final Duration _restartMaxDelay;

  final Map<String, _ActiveTrackingSession> _activeSessions = {};
  StreamSubscription<TrackingPointSample>? _pointSubscription;
  Future<void> _ingestTail = Future<void>.value();
  Timer? _restartTimer;
  int _restartAttempt = 0;
  bool _disposed = false;

  bool get isCapturing =>
      _pointSubscription != null && _activeSessions.isNotEmpty;

  Future<TrackingSessionRow> startTracking({
    required String tripId,
    String? timezone,
    Map<String, dynamic>? deviceContext,
  }) async {
    await _requireLocationAccess(requestIfDenied: true);
    final session = await _runCommand(
      () => _repository.startSession(
        tripId: tripId,
        timezone: timezone,
        deviceContext: deviceContext,
      ),
    );
    await _setSingleActiveSession(session);
    await _syncCaptureSubscription();
    return session;
  }

  Future<TrackingSessionRow?> pauseTracking({
    required String tripId,
  }) async {
    final paused = await _runCommand(
      () => _repository.pauseSession(tripId: tripId),
    );
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
    final resumed = await _runCommand(
      () => _repository.resumeSession(tripId: tripId),
    );
    if (resumed == null) {
      return null;
    }
    await _setSingleActiveSession(resumed);
    await _syncCaptureSubscription();
    return resumed;
  }

  Future<TrackingSessionRow?> stopTracking({
    required String tripId,
  }) async {
    final stopped = await _runCommand(
      () => _repository.stopSession(tripId: tripId),
    );
    if (stopped == null) {
      return null;
    }
    _activeSessions.remove(stopped.id);
    await _syncCaptureSubscription();
    return stopped;
  }

  Future<int> recoverActiveSessions() => recoverAndEnforceSingleActiveSession();

  Future<int> recoverAndEnforceSingleActiveSession() async {
    final accessState = await _ensureLocationAccess(requestIfDenied: false);
    if (accessState != LocationAccessState.granted) {
      return 0;
    }
    final activeSessions =
        await _trackingSessionDao.getSessionsByStates(const {'active'});
    if (activeSessions.isEmpty) {
      _activeSessions.clear();
      await _syncCaptureSubscription();
      return 0;
    }

    final newestActive = activeSessions.first;
    if (activeSessions.length > 1) {
      debugPrint(
        '[LIVE_CAPTURE] invariant_violation multiple_active_sessions '
        'count=${activeSessions.length} keep=${newestActive.id}',
      );
      final abandonedAt = DateTime.now().toUtc();
      for (final stale in activeSessions.skip(1)) {
        await _trackingSessionDao.updateLifecycle(
          sessionId: stale.id,
          state: 'abandoned',
          abandonedAt: abandonedAt,
        );
      }
    }

    _activeSessions
      ..clear()
      ..[newestActive.id] = _ActiveTrackingSession(
        sessionId: newestActive.id,
        tripId: newestActive.tripId,
      );
    await _syncCaptureSubscription();
    return 1;
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _activeSessions.clear();
    _restartTimer?.cancel();
    _restartTimer = null;
    await _pointSubscription?.cancel();
    _pointSubscription = null;
    try {
      await _ingestTail;
    } catch (_) {
      // no-op: pending ingestion failures should not fail dispose.
    }
  }

  Future<void> _syncCaptureSubscription() async {
    if (_disposed) {
      return;
    }
    if (_activeSessions.length > 1) {
      final keep = _activeSessions.values.first;
      debugPrint(
        '[LIVE_CAPTURE] invariant_violation active_session_map_count='
        '${_activeSessions.length} keep=${keep.sessionId}',
      );
      _activeSessions
        ..clear()
        ..[keep.sessionId] = keep;
    }
    if (_activeSessions.isEmpty) {
      await _pointSubscription?.cancel();
      _pointSubscription = null;
      _restartTimer?.cancel();
      _restartTimer = null;
      _restartAttempt = 0;
      return;
    }
    if (_pointSubscription != null) {
      return;
    }
    _restartTimer?.cancel();
    _restartTimer = null;
    _pointSubscription = _pointStreamFactory().listen(
      (sample) {
        _restartAttempt = 0;
        _enqueuePointIngestion(sample);
      },
      onError: (_, __) {
        final currentSubscription = _pointSubscription;
        _pointSubscription = null;
        if (currentSubscription != null) {
          unawaited(currentSubscription.cancel());
        }
        _scheduleResubscribe();
      },
      onDone: () {
        _pointSubscription = null;
        _scheduleResubscribe();
      },
      cancelOnError: false,
    );
  }

  void _enqueuePointIngestion(TrackingPointSample sample) {
    if (_activeSessions.isEmpty) {
      return;
    }
    final session = _activeSessions.values.first;
    _ingestTail = _ingestTail.catchError((_, __) {}).then((_) async {
      final accepted = await _repository.ingestPoint(
        tripId: session.tripId,
        sessionId: session.sessionId,
        point: sample,
      );
      if (!accepted && _activeSessions.containsKey(session.sessionId)) {
        debugPrint(
          '[LIVE_CAPTURE] stale_or_inactive_session_removed '
          'session=${session.sessionId} trip=${session.tripId}',
        );
        _activeSessions.remove(session.sessionId);
        await _syncCaptureSubscription();
      }
    });
  }

  Future<void> _setSingleActiveSession(TrackingSessionRow session) async {
    final activeSessions =
        await _trackingSessionDao.getSessionsByStates(const {'active'});
    if (activeSessions.length > 1 ||
        (activeSessions.length == 1 && activeSessions.first.id != session.id)) {
      debugPrint(
        '[LIVE_CAPTURE] reconciling_active_sessions keep=${session.id} '
        'existing=${activeSessions.length}',
      );
    }

    final abandonedAt = DateTime.now().toUtc();
    for (final row in activeSessions) {
      if (row.id == session.id) {
        continue;
      }
      await _trackingSessionDao.updateLifecycle(
        sessionId: row.id,
        state: 'abandoned',
        abandonedAt: abandonedAt,
      );
    }

    _activeSessions
      ..clear()
      ..[session.id] = _ActiveTrackingSession(
        sessionId: session.id,
        tripId: session.tripId,
      );
  }

  void _scheduleResubscribe() {
    if (_disposed || _activeSessions.isEmpty || _pointSubscription != null) {
      return;
    }
    if (_restartTimer != null) {
      return;
    }
    final delay = _computeRestartDelay();
    _restartTimer = Timer(delay, () {
      _restartTimer = null;
      if (_disposed || _activeSessions.isEmpty || _pointSubscription != null) {
        return;
      }
      unawaited(_syncCaptureSubscription());
    });
  }

  Duration _computeRestartDelay() {
    final clampedAttempt = _restartAttempt > 8 ? 8 : _restartAttempt;
    final multiplier = 1 << clampedAttempt;
    final delay = Duration(
      milliseconds: _restartInitialDelay.inMilliseconds * multiplier,
    );
    _restartAttempt += 1;
    if (delay > _restartMaxDelay) {
      return _restartMaxDelay;
    }
    return delay;
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

  Future<T> _runCommand<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on LiveTrackingCommandException catch (error) {
      throw LiveTrackingCaptureException(
        code: error.code,
        message: error.message,
      );
    }
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
