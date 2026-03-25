import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return buildLiveTrackingMapOverlay(
      snapshot: LiveTrackingRuntimeSnapshot(
        tripId: tripId,
        state: runtimeState,
        sessionId: sessionId,
      ),
      sessionBatches: sessionBatches,
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
