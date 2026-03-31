import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';

final liveTrackingEventRepositoryProvider =
    Provider<LiveTrackingEventRepository>((ref) {
  final trackingEventDao = ref.watch(trackingEventDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  return LiveTrackingEventRepository(
    trackingEventDao: trackingEventDao,
    syncTaskDao: syncTaskDao,
  );
});

final liveTrackingEventsProvider =
    StreamProvider.autoDispose.family<List<TrackingEventRow>, String>((
  ref,
  tripId,
) {
  final repository = ref.watch(liveTrackingEventRepositoryProvider);
  return repository.watchEventsForTrip(tripId);
});
