import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_event_media_event_created_idx',
  columns: {#eventId, #createdAt},
)
@TableIndex(
  name: 'tracking_event_media_status_updated_idx',
  columns: {#uploadStatus, #updatedAt},
)
@DataClassName('TrackingEventMediaRow')
class TrackingEventMedia extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get eventId => text()();
  TextColumn get localPath => text()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get uploadStatus =>
      text().withDefault(const Constant('awaiting_place_binding'))();
  RealColumn get uploadProgress => real().withDefault(const Constant(0.0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get workerSessionId => text().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();

  // Sync metadata (local-only foundation in C2/C3 slice)
  TextColumn get syncStatus =>
      text().withDefault(const Constant('local_only'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
