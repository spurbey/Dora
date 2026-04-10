import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/database_provider.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/media_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/resolver_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

final v2SessionJournalRepositoryProvider =
    Provider<V2SessionJournalRepository>((ref) {
  final dao = ref.watch(v2SessionJournalDaoProvider);
  return V2SessionJournalRepository(dao);
});

final v2RoutePointJournalRepositoryProvider =
    Provider<V2RoutePointJournalRepository>((ref) {
  final dao = ref.watch(v2RoutePointJournalDaoProvider);
  return V2RoutePointJournalRepository(dao);
});

final v2EventJournalRepositoryProvider = Provider<V2EventJournalRepository>(
  (ref) {
    final dao = ref.watch(v2EventJournalDaoProvider);
    return V2EventJournalRepository(dao);
  },
);

final v2MediaJournalRepositoryProvider = Provider<V2MediaJournalRepository>(
  (ref) {
    final dao = ref.watch(v2MediaJournalDaoProvider);
    return V2MediaJournalRepository(dao);
  },
);

final v2ResolverJournalRepositoryProvider =
    Provider<V2ResolverJournalRepository>((ref) {
  final candidateDao = ref.watch(v2ResolverCandidateJournalDaoProvider);
  final attemptDao = ref.watch(v2ResolverAttemptJournalDaoProvider);
  return V2ResolverJournalRepository(
    resolverCandidateDao: candidateDao,
    resolverAttemptDao: attemptDao,
  );
});
