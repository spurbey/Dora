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
  final trackingEventMediaDao = ref.watch(trackingEventMediaDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  final resolver = ref.watch(liveTrackingEventResolverProvider);
  return LiveTrackingEventRepository(
    trackingEventDao: trackingEventDao,
    trackingEventMediaDao: trackingEventMediaDao,
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
    required this.latestReviewRequired,
    required this.reviewHints,
  });

  final int unresolvedCount;
  final TrackingEventRow? latestUnresolved;
  final TrackingEventRow? latestReviewRequired;
  final List<LiveTrackingPlaceHint> reviewHints;

  bool get hasUnresolved => unresolvedCount > 0;
  bool get hasReviewPrompt =>
      latestReviewRequired != null && reviewHints.isNotEmpty;
}

final liveTrackingUnresolvedSummaryProvider =
    Provider.family<LiveTrackingUnresolvedSummary, String>((ref, tripId) {
  final events = ref.watch(liveTrackingEventsProvider(tripId)).valueOrNull ??
      const <TrackingEventRow>[];
  final repository = ref.watch(liveTrackingEventRepositoryProvider);
  final unresolved = events
      .where((event) => event.resolverState != 'resolved')
      .toList(growable: false);
  TrackingEventRow? reviewEvent;
  for (final event in unresolved) {
    if (event.resolverState == 'review_required') {
      reviewEvent = event;
      break;
    }
  }
  final reviewHints = reviewEvent != null
      ? repository.parsePlaceHints(reviewEvent.resolutionHintJson)
      : const <LiveTrackingPlaceHint>[];
  return LiveTrackingUnresolvedSummary(
    unresolvedCount: unresolved.length,
    latestUnresolved: unresolved.isEmpty ? null : unresolved.first,
    latestReviewRequired: reviewEvent,
    reviewHints: reviewHints,
  );
});
