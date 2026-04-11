import 'package:drift/drift.dart';

@TableIndex(
  name: 'session_commit_media_item_job_state_idx',
  columns: {#jobId, #uploadState},
)
@TableIndex(
  name: 'session_commit_media_item_media_idx',
  columns: {#mediaId},
)
@DataClassName('SessionCommitMediaItemRow')
class SessionCommitMediaItem extends Table {
  @override
  String get tableName => 'session_commit_media_item';

  TextColumn get itemId => text()();
  TextColumn get jobId => text()();
  TextColumn get mediaId => text()();
  TextColumn get uploadState => text()();
  TextColumn get localUri => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get bytesSize => integer().nullable()();
  TextColumn get uploadRef => text().nullable()();
  TextColumn get remoteChecksum => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

