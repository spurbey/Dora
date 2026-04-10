import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/resolver_candidate_journal_table.dart';

part 'resolver_candidate_journal_dao.g.dart';

@DriftAccessor(tables: [ResolverCandidateJournal])
class ResolverCandidateJournalDao extends DatabaseAccessor<AppDatabase>
    with _$ResolverCandidateJournalDaoMixin {
  ResolverCandidateJournalDao(super.db);

  Future<int> upsertCandidate(ResolverCandidateJournalCompanion row) =>
      into(resolverCandidateJournal).insertOnConflictUpdate(row);

  Future<List<ResolverCandidateJournalRow>> listCandidatesForEvent(
    String eventId,
  ) =>
      (select(resolverCandidateJournal)
            ..where((row) => row.eventId.equals(eventId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.candidateVersion,
                    mode: OrderingMode.desc,
                  ),
              (row) => OrderingTerm(
                    expression: row.rankIndex,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<List<ResolverCandidateJournalRow>> listLatestCandidatesForEvent(
    String eventId, {
    int limit = 3,
  }) async {
    final candidates = await listCandidatesForEvent(eventId);
    if (candidates.isEmpty) {
      return const <ResolverCandidateJournalRow>[];
    }
    final latestVersion = candidates.first.candidateVersion;
    return candidates
        .where((candidate) => candidate.candidateVersion == latestVersion)
        .take(limit)
        .toList(growable: false);
  }

  Stream<List<ResolverCandidateJournalRow>> watchLatestCandidatesForEvent(
    String eventId, {
    int limit = 3,
  }) {
    return (select(resolverCandidateJournal)
          ..where((row) => row.eventId.equals(eventId))
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.candidateVersion,
                  mode: OrderingMode.desc,
                ),
            (row) => OrderingTerm(
                  expression: row.rankIndex,
                  mode: OrderingMode.asc,
                ),
          ]))
        .watch()
        .map((candidates) {
      if (candidates.isEmpty) {
        return const <ResolverCandidateJournalRow>[];
      }
      final latestVersion = candidates.first.candidateVersion;
      return candidates
          .where((candidate) => candidate.candidateVersion == latestVersion)
          .take(limit)
          .toList(growable: false);
    });
  }
}
