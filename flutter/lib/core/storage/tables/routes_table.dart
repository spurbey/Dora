import 'package:drift/drift.dart';

import 'package:dora/core/storage/converters.dart';

@DataClassName('RouteRow')
class Routes extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get coordinates =>
      text().map(const LatLngListConverter()).withDefault(const Constant('[]'))();
  TextColumn get transportMode => text().withDefault(const Constant('car'))();
  RealColumn get distance => real().nullable()(); // km
  IntColumn get duration => integer().nullable()(); // minutes
  IntColumn get dayNumber => integer().nullable()();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
