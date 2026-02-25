import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/sync/entity_sync_bootstrap.dart';
import 'package:dora/core/sync/entity_sync_worker.dart';
import 'package:dora/features/create/presentation/providers/editor_provider.dart';

final entitySyncWorkerProvider = Provider<EntitySyncWorker>((ref) {
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);
  final placeRepository = ref.watch(placeRepositoryProvider);
  final routeRepository = ref.watch(routeRepositoryProvider);
  return EntitySyncWorker(
    syncTaskDao: syncTaskDao,
    tripRepository: tripRepository,
    placeRepository: placeRepository,
    routeRepository: routeRepository,
  );
});

final entitySyncBootstrapProvider = Provider<void>((ref) {
  final worker = ref.watch(entitySyncWorkerProvider);
  final bootstrap = EntitySyncBootstrap(worker);
  bootstrap.start();
  ref.onDispose(bootstrap.dispose);
});
