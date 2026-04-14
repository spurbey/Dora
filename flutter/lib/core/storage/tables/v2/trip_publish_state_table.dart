import 'package:drift/drift.dart';

@TableIndex(
  name: 'trip_publish_state_state_updated_idx',
  columns: {#publishState, #updatedAt},
)
@DataClassName('TripPublishStateRow')
class TripPublishState extends Table {
  @override
  String get tableName => 'trip_publish_state';

  TextColumn get tripLocalId => text()();
  TextColumn get publishState =>
      text().withDefault(const Constant('publish_pending'))();
  TextColumn get publishJobId => text().nullable()();
  TextColumn get lastSavedSnapshotDigest => text().nullable()();
  DateTimeColumn get lastSavedAt => dateTime().nullable()();
  TextColumn get lastPublishedSnapshotDigest => text().nullable()();
  DateTimeColumn get lastPublishedAt => dateTime().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {tripLocalId};
}
