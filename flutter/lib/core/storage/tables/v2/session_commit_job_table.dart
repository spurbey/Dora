import 'package:drift/drift.dart';

@TableIndex(
  name: 'session_commit_job_state_retry_idx',
  columns: {#jobState, #nextRetryAt},
)
@TableIndex(
  name: 'session_commit_job_session_idx',
  columns: {#sessionId},
)
@TableIndex(
  name: 'session_commit_job_trip_created_idx',
  columns: {#tripLocalId, #createdAt},
)
@DataClassName('SessionCommitJobRow')
class SessionCommitJob extends Table {
  @override
  String get tableName => 'session_commit_job';

  TextColumn get jobId => text()();
  TextColumn get sessionId => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get serverTripId => text().nullable()();
  TextColumn get jobState => text()();
  TextColumn get phase => text()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  TextColumn get idempotencyKey => text()();
  TextColumn get sessionCommitToken => text().nullable()();
  IntColumn get isExecuting => integer().withDefault(const Constant(0))();
  DateTimeColumn get executionStartedAt => dateTime().nullable()();
  TextColumn get executionOwnerId => text().nullable()();
  IntColumn get leaseVersion => integer().withDefault(const Constant(0))();
  TextColumn get snapshotHash => text().nullable()();
  DateTimeColumn get snapshotCreatedAt => dateTime().nullable()();
  IntColumn get snapshotEventCount => integer().withDefault(const Constant(0))();
  IntColumn get snapshotMediaCount => integer().withDefault(const Constant(0))();
  IntColumn get snapshotPointCount => integer().withDefault(const Constant(0))();
  IntColumn get snapshotPayloadBytes =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {jobId};
}

