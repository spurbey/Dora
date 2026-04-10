import 'package:drift/drift.dart';

@TableIndex(
  name: 'resolver_attempt_journal_event_attempt_idx',
  columns: {#eventId, #attemptNo},
)
@TableIndex(
  name: 'resolver_attempt_journal_started_idx',
  columns: {#startedAt},
)
@DataClassName('ResolverAttemptJournalRow')
class ResolverAttemptJournal extends Table {
  @override
  String get tableName => 'resolver_attempt_journal';

  TextColumn get attemptId => text()();
  TextColumn get eventId => text()();
  IntColumn get attemptNo => integer()();
  TextColumn get triggerReason => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get resultKind => text()();
  TextColumn get errorCode => text().nullable()();
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {attemptId};
}
