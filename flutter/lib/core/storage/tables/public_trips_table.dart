import 'dart:convert';

import 'package:drift/drift.dart';

@DataClassName('PublicTripRow')
class PublicTrips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverPhotoUrl => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  IntColumn get placeCount => integer()();
  IntColumn get duration => integer().nullable()();
  TextColumn get tags => text().map(const TagsConverter())();
  TextColumn get visibility =>
      text().withDefault(const Constant('public'))();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get localUpdatedAt => dateTime()();
  DateTimeColumn get serverUpdatedAt => dateTime()();
  TextColumn get syncStatus => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb) as List;
    return decoded.cast<String>();
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
