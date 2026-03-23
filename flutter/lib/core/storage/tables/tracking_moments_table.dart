import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_moments_trip_captured_idx',
  columns: {#tripId, #capturedAt},
)
@TableIndex(
  name: 'tracking_moments_sync_pending_idx',
  columns: {#syncStatus, #pendingOperation, #updatedAt},
)
@DataClassName('TrackingMomentRow')
class TrackingMoments extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get candidateId => text().nullable()();
  TextColumn get linkedTripPlaceId => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  RealColumn get confidence => real().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get mediaRefsJson => text().withDefault(const Constant('[]'))();
  TextColumn get extraPayloadJson => text().withDefault(const Constant('{}'))();
  TextColumn get lockedFieldsJson => text().withDefault(const Constant('{}'))();

  // Local pending write operation: create | update | null
  TextColumn get pendingOperation => text().nullable()();
  TextColumn get clientEventId => text().nullable()();

  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
