import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/storage/drift_database.dart';

void main() {
  group('V2ProjectionSchema', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('schema includes projection tables and indexes', () async {
      final tables = await database.customSelect(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
          AND name IN (
            'timeline_projection_local',
            'route_projection_local',
            'timeline_compile_cursor'
          )
        ORDER BY name
        ''',
      ).get();
      final tableNames = tables.map((row) => row.read<String>('name')).toList();
      expect(
        tableNames,
        containsAll(<String>[
          'timeline_projection_local',
          'route_projection_local',
          'timeline_compile_cursor',
        ]),
      );

      final indexes = await database.customSelect(
        '''
        SELECT name
        FROM sqlite_master
        WHERE type = 'index'
          AND name IN (
            'timeline_projection_local_trip_captured_idx',
            'timeline_projection_local_trip_bucket_captured_idx',
            'timeline_projection_local_trip_captured_session_idx',
            'timeline_projection_local_trip_source_unique_idx',
            'route_projection_local_trip_started_idx',
            'route_projection_local_trip_session_started_idx',
            'timeline_compile_cursor_updated_idx'
          )
        ''',
      ).get();
      final indexNames = indexes.map((row) => row.read<String>('name')).toSet();
      expect(
        indexNames,
        containsAll(<String>{
          'timeline_projection_local_trip_captured_idx',
          'timeline_projection_local_trip_bucket_captured_idx',
          'timeline_projection_local_trip_captured_session_idx',
          'timeline_projection_local_trip_source_unique_idx',
          'route_projection_local_trip_started_idx',
          'route_projection_local_trip_session_started_idx',
          'timeline_compile_cursor_updated_idx',
        }),
      );
    });

    test('v1 tables remain queryable with v2 schema present', () async {
      final result = await database
          .customSelect(
            'SELECT COUNT(1) AS cnt FROM trips',
          )
          .getSingle();
      expect(result.read<int>('cnt'), isA<int>());
    });
  });
}
