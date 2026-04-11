import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/event_journal_table.dart';

part 'event_journal_dao.g.dart';

@DriftAccessor(tables: [EventJournal])
class EventJournalDao extends DatabaseAccessor<AppDatabase>
    with _$EventJournalDaoMixin {
  EventJournalDao(super.db);

  Future<EventJournalRow?> getEventById(String eventId) =>
      (select(eventJournal)..where((row) => row.eventId.equals(eventId)))
          .getSingleOrNull();

  Future<int> upsertEvent(EventJournalCompanion row) =>
      into(eventJournal).insertOnConflictUpdate(row);

  Future<List<EventJournalRow>> listEventsForSession(String sessionId) =>
      (select(eventJournal)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.eventSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<List<EventJournalRow>> listEventsForTrip(String tripLocalId) =>
      (select(eventJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Future<List<EventJournalRow>> listEventsForTripChronological(
    String tripLocalId,
  ) =>
      (select(eventJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
              (row) => OrderingTerm(
                    expression: row.eventSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<List<EventJournalRow>> listEventsForTripFromCapturedAt(
    String tripLocalId,
    DateTime fromCapturedAt,
  ) =>
      (select(eventJournal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.capturedAt.isBiggerOrEqualValue(fromCapturedAt.toUtc()),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
              (row) => OrderingTerm(
                    expression: row.eventSeq,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Stream<List<EventJournalRow>> watchEventsForTrip(String tripLocalId) =>
      (select(eventJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<List<EventJournalRow>> listUnresolvedEventsForTrip(
    String tripLocalId, {
    int limit = 50,
  }) =>
      (select(eventJournal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.resolverState
                      .isIn(const ['geotag_unresolved', 'review_required']),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .get();

  Stream<List<EventJournalRow>> watchUnresolvedEventsForTrip(
    String tripLocalId, {
    int limit = 50,
  }) =>
      (select(eventJournal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.resolverState
                      .isIn(const ['geotag_unresolved', 'review_required']),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(limit))
          .watch();

  Future<int> updateResolverOutcome({
    required String eventId,
    required String resolverState,
    String? decisionSource,
    int? manualLock,
    String? placeBindKind,
    String? placeBindId,
    String? placeBindName,
    String? geotagFinalReason,
    int? candidateSetVersion,
    DateTime? resolvedAt,
    DateTime? updatedAt,
  }) {
    return (update(eventJournal)..where((row) => row.eventId.equals(eventId)))
        .write(
      EventJournalCompanion(
        resolverState: Value(resolverState),
        decisionSource: Value(decisionSource),
        manualLock:
            manualLock == null ? const Value.absent() : Value(manualLock),
        placeBindKind: Value(placeBindKind),
        placeBindId: Value(placeBindId),
        placeBindName: Value(placeBindName),
        geotagFinalReason: Value(geotagFinalReason),
        candidateSetVersion: candidateSetVersion == null
            ? const Value.absent()
            : Value(candidateSetVersion),
        resolvedAt: Value(resolvedAt?.toUtc()),
        updatedAt: Value((updatedAt ?? DateTime.now()).toUtc()),
      ),
    );
  }
}
