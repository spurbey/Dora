import 'package:drift/drift.dart';

@TableIndex(
  name: 'media_owner_captured_idx',
  columns: {#ownerUserId, #capturedAt},
)
@TableIndex(
  name: 'media_upload_state_next_attempt_idx',
  columns: {#uploadState, #nextAttemptAt},
)
@TableIndex(
  name: 'media_origin_captured_idx',
  columns: {#originScope, #capturedAt},
)
@TableIndex(
  name: 'media_geo_idx',
  columns: {#latitude, #longitude},
)
@DataClassName('MediaItem')
class Media extends Table {
  @override
  String get tableName => 'media';

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get ownerUserId => text()();
  TextColumn get mediaType => text().withDefault(const Constant('photo'))();
  TextColumn get originScope => text()();

  TextColumn get localUri => text().nullable()();
  TextColumn get thumbnailLocalPath => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get bytesSize => integer().nullable()();
  IntColumn get widthPx => integer().nullable()();
  IntColumn get heightPx => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get contentHash => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get remoteThumbnailUrl => text().nullable()();

  DateTimeColumn get capturedAt => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get accuracyM => real().nullable()();

  TextColumn get uploadState =>
      text().withDefault(const Constant('local_only'))();
  RealColumn get uploadProgress => real().withDefault(const Constant(0.0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get workerSessionId => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get uploadedAt => dateTime().nullable()();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
