import 'package:drift/drift.dart';

@TableIndex(
  name: 'session_commit_chunk_job_state_idx',
  columns: {#jobId, #chunkState},
)
@DataClassName('SessionCommitChunkRow')
class SessionCommitChunk extends Table {
  @override
  String get tableName => 'session_commit_chunk';

  TextColumn get chunkId => text()();
  TextColumn get jobId => text()();
  IntColumn get chunkIndex => integer()();
  IntColumn get totalChunks => integer()();
  IntColumn get byteSize => integer()();
  TextColumn get contentHash => text()();
  TextColumn get payloadJson => text()();
  TextColumn get chunkState => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  TextColumn get lastErrorCode => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {chunkId};
}

