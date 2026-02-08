import 'package:drift/drift.dart';

@DataClassName('UserTripRow')
class UserTrips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverPhotoUrl => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get visibility =>
      text().withDefault(const Constant('private'))();
  IntColumn get placeCount => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('editing'))();
  DateTimeColumn get lastEditedAt => dateTime().nullable()();

  // Sync metadata
  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
