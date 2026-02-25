import 'package:drift/drift.dart';

import 'package:dora/core/storage/converters.dart';

@DataClassName('RouteRow')
class Routes extends Table {
  TextColumn get id => text()();
  TextColumn get serverRouteId => text().nullable()();
  TextColumn get tripId => text()();
  TextColumn get coordinates =>
      text().map(const LatLngListConverter()).withDefault(const Constant('[]'))();
  TextColumn get transportMode => text().withDefault(const Constant('car'))();
  RealColumn get distance => real().nullable()(); // km
  IntColumn get duration => integer().nullable()(); // minutes
  IntColumn get dayNumber => integer().nullable()();

  // Route metadata
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get routeCategory =>
      text().withDefault(const Constant('ground'))();
  TextColumn get startPlaceId => text().nullable()();
  TextColumn get endPlaceId => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  TextColumn get routeGeojson => text().nullable()();
  TextColumn get waypointsJson =>
      text().map(const LatLngListConverter()).withDefault(const Constant('[]'))();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
