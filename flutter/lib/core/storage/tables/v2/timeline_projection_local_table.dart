import 'package:drift/drift.dart';

@TableIndex(
  name: 'timeline_projection_local_trip_captured_idx',
  columns: {#tripLocalId, #capturedAt},
)
@TableIndex(
  name: 'timeline_projection_local_trip_bucket_captured_idx',
  columns: {#tripLocalId, #bucketType, #capturedAt},
)
@TableIndex(
  name: 'timeline_projection_local_trip_captured_session_idx',
  columns: {#tripLocalId, #capturedAt, #sessionId},
)
@TableIndex(
  name: 'timeline_projection_local_trip_display_order_idx',
  columns: {#tripLocalId, #displayOrder},
)
@DataClassName('TimelineProjectionLocalRow')
class TimelineProjectionLocal extends Table {
  @override
  String get tableName => 'timeline_projection_local';

  TextColumn get entryId => text()();
  TextColumn get tripLocalId => text()();
  TextColumn get sessionId => text()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get sourceKind => text()();
  TextColumn get sourceId => text()();
  TextColumn get eventType => text()();
  TextColumn get bucketType => text()();
  TextColumn get placeBindKind => text().nullable()();
  TextColumn get placeBindId => text().nullable()();
  TextColumn get placeBindName => text().nullable()();
  TextColumn get decisionSource => text().nullable()();
  IntColumn get manualLock => integer().withDefault(const Constant(0))();
  RealColumn get anchorLatitude => real()();
  RealColumn get anchorLongitude => real()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get syncChipState => text()();
  RealColumn get displayOrder => real().nullable()();
  TextColumn get routeSegmentKey => text().nullable()();
  RealColumn get routeDistanceM => real().nullable()();
  TextColumn get renderPayloadJson => text().nullable()();
  DateTimeColumn get compiledAt => dateTime()();
  IntColumn get compilerVersion => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}
