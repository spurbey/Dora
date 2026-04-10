import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/resolver_attempt_journal_table.dart';

part 'resolver_attempt_journal_dao.g.dart';

@DriftAccessor(tables: [ResolverAttemptJournal])
class ResolverAttemptJournalDao extends DatabaseAccessor<AppDatabase>
    with _$ResolverAttemptJournalDaoMixin {
  ResolverAttemptJournalDao(super.db);

  Future<ResolverAttemptJournalRow?> getAttemptById(String attemptId) =>
      (select(resolverAttemptJournal)
            ..where((row) => row.attemptId.equals(attemptId))
            ..limit(1))
          .getSingleOrNull();

  Future<int> upsertAttempt(ResolverAttemptJournalCompanion row) =>
      into(resolverAttemptJournal).insertOnConflictUpdate(row);

  Future<List<ResolverAttemptJournalRow>> listAttemptsForEvent(
          String eventId) =>
      (select(resolverAttemptJournal)
            ..where((row) => row.eventId.equals(eventId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.attemptNo,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<ResolverAttemptJournalRow>> watchAttemptsForEvent(
    String eventId,
  ) =>
      (select(resolverAttemptJournal)
            ..where((row) => row.eventId.equals(eventId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.attemptNo,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();
}
