import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_events_trip_created_idx',
  columns: {#tripId, #createdAt},
)
@TableIndex(
  name: 'tracking_events_sync_updated_idx',
  columns: {#syncStatus, #updatedAt},
)
@DataClassName('TrackingEventRow')
class TrackingEvents extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get eventType => text()();
  TextColumn get note => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get clientEventId => text().nullable()();

  // Sync metadata (local-only in C2/C3 slice)
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
