import 'package:drift/drift.dart';

@TableIndex(
  name: 'session_journal_trip_state_updated_idx',
  columns: {#tripLocalId, #controlState, #updatedAt},
)
@TableIndex(
  name: 'session_journal_trip_started_idx',
  columns: {#tripLocalId, #startedAt},
)
@DataClassName('SessionJournalRow')
class SessionJournal extends Table {
  @override
  String get tableName => 'session_journal';

  TextColumn get sessionId => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get serverTripId => text().nullable()();
  TextColumn get controlState => text()();
  IntColumn get stopServerPending => integer().withDefault(const Constant(0))();
  DateTimeColumn get startAckAt => dateTime().nullable()();
  DateTimeColumn get stopAckAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get stopClientEventId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sealVersion => integer().withDefault(const Constant(0))();
  IntColumn get startRequestSeq => integer().withDefault(const Constant(0))();
  IntColumn get sessionSeq => integer()();
  TextColumn get deviceId => text()();

  @override
  Set<Column<Object>> get primaryKey => {sessionId};
}
