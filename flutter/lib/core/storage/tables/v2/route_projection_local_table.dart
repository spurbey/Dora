import 'package:drift/drift.dart';

@TableIndex(
  name: 'route_projection_local_trip_started_idx',
  columns: {#tripLocalId, #startedAt},
)
@TableIndex(
  name: 'route_projection_local_trip_session_started_idx',
  columns: {#tripLocalId, #sessionId, #startedAt},
)
@DataClassName('RouteProjectionLocalRow')
class RouteProjectionLocal extends Table {
  @override
  String get tableName => 'route_projection_local';

  TextColumn get segmentKey => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get sessionId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get pointsCount => integer()();
  RealColumn get distanceM => real()();
  RealColumn get bboxMinLat => real()();
  RealColumn get bboxMinLon => real()();
  RealColumn get bboxMaxLat => real()();
  RealColumn get bboxMaxLon => real()();
  TextColumn get geometryJson => text()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get compilerVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {segmentKey};
}
