import 'package:drift/drift.dart';

@TableIndex(
  name: 'session_activity_window_session_seq_idx',
  columns: {#sessionId, #windowSeq},
)
@TableIndex(
  name: 'session_activity_window_session_started_idx',
  columns: {#sessionId, #startedAt},
)
@DataClassName('SessionActivityWindowRow')
class SessionActivityWindow extends Table {
  @override
  String get tableName => 'session_activity_window';

  TextColumn get windowId => text()();
  TextColumn get sessionId => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get windowKind => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get windowSeq => integer()();

  @override
  Set<Column<Object>> get primaryKey => {windowId};
}
