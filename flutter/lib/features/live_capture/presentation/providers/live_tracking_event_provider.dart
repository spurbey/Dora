import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/map/geocoding/geocoding_provider.dart';
import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_repository.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_resolver.dart';

final liveTrackingEventResolverProvider = Provider<LiveTrackingEventResolver>((
  ref,
) {
  final trackingEventDao = ref.watch(trackingEventDaoProvider);
  final placeDao = ref.watch(appDatabaseProvider).placeDao;
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  final geocodingService = ref.watch(geocodingServiceProvider);
  return LiveTrackingEventResolver(
    trackingEventDao: trackingEventDao,
    placeDao: placeDao,
    syncTaskDao: syncTaskDao,
    geocodingService: geocodingService,
  );
});

final liveTrackingEventRepositoryProvider =
    Provider<LiveTrackingEventRepository>((ref) {
  final trackingEventDao = ref.watch(trackingEventDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  final resolver = ref.watch(liveTrackingEventResolverProvider);
  return LiveTrackingEventRepository(
    trackingEventDao: trackingEventDao,
    syncTaskDao: syncTaskDao,
    resolver: resolver,
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

class LiveTrackingUnresolvedSummary {
  const LiveTrackingUnresolvedSummary({
    required this.unresolvedCount,
    required this.latestUnresolved,
  });

  final int unresolvedCount;
  final TrackingEventRow? latestUnresolved;

  bool get hasUnresolved => unresolvedCount > 0;
}

final liveTrackingUnresolvedSummaryProvider =
    Provider.family<LiveTrackingUnresolvedSummary, String>((ref, tripId) {
  final events = ref.watch(liveTrackingEventsProvider(tripId)).valueOrNull ??
      const <TrackingEventRow>[];
  final unresolved = events
      .where((event) => event.resolverState != 'resolved')
      .toList(growable: false);
  return LiveTrackingUnresolvedSummary(
    unresolvedCount: unresolved.length,
    latestUnresolved: unresolved.isEmpty ? null : unresolved.first,
  );
});
