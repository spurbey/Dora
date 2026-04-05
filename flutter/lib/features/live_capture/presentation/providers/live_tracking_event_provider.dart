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
    required this.reviewRequiredCount,
    required this.onRouteCount,
    required this.latestReviewRequired,
    required this.reviewHints,
  });

  /// Events that genuinely need user place confirmation.
  final int reviewRequiredCount;
  /// Events correctly tagged to route (valid state, not an error).
  final int onRouteCount;
  final TrackingEventRow? latestReviewRequired;
  final List<LiveTrackingPlaceHint> reviewHints;

  bool get hasReviewRequired => reviewRequiredCount > 0;
  bool get hasReviewPrompt =>
      latestReviewRequired != null && reviewHints.isNotEmpty;
}

final liveTrackingUnresolvedSummaryProvider =
    Provider.family<LiveTrackingUnresolvedSummary, String>((ref, tripId) {
  final events = ref.watch(liveTrackingEventsProvider(tripId)).valueOrNull ??
      const <TrackingEventRow>[];
  final repository = ref.watch(liveTrackingEventRepositoryProvider);

  var reviewRequiredCount = 0;
  var onRouteCount = 0;
  TrackingEventRow? reviewEvent;

  for (final event in events) {
    final state = event.resolverState.trim();
    if (state == 'review_required') {
      reviewRequiredCount++;
      reviewEvent ??= event;
    } else if (state == 'on_route_unresolved') {
      onRouteCount++;
    }
  }

  final reviewHints = reviewEvent != null
      ? repository.parsePlaceHints(reviewEvent.resolutionHintJson)
      : const <LiveTrackingPlaceHint>[];
  return LiveTrackingUnresolvedSummary(
    reviewRequiredCount: reviewRequiredCount,
    onRouteCount: onRouteCount,
    latestReviewRequired: reviewEvent,
    reviewHints: reviewHints,
  );
});
