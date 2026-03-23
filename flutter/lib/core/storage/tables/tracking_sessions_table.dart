import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_sessions_trip_state_updated_idx',
  columns: {#tripId, #state, #localUpdatedAt},
)
@TableIndex(
  name: 'tracking_sessions_trip_updated_idx',
  columns: {#tripId, #updatedAt},
)
@DataClassName('TrackingSessionRow')
class TrackingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get remoteSessionId => text().nullable()();
  TextColumn get clientSessionId => text()();

  // Local runtime lifecycle: planned | active | paused | ended | abandoned
  TextColumn get state => text().withDefault(const Constant('planned'))();

  TextColumn get timezone => text().nullable()();
  TextColumn get deviceContextJson =>
      text().withDefault(const Constant('{}'))();

  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get resumedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  DateTimeColumn get abandonedAt => dateTime().nullable()();
  DateTimeColumn get lastPointAt => dateTime().nullable()();
  DateTimeColumn get lastFlushAt => dateTime().nullable()();

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
        {tripId, clientSessionId},
      ];
}
