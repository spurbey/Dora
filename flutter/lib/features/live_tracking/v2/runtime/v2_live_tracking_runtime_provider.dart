import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/location/location_provider.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart'
    show
        LiveTrackingRuntimeSnapshot,
        LiveTrackingRuntimeState,
        TrackingPointSample;
import 'package:dora/features/create/presentation/live_tracking_map_overlay.dart';
import 'package:dora/features/create/presentation/live_tracking_path_filter.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_capture_coordinator.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_command_api.dart';
import 'package:dora/features/live_tracking/v2/runtime/v2_live_tracking_runtime_repository.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

final v2CommandApiProvider = Provider<V2CommandApi>((ref) {
  final liveTrackingApi = ref.watch(liveTrackingApiProvider);
  return V2BridgeCommandApi(liveTrackingApi: liveTrackingApi);
});

final v2LiveTrackingRuntimeRepositoryProvider =
    Provider<V2LiveTrackingRuntimeRepository>((ref) {
  final sessionRepository = ref.watch(v2SessionJournalRepositoryProvider);
  final routePointRepository = ref.watch(v2RoutePointJournalRepositoryProvider);
  final commandApi = ref.watch(v2CommandApiProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);
  return V2LiveTrackingRuntimeRepository(
    sessionRepository: sessionRepository,
    routePointRepository: routePointRepository,
    commandApi: commandApi,
    resolveRemoteTripId: (tripId) =>
        tripRepository.ensureRemoteTripId(tripId, allowCreate: false),
  );
});

final v2LiveTrackingRuntimeSnapshotProvider =
    StreamProvider.family<LiveTrackingRuntimeSnapshot, String>((ref, tripId) {
  final repository = ref.watch(v2LiveTrackingRuntimeRepositoryProvider);
  return repository.watchRuntimeSnapshot(tripId);
});

final v2HasActiveSessionProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, tripId) {
  final sessionRepository = ref.watch(v2SessionJournalRepositoryProvider);
  return sessionRepository.watchLatestSessionForTrip(tripId).map((row) {
    if (row == null) {
      return false;
    }
    return row.controlState == 'active' || row.controlState == 'paused';
  });
});

final v2LiveTrackingSessionPointsProvider =
    StreamProvider.autoDispose.family<List<RoutePointJournalRow>, String>(
  (ref, sessionId) {
    final repository = ref.watch(v2RoutePointJournalRepositoryProvider);
    return repository.watchPointsForSession(sessionId);
  },
);

final v2LiveTrackingMapOverlayProvider =
    Provider.autoDispose.family<LiveTrackingMapOverlay, String>((ref, tripId) {
  final runtime = ref.watch(
    v2LiveTrackingRuntimeSnapshotProvider(tripId).select(
      (asyncSnapshot) => asyncSnapshot.valueOrNull,
    ),
  );
  if (runtime == null ||
      runtime.state == LiveTrackingRuntimeState.planned ||
      runtime.sessionId == null ||
      runtime.sessionId!.isEmpty) {
    return const LiveTrackingMapOverlay();
  }
  final sessionId = runtime.sessionId!;
  final points =
      ref.watch(v2LiveTrackingSessionPointsProvider(sessionId)).valueOrNull ??
          const <RoutePointJournalRow>[];
  if (points.isEmpty) {
    return const LiveTrackingMapOverlay();
  }
  final samples = points
      .map(
        (row) => LiveTrackingPathSample(
          latitude: row.latitude,
          longitude: row.longitude,
          recordedAt: row.capturedAt,
          accuracyM: row.accuracyM,
          speedMps: row.speedMps,
          sequence: row.pointSeq,
        ),
      )
      .toList(growable: false);
  final pathPoints = buildStableLiveTrackingPathPoints(samples);
  if (pathPoints.isEmpty) {
    return const LiveTrackingMapOverlay();
  }
  return LiveTrackingMapOverlay(
    pathRoute: pathPoints.length >= 2
        ? AppRoute(
            id: '_live_tracking_v2_path_$sessionId',
            coordinates: pathPoints,
            color: const Color(0xFF0EA5E9),
            width: 5.0,
            dashed: false,
          )
        : null,
    currentMarker: AppMarker(
      id: '_live_tracking_v2_current_$sessionId',
      position: pathPoints.last,
      title: 'Live position',
      color: const Color(0xFF0EA5E9),
      markerType: 'tracking_current',
      label: 'Live',
    ),
  );
});

final v2LiveCaptureEventsProvider =
    StreamProvider.autoDispose.family<List<EventJournalRow>, String>(
  (ref, tripId) {
    final repository = ref.watch(v2LiveCaptureJournalRepositoryProvider);
    return repository.watchEventsForTrip(tripId);
  },
);

final v2CaptureCoordinatorProvider = Provider<V2CaptureCoordinator>((ref) {
  final repository = ref.watch(v2LiveTrackingRuntimeRepositoryProvider);
  final permissionService = ref.watch(locationPermissionProvider);
  final locationService = ref.watch(locationServiceProvider);
  final coordinator = V2CaptureCoordinator(
    repository: repository,
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

final v2CaptureBootstrapProvider = Provider<void>((ref) {
  final coordinator = ref.watch(v2CaptureCoordinatorProvider);
  unawaited(coordinator.recoverAndEnforceSingleActiveSession());
});
