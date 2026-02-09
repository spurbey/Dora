import 'package:drift/drift.dart';

import 'package:dora/core/storage/converters.dart';

@DataClassName('TripRow')
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get tags =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get visibility =>
      text().withDefault(const Constant('private'))();
  TextColumn get centerPoint =>
      text().map(const LatLngConverter()).nullable()();
  RealColumn get zoom => real().withDefault(const Constant(12.0))();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()(); // 'pending' | 'synced' | 'conflict'

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
