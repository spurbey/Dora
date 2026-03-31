import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_capture_coordinator.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';

final liveTrackingRuntimeRepositoryProvider =
    Provider<LiveTrackingRuntimeRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final trackingSessionDao = ref.watch(trackingSessionDaoProvider);
  final trackingPointBatchDao = ref.watch(trackingPointBatchDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  final liveTrackingApi = ref.watch(liveTrackingApiProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);
  return LiveTrackingRuntimeRepository(
    db,
    trackingSessionDao: trackingSessionDao,
    trackingPointBatchDao: trackingPointBatchDao,
    syncTaskDao: syncTaskDao,
    liveTrackingApi: liveTrackingApi,
    resolveRemoteTripId: (tripId) =>
        tripRepository.ensureRemoteTripId(tripId, allowCreate: false),
    clearRemoteTripId: tripRepository.clearServerTripId,
  );
});

final liveTrackingRuntimeSnapshotProvider =
    StreamProvider.family<LiveTrackingRuntimeSnapshot, String>(
  (ref, tripId) {
    final repository = ref.watch(liveTrackingRuntimeRepositoryProvider);
    return repository.watchRuntimeSnapshot(tripId);
  },
);

final liveTrackingSessionBatchesProvider =
    StreamProvider.autoDispose.family<List<TrackingPointBatchRow>, String>(
  (ref, sessionId) {
    final dao = ref.watch(trackingPointBatchDaoProvider);
    return dao.watchBatchesForSession(sessionId);
  },
);

final liveTrackingRemotePathRefreshIntervalProvider =
    Provider.family<Duration, LiveTrackingRuntimeState>((ref, state) {
  switch (state) {
    case LiveTrackingRuntimeState.active:
      return const Duration(seconds: 12);
    case LiveTrackingRuntimeState.paused:
      return const Duration(seconds: 30);
    case LiveTrackingRuntimeState.ended:
      return const Duration(seconds: 60);
    case LiveTrackingRuntimeState.planned:
      return const Duration(seconds: 60);
  }
});

final liveTrackingIsAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).valueOrNull != null;
});

final liveTrackingServerTripIdProvider =
    StreamProvider.autoDispose.family<String?, String>((ref, tripId) {
  final db = ref.watch(appDatabaseProvider);
  final query = db.customSelect(
    '''
    SELECT server_trip_id
    FROM trips
    WHERE id = ?
    LIMIT 1
    ''',
    variables: [Variable<String>(tripId)],
    readsFrom: {db.trips},
  );
  return query.watchSingleOrNull().map((row) {
    final serverTripId = row?.read<String?>('server_trip_id')?.trim();
    if (serverTripId == null || serverTripId.isEmpty) {
      return null;
    }
    return serverTripId;
  });
});

final liveTrackingRemotePathPointsProvider =
    StreamProvider.autoDispose.family<List<AppLatLng>, String>((
  ref,
  tripId,
) {
  final isAuthenticated = ref.watch(liveTrackingIsAuthenticatedProvider);
  final serverTripId =
      ref.watch(liveTrackingServerTripIdProvider(tripId)).valueOrNull;
  final runtimeState = ref.watch(
    liveTrackingRuntimeSnapshotProvider(tripId).select((asyncSnapshot) {
      final snapshot = asyncSnapshot.valueOrNull;
      return (
        snapshot?.state ?? LiveTrackingRuntimeState.planned,
        snapshot?.remoteSessionId,
      );
    }),
  );
  final state = runtimeState.$1;
  final remoteSessionId = runtimeState.$2;
  if (!isAuthenticated ||
      state == LiveTrackingRuntimeState.planned ||
      serverTripId == null ||
      remoteSessionId == null ||
      remoteSessionId.isEmpty) {
    return Stream<List<AppLatLng>>.value(const <AppLatLng>[]);
  }

  final api = ref.watch(liveTrackingApiProvider);
  final refreshInterval =
      ref.watch(liveTrackingRemotePathRefreshIntervalProvider(state));
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
  });

  Future<List<AppLatLng>> fetchPoints() async {
    final payload = await api.fetchTrackingPath(
      tripId: serverTripId,
      sessionId: remoteSessionId,
    );
    final rawPoints = payload['points'];
    if (rawPoints is! List) {
      return const <AppLatLng>[];
    }

    final points = <AppLatLng>[];
    for (final raw in rawPoints) {
      if (raw is! Map) {
        continue;
      }
      final latitude = _asDouble(raw['latitude']);
      final longitude = _asDouble(raw['longitude']);
      if (latitude == null || longitude == null) {
        continue;
      }
      if (!_isValidCoordinate(latitude: latitude, longitude: longitude)) {
        continue;
      }
      points.add(AppLatLng(latitude: latitude, longitude: longitude));
    }
    return _stabilizeRemotePath(points);
  }

  return (() async* {
    List<AppLatLng>? previous;
    while (!disposed) {
      try {
        final points = await fetchPoints();
        if (previous == null || !_sameCoordinates(previous, points)) {
          previous = points;
          yield points;
        }
      } catch (_) {
        const fallback = <AppLatLng>[];
        if (previous == null || !_sameCoordinates(previous, fallback)) {
          previous = fallback;
          yield previous;
        }
      }
      if (state == LiveTrackingRuntimeState.ended || disposed) {
        break;
      }
      await Future<void>.delayed(refreshInterval);
    }
  })();
});

final liveTrackingMapOverlayProvider =
    Provider.autoDispose.family<LiveTrackingMapOverlay, String>(
  (ref, tripId) {
    final runtimeKey = ref.watch(
      liveTrackingRuntimeSnapshotProvider(tripId).select((asyncSnapshot) {
        final snapshot = asyncSnapshot.valueOrNull;
        return (
          snapshot?.state ?? LiveTrackingRuntimeState.planned,
          snapshot?.sessionId,
        );
      }),
    );
    final runtimeState = runtimeKey.$1;
    final sessionId = runtimeKey.$2;
    if (runtimeState == LiveTrackingRuntimeState.planned ||
        sessionId == null ||
        sessionId.isEmpty) {
      return const LiveTrackingMapOverlay();
    }
    final sessionBatches =
        ref.watch(liveTrackingSessionBatchesProvider(sessionId)).valueOrNull ??
            const <TrackingPointBatchRow>[];
    final localOverlay = buildLiveTrackingMapOverlay(
      snapshot: LiveTrackingRuntimeSnapshot(
        tripId: tripId,
        state: runtimeState,
        sessionId: sessionId,
      ),
      sessionBatches: sessionBatches,
    );
    final remotePath =
        ref.watch(liveTrackingRemotePathPointsProvider(tripId)).valueOrNull ??
            const <AppLatLng>[];
    final localPath =
        localOverlay.pathRoute?.coordinates ?? const <AppLatLng>[];
    if (!_shouldPreferRemotePath(
        remotePath: remotePath, localPath: localPath)) {
      return localOverlay;
    }

    return LiveTrackingMapOverlay(
      pathRoute: AppRoute(
        id: '_live_tracking_remote_path_$sessionId',
        coordinates: remotePath,
        color: const Color(0xFF0EA5E9),
        width: 5.0,
        dashed: false,
      ),
      currentMarker: localOverlay.currentMarker,
    );
  },
);

final liveTrackingCaptureCoordinatorProvider =
    Provider<LiveTrackingCaptureCoordinator>((ref) {
  final repository = ref.watch(liveTrackingRuntimeRepositoryProvider);
  final trackingSessionDao = ref.watch(trackingSessionDaoProvider);
  final permissionService = ref.watch(locationPermissionProvider);
  final locationService = ref.watch(locationServiceProvider);
  final coordinator = LiveTrackingCaptureCoordinator(
    repository: repository,
    trackingSessionDao: trackingSessionDao,
    ensureLocationAccess: ({
      required bool requestIfDenied,
    }) {
      return permissionService.ensurePermissionStatus(
        requestIfDenied: requestIfDenied,
      );
    },
    pointStreamFactory: () {
      return locationService.watchPosition().map(
            (position) => TrackingPointSample(
              recordedAt: position.timestamp.toUtc(),
              latitude: position.latitude,
              longitude: position.longitude,
              accuracyMeters: position.accuracy,
              speedMps: position.speed,
            ),
          );
    },
  );
  ref.onDispose(() {
    unawaited(coordinator.dispose());
  });
  return coordinator;
});

final liveTrackingCaptureBootstrapProvider = Provider<void>((ref) {
  final coordinator = ref.watch(liveTrackingCaptureCoordinatorProvider);
  unawaited(coordinator.recoverActiveSessions());
});

double? _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

bool _isValidCoordinate({
  required double latitude,
  required double longitude,
}) {
  return latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;
}

bool _sameCoordinates(List<AppLatLng> left, List<AppLatLng> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i += 1) {
    if (left[i].latitude != right[i].latitude ||
        left[i].longitude != right[i].longitude) {
      return false;
    }
  }
  return true;
}

const double _minRemoteMoveMeters = 2.0;
const double _remoteSpikeJumpMeters = 120.0;
const double _remoteSpikeDirectMeters = 60.0;
const double _maxRemoteSegmentMeters = 2500.0;

List<AppLatLng> _stabilizeRemotePath(List<AppLatLng> raw) {
  if (raw.length <= 1) {
    return raw;
  }

  final deduped = <AppLatLng>[raw.first];
  for (final point in raw.skip(1)) {
    if (_distanceMeters(deduped.last, point) <= _minRemoteMoveMeters) {
      continue;
    }
    deduped.add(point);
  }

  if (deduped.length <= 2) {
    return deduped;
  }

  final spikePruned = <AppLatLng>[deduped.first];
  for (var i = 1; i < deduped.length - 1; i += 1) {
    final previous = spikePruned.last;
    final current = deduped[i];
    final next = deduped[i + 1];
    final toCurrent = _distanceMeters(previous, current);
    final fromCurrent = _distanceMeters(current, next);
    final direct = _distanceMeters(previous, next);
    final looksLikeSpike = toCurrent >= _remoteSpikeJumpMeters &&
        fromCurrent >= _remoteSpikeJumpMeters &&
        direct <= _remoteSpikeDirectMeters;
    if (looksLikeSpike) {
      continue;
    }
    spikePruned.add(current);
  }
  spikePruned.add(deduped.last);

  final bridged = <AppLatLng>[spikePruned.first];
  for (final point in spikePruned.skip(1)) {
    if (_distanceMeters(bridged.last, point) > _maxRemoteSegmentMeters) {
      continue;
    }
    bridged.add(point);
  }
  return bridged;
}

bool _shouldPreferRemotePath({
  required List<AppLatLng> remotePath,
  required List<AppLatLng> localPath,
}) {
  if (remotePath.length < 2) {
    return false;
  }
  if (localPath.length < 2) {
    return true;
  }

  final remoteDistance = _pathDistanceMeters(remotePath);
  final localDistance = _pathDistanceMeters(localPath);
  if (remoteDistance <= 0) {
    return false;
  }

  final remotePointCount = remotePath.length;
  final localPointCount = localPath.length;
  if (localPointCount >= 6 &&
      remotePointCount <= math.max(2, (localPointCount / 2).floor())) {
    return false;
  }

  if (localDistance >= 250) {
    final distanceRatio = remoteDistance / localDistance;
    if (distanceRatio < 0.6) {
      return false;
    }
  }

  return true;
}

double _pathDistanceMeters(List<AppLatLng> points) {
  if (points.length < 2) {
    return 0;
  }
  var total = 0.0;
  for (var i = 1; i < points.length; i += 1) {
    total += _distanceMeters(points[i - 1], points[i]);
  }
  return total;
}

double _distanceMeters(AppLatLng left, AppLatLng right) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _radians(right.latitude - left.latitude);
  final dLon = _radians(right.longitude - left.longitude);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_radians(left.latitude)) *
          math.cos(_radians(right.latitude)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

double _radians(double degrees) => degrees * (math.pi / 180.0);
