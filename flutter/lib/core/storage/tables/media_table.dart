import 'package:drift/drift.dart';

@DataClassName('MediaItem')
class Media extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get placeId => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get mimeType => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  TextColumn get type => text().withDefault(const Constant('photo'))();

  // Upload queue metadata
  TextColumn get uploadStatus => text().withDefault(const Constant('queued'))();
  RealColumn get uploadProgress => real().withDefault(const Constant(0.0))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get uploadedAt => dateTime().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get workerSessionId => text().nullable()();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
