import 'package:drift/drift.dart';

import 'package:dora/core/storage/converters.dart';

@DataClassName('PlaceRow')
class Places extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text()();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get coordinates => text().map(const LatLngConverter())();
  TextColumn get notes => text().nullable()();
  TextColumn get visitTime => text().nullable()();
  IntColumn get dayNumber => integer().nullable()();
  IntColumn get orderIndex => integer()();
  TextColumn get photoUrls =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();

  // Place classification
  TextColumn get placeType => text().nullable()();
  IntColumn get rating => integer().nullable()();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
