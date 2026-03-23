import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';

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
