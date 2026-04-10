import 'package:drift/drift.dart';

@TableIndex(
  name: 'event_journal_session_captured_idx',
  columns: {#sessionId, #capturedAt},
)
@TableIndex(
  name: 'event_journal_trip_resolver_captured_idx',
  columns: {#tripLocalId, #resolverState, #capturedAt},
)
@TableIndex(
  name: 'event_journal_trip_manual_resolver_idx',
  columns: {#tripLocalId, #manualLock, #resolverState},
)
@TableIndex(
  name: 'event_journal_session_seq_idx',
  columns: {#sessionId, #eventSeq},
)
@DataClassName('EventJournalRow')
class EventJournal extends Table {
  @override
  String get tableName => 'event_journal';

  TextColumn get eventId => text()();
  TextColumn get sessionId => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get capturedAt => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get anchorAccuracyM => real().nullable()();
  TextColumn get payloadJson => text().nullable()();
  TextColumn get resolverState => text()();
  TextColumn get decisionSource => text().nullable()();
  IntColumn get manualLock => integer().withDefault(const Constant(0))();
  TextColumn get placeBindKind => text().nullable()();
  TextColumn get placeBindId => text().nullable()();
  TextColumn get placeBindName => text().nullable()();
  TextColumn get geotagFinalReason => text().nullable()();
  IntColumn get capturedWhilePaused =>
      integer().withDefault(const Constant(0))();
  IntColumn get candidateSetVersion =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get eventSeq => integer()();

  @override
  Set<Column<Object>> get primaryKey => {eventId};
}
