import 'package:drift/drift.dart';

@TableIndex(
  name: 'route_point_journal_session_captured_idx',
  columns: {#sessionId, #capturedAt},
)
@TableIndex(
  name: 'route_point_journal_trip_captured_idx',
  columns: {#tripLocalId, #capturedAt},
)
@TableIndex(
  name: 'route_point_journal_session_seq_idx',
  columns: {#sessionId, #pointSeq},
)
@DataClassName('RoutePointJournalRow')
class RoutePointJournal extends Table {
  @override
  String get tableName => 'route_point_journal';

  TextColumn get pointId => text()();
  TextColumn get sessionId => text()();
  TextColumn get tripLocalId => text()();
  DateTimeColumn get capturedAt => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get accuracyM => real().nullable()();
  RealColumn get speedMps => real().nullable()();
  RealColumn get bearingDeg => real().nullable()();
  RealColumn get altitudeM => real().nullable()();
  TextColumn get source => text().withDefault(const Constant('device_gps'))();
  IntColumn get pointSeq => integer()();

  @override
  Set<Column<Object>> get primaryKey => {pointId};
}
