import 'package:drift/drift.dart';

@TableIndex(
  name: 'media_journal_event_idx',
  columns: {#eventId},
)
@TableIndex(
  name: 'media_journal_session_upload_state_idx',
  columns: {#sessionId, #uploadState},
)
@TableIndex(
  name: 'media_journal_trip_captured_idx',
  columns: {#tripLocalId, #capturedAt},
)
@DataClassName('MediaJournalRow')
class MediaJournal extends Table {
  @override
  String get tableName => 'media_journal';

  TextColumn get mediaId => text()();
  TextColumn get eventId => text()();
  TextColumn get sessionId => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get mediaType => text()();
  TextColumn get localUri => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get bytesSize => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get widthPx => integer().nullable()();
  IntColumn get heightPx => integer().nullable()();
  TextColumn get uploadState =>
      text().withDefault(const Constant('local_only'))();
  TextColumn get uploadRef => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}
