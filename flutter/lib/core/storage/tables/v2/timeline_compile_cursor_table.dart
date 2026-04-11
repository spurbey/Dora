import 'package:drift/drift.dart';

@TableIndex(
  name: 'timeline_compile_cursor_updated_idx',
  columns: {#updatedAt},
)
@DataClassName('TimelineCompileCursorRow')
class TimelineCompileCursor extends Table {
  @override
  String get tableName => 'timeline_compile_cursor';

  TextColumn get tripLocalId => text()();
  IntColumn get compilerVersion => integer()();
  IntColumn get projectionSchemaVersion => integer()();
  DateTimeColumn get lastCompiledAt => dateTime()();
  DateTimeColumn get lastEventUpdatedAt => dateTime().nullable()();
  DateTimeColumn get lastMediaUpdatedAt => dateTime().nullable()();
  DateTimeColumn get lastRoutePointCapturedAt => dateTime().nullable()();
  DateTimeColumn get lastSessionUpdatedAt => dateTime().nullable()();
  DateTimeColumn get dirtyFromCapturedAt => dateTime().nullable()();
  TextColumn get dirtyReason => text().nullable()();
  IntColumn get fullRebuildRequired =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {tripLocalId};
}
