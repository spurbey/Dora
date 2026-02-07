import 'package:drift/drift.dart';

@DataClassName('MediaItem')
class Media extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get placeId => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get type => text().withDefault(const Constant('photo'))();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
