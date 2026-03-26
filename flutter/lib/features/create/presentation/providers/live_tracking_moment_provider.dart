import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_moment_repository.dart';

final liveTrackingMomentRepositoryProvider =
    Provider<LiveTrackingMomentRepository>((ref) {
  final trackingMomentDao = ref.watch(trackingMomentDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  return LiveTrackingMomentRepository(
    trackingMomentDao: trackingMomentDao,
    syncTaskDao: syncTaskDao,
  );
});

final liveTrackingMomentsProvider =
    StreamProvider.autoDispose.family<List<TrackingMomentRow>, String>((
  ref,
  tripId,
) {
  final repository = ref.watch(liveTrackingMomentRepositoryProvider);
  return repository.watchMomentsForTrip(tripId);
});
