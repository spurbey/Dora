import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_candidate_repository.dart';

final liveTrackingCandidateRepositoryProvider =
    Provider<LiveTrackingCandidateRepository>((ref) {
  final trackingCandidateDao = ref.watch(trackingCandidateDaoProvider);
  final syncTaskDao = ref.watch(syncTaskDaoProvider);
  return LiveTrackingCandidateRepository(
    trackingCandidateDao: trackingCandidateDao,
    syncTaskDao: syncTaskDao,
  );
});

final liveTrackingCandidateInboxProvider =
    StreamProvider.autoDispose.family<List<TrackingCandidateRow>, String>(
  (ref, tripId) {
    final repository = ref.watch(liveTrackingCandidateRepositoryProvider);
    return repository.watchInboxCandidates(tripId);
  },
);
