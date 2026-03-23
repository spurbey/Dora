import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_candidates_trip_created_idx',
  columns: {#tripId, #createdAt},
)
@TableIndex(
  name: 'tracking_candidates_trip_status_updated_idx',
  columns: {#tripId, #status, #updatedAt},
)
@TableIndex(
  name: 'tracking_candidates_action_queue_idx',
  columns: {#actionState, #syncStatus, #actionQueuedAt},
)
@DataClassName('TrackingCandidateRow')
class TrackingCandidates extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get fingerprint => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  RealColumn get confidence => real().nullable()();
  TextColumn get suggestedName => text().nullable()();
  RealColumn get suggestedLatitude => real().nullable()();
  RealColumn get suggestedLongitude => real().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get confirmedTripPlaceId => text().nullable()();
  TextColumn get rejectedReason => text().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  DateTimeColumn get cooldownUntil => dateTime().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();

  // Notification visibility mirrors backend inbox/push delivery state.
  TextColumn get notificationState => text().nullable()();

  // Local decision queue metadata: none | queued | synced | failed
  TextColumn get actionState => text().withDefault(const Constant('none'))();
  TextColumn get actionType => text().nullable()();
  TextColumn get actionClientEventId => text().nullable()();
  DateTimeColumn get actionQueuedAt => dateTime().nullable()();
  DateTimeColumn get actionSyncedAt => dateTime().nullable()();

  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
