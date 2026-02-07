import 'package:drift/drift.dart';

@DataClassName('TripRoute')
class Routes extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get fromPlaceId => text()();
  TextColumn get toPlaceId => text()();
  TextColumn get transportMode => text().withDefault(const Constant('car'))();
  IntColumn get distanceMeters => integer().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get polyline => text().nullable()();
  IntColumn get order => integer().withDefault(const Constant(0))();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
