import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/session_activity_window_table.dart';
import 'package:dora/core/storage/tables/v2/session_journal_table.dart';

part 'session_journal_dao.g.dart';

@DriftAccessor(tables: [SessionJournal, SessionActivityWindow])
class SessionJournalDao extends DatabaseAccessor<AppDatabase>
    with _$SessionJournalDaoMixin {
  SessionJournalDao(super.db);

  Future<SessionJournalRow?> getSessionById(String sessionId) =>
      (select(sessionJournal)
            ..where((row) => row.sessionId.equals(sessionId))
            ..limit(1))
          .getSingleOrNull();

  Future<List<SessionJournalRow>> listSessionsForTrip(String tripLocalId) =>
      (select(sessionJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Stream<List<SessionJournalRow>> watchSessionsForTrip(String tripLocalId) =>
      (select(sessionJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<SessionJournalRow?> getLatestSessionForTrip(String tripLocalId) =>
      (select(sessionJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Stream<SessionJournalRow?> watchLatestSessionForTrip(String tripLocalId) =>
      (select(sessionJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .watchSingleOrNull();

  Future<SessionJournalRow?> getActiveOrPausedSessionForTrip(
          String tripLocalId) =>
      (select(sessionJournal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.controlState.isIn(const ['active', 'paused']),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<SessionJournalRow>> listSessionsByStates(Set<String> states) {
    if (states.isEmpty) {
      return Future<List<SessionJournalRow>>.value(
        const <SessionJournalRow>[],
      );
    }
    return (select(sessionJournal)
          ..where((row) => row.controlState.isIn(states.toList()))
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.updatedAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  Future<int> upsertSession(SessionJournalCompanion row) =>
      into(sessionJournal).insertOnConflictUpdate(row);

  Future<int> upsertActivityWindow(SessionActivityWindowCompanion row) =>
      into(sessionActivityWindow).insertOnConflictUpdate(row);

  Future<List<SessionActivityWindowRow>> listActivityWindowsForSession(
    String sessionId,
  ) =>
      (select(sessionActivityWindow)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.windowSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Stream<List<SessionActivityWindowRow>> watchActivityWindowsForSession(
    String sessionId,
  ) =>
      (select(sessionActivityWindow)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.windowSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .watch();
}
