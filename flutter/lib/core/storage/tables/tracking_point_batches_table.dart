import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_point_batches_claim_idx',
  columns: {#status, #nextAttemptAt, #workerSessionId, #createdAt},
)
@TableIndex(
  name: 'tracking_point_batches_trip_created_idx',
  columns: {#tripId, #createdAt},
)
@TableIndex(
  name: 'tracking_point_batches_session_created_idx',
  columns: {#sessionId, #createdAt},
)
@DataClassName('TrackingPointBatchRow')
class TrackingPointBatches extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get sessionId => text()();
  TextColumn get remoteSessionId => text().nullable()();
  TextColumn get clientBatchId => text()();

  DateTimeColumn get firstRecordedAt => dateTime().nullable()();
  DateTimeColumn get lastRecordedAt => dateTime().nullable()();
  IntColumn get pointCount => integer().withDefault(const Constant(0))();
  TextColumn get pointsJson => text().withDefault(const Constant('[]'))();

  // Queue lifecycle: queued | in_progress | failed | completed | dropped_stale_session
  TextColumn get status => text().withDefault(const Constant('queued'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get workerSessionId => text().nullable()();
  TextColumn get lastError => text().nullable()();

  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>>? get uniqueKeys => [
        {clientBatchId},
      ];
}
