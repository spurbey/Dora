import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/resolver/v2_resolver_models.dart';
import 'package:dora/features/live_tracking/v2/v2_providers.dart';

class V2UnresolvedInboxItem {
  const V2UnresolvedInboxItem({
    required this.eventId,
    required this.tripLocalId,
    required this.sessionId,
    required this.eventType,
    required this.capturedAt,
    required this.resolverState,
    required this.manualLock,
    required this.topCandidates,
    required this.lastActivityAt,
  });

  final String eventId;
  final String tripLocalId;
  final String sessionId;
  final String eventType;
  final DateTime capturedAt;
  final String resolverState;
  final int manualLock;
  final List<V2ResolverCandidate> topCandidates;
  final DateTime lastActivityAt;
}

class V2UnresolvedReviewController {
  const V2UnresolvedReviewController({
    required this.ref,
  });

  final Ref ref;

  Future<void> acceptCandidate({
    required String eventId,
    required V2ResolverCandidate candidate,
  }) {
    return ref.read(v2ResolverOrchestratorProvider).acceptCandidate(
          eventId: eventId,
          candidate: candidate,
        );
  }

  Future<void> keepGeotag({
    required String eventId,
    bool fromManualAddCancel = false,
  }) {
    return ref.read(v2ResolverOrchestratorProvider).keepGeotag(
          eventId: eventId,
          reason:
              fromManualAddCancel ? 'manual_add_cancelled' : 'user_keep_geotag',
        );
  }

  Future<void> assignManualPlace({
    required String eventId,
    required String placeId,
    required String placeName,
  }) {
    return ref.read(v2ResolverOrchestratorProvider).assignManualPlace(
          eventId: eventId,
          placeId: placeId,
          placeName: placeName,
        );
  }
}

final v2UnresolvedReviewControllerProvider =
    Provider<V2UnresolvedReviewController>((ref) {
  return V2UnresolvedReviewController(ref: ref);
});

final v2UnresolvedInboxProvider =
    StreamProvider.autoDispose.family<List<V2UnresolvedInboxItem>, String>(
  (ref, tripId) {
  final eventRepository = ref.watch(v2EventJournalRepositoryProvider);
  final resolverRepository = ref.watch(v2ResolverJournalRepositoryProvider);
  return eventRepository
      .watchUnresolvedEventsForTrip(tripId, limit: 20)
      .asyncMap((events) async {
      final inbox = <V2UnresolvedInboxItem>[];
      final eventIds = events.map((event) => event.eventId).toList();
      final allCandidates =
          await resolverRepository.listCandidatesForEvents(eventIds);
      final latestByEvent = _latestCandidatesByEvent(allCandidates, limit: 3);
      for (final event in events) {
        final candidates = latestByEvent[event.eventId] ??
            const <ResolverCandidateJournalRow>[];
        final normalizedCandidates =
            candidates.map(_toCandidate).toList(growable: false);
        final lastActivityAt = _resolveLastActivityAt(
          event: event,
          candidates: candidates,
        );
        inbox.add(
          V2UnresolvedInboxItem(
            eventId: event.eventId,
            tripLocalId: event.tripLocalId,
            sessionId: event.sessionId,
            eventType: event.eventType,
            capturedAt: event.capturedAt,
            resolverState: event.resolverState,
            manualLock: event.manualLock,
            topCandidates: normalizedCandidates,
            lastActivityAt: lastActivityAt,
          ),
        );
      }
      inbox.sort((a, b) {
        final aPriority = _resolverPriority(a.resolverState);
        final bPriority = _resolverPriority(b.resolverState);
        final byPriority = aPriority.compareTo(bPriority);
        if (byPriority != 0) {
          return byPriority;
        }
        return b.capturedAt.compareTo(a.capturedAt);
      });
      return inbox;
    });
  },
);

V2ResolverCandidate _toCandidate(ResolverCandidateJournalRow row) {
  return V2ResolverCandidate(
    providerPlaceId: row.providerPlaceId,
    name: row.name,
    label: row.label,
    coordinates: AppLatLng(
      latitude: row.latitude,
      longitude: row.longitude,
    ),
    confidenceScore: row.confidenceScore ?? 0,
    distanceM: row.distanceM ?? 0,
    rawJson: const <String, dynamic>{},
  );
}

DateTime _resolveLastActivityAt({
  required EventJournalRow event,
  required List<ResolverCandidateJournalRow> candidates,
}) {
  if (candidates.isEmpty) {
    return event.updatedAt;
  }
  var maxValue = event.updatedAt;
  for (final candidate in candidates) {
    if (candidate.createdAt.isAfter(maxValue)) {
      maxValue = candidate.createdAt;
    }
  }
  return maxValue;
}

int _resolverPriority(String state) {
  switch (state) {
    case 'review_required':
      return 0;
    case 'geotag_unresolved':
      return 1;
    default:
      return 2;
  }
}

Map<String, List<ResolverCandidateJournalRow>> _latestCandidatesByEvent(
  List<ResolverCandidateJournalRow> rows, {
  int limit = 3,
}) {
  if (rows.isEmpty) {
    return const <String, List<ResolverCandidateJournalRow>>{};
  }
  final Map<String, List<ResolverCandidateJournalRow>> result =
      <String, List<ResolverCandidateJournalRow>>{};
  final Map<String, int> latestVersion = <String, int>{};
  for (final row in rows) {
    final current = latestVersion[row.eventId];
    if (current == null || row.candidateVersion > current) {
      latestVersion[row.eventId] = row.candidateVersion;
    }
  }
  for (final row in rows) {
    final version = latestVersion[row.eventId];
    if (version == null || row.candidateVersion != version) {
      continue;
    }
    final list = result.putIfAbsent(
      row.eventId,
      () => <ResolverCandidateJournalRow>[],
    );
    if (list.length < limit) {
      list.add(row);
    }
  }
  return result;
}
