import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/network/api_providers.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/sync/tracking_sync_bootstrap.dart';
import 'package:dora/core/sync/tracking_sync_worker.dart';

final trackingSyncWorkerProvider = Provider<TrackingSyncWorker>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  final trackingSessionDao = ref.watch(trackingSessionDaoProvider);
  final trackingPointBatchDao = ref.watch(trackingPointBatchDaoProvider);
  final trackingCandidateDao = ref.watch(trackingCandidateDaoProvider);
  final trackingEventDao = ref.watch(trackingEventDaoProvider);
  final trackingMomentDao = ref.watch(trackingMomentDaoProvider);
  final liveTrackingApi = ref.watch(liveTrackingApiProvider);
  return TrackingSyncWorker(
    db: db,
    syncTaskDao: syncTaskDao,
    trackingSessionDao: trackingSessionDao,
    trackingPointBatchDao: trackingPointBatchDao,
    trackingCandidateDao: trackingCandidateDao,
    trackingEventDao: trackingEventDao,
    trackingMomentDao: trackingMomentDao,
    liveTrackingApi: liveTrackingApi,
  );
});

final trackingSyncBootstrapProvider = Provider<void>((ref) {
  final worker = ref.watch(trackingSyncWorkerProvider);
  final bootstrap = TrackingSyncBootstrap(worker);
  bootstrap.start();
  ref.onDispose(bootstrap.dispose);
});
