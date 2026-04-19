import 'package:drift/drift.dart';

@TableIndex(
  name: 'stories_visibility_published_idx',
  columns: {#visibility, #publishedAt},
)
@TableIndex(
  name: 'stories_author_published_idx',
  columns: {#authorUserId, #publishedAt},
)
@TableIndex(
  name: 'stories_geo_idx',
  columns: {#centerLat, #centerLng},
)
@DataClassName('StoryRow')
class Stories extends Table {
  @override
  String get tableName => 'stories';

  TextColumn get id => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get mediaId => text()();
  TextColumn get authorUserId => text()();
  RealColumn get centerLat => real()();
  RealColumn get centerLng => real()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get visibility => text().withDefault(const Constant('draft'))();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
