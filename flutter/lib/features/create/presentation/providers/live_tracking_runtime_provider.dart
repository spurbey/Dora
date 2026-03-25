import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_capture_coordinator.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';

final liveTrackingRuntimeRepositoryProvider =
    Provider<LiveTrackingRuntimeRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final trackingSessionDao = ref.watch(trackingSessionDaoProvider);
  final trackingPointBatchDao = ref.watch(trackingPointBatchDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  return LiveTrackingRuntimeRepository(
    db,
    trackingSessionDao: trackingSessionDao,
    trackingPointBatchDao: trackingPointBatchDao,
    syncTaskDao: syncTaskDao,
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

final liveTrackingRemotePathPointsProvider =
    StreamProvider.autoDispose.family<List<AppLatLng>, String>((
      ref,
      tripId,
    ) {
      final runtimeState = ref.watch(
        liveTrackingRuntimeSnapshotProvider(tripId).select((asyncSnapshot) {
          final snapshot = asyncSnapshot.valueOrNull;
          return (
            snapshot?.state ?? LiveTrackingRuntimeState.planned,
            snapshot?.sessionId,
          );
        }),
      );
      final state = runtimeState.$1;
      final sessionId = runtimeState.$2;
      if (state == LiveTrackingRuntimeState.planned ||
          sessionId == null ||
          sessionId.isEmpty) {
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
          tripId: tripId,
          sessionId: sessionId,
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
        return points;
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
            if (previous == null) {
              previous = const <AppLatLng>[];
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
    if (remotePath.length < 2) {
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
