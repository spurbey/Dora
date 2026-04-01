import 'package:drift/drift.dart';

@TableIndex(
  name: 'tracking_event_media_event_created_idx',
  columns: {#eventId, #createdAt},
)
@TableIndex(
  name: 'tracking_event_media_status_updated_idx',
  columns: {#uploadStatus, #updatedAt},
)
@TableIndex(
  name: 'tracking_event_media_trip_bind_state_created_idx',
  columns: {#tripId, #bindState, #createdAt},
)
@TableIndex(
  name: 'tracking_event_media_sync_updated_idx',
  columns: {#syncStatus, #updatedAt},
)
@DataClassName('TrackingEventMediaRow')
class TrackingEventMedia extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get eventId => text()();
  TextColumn get bindMode => text().withDefault(const Constant('route'))();
  // Workflow state of media lane. This is the source-of-truth state used by
  // resolver/sync orchestration.
  TextColumn get bindState =>
      text().withDefault(const Constant('awaiting_bind_choice'))();
  TextColumn get tripPlaceId => text().nullable()();
  RealColumn get anchorLatitude => real().nullable()();
  RealColumn get anchorLongitude => real().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get localPath => text()();
  TextColumn get uploadRef => text().nullable()();
  TextColumn get remoteMediaId => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  // UI compatibility mirror of bindState; kept to avoid breaking older reads.
  TextColumn get uploadStatus =>
      text().withDefault(const Constant('awaiting_bind_choice'))();
  RealColumn get uploadProgress => real().withDefault(const Constant(0.0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get workerSessionId => text().nullable()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();

  // Sync metadata (local-only foundation in C2/C3 slice)
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
