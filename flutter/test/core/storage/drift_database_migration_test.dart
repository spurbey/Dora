import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:dora/core/storage/drift_database.dart';

Future<bool> _tableExists(AppDatabase db, String tableName) async {
  final row = await db.customSelect(
    'SELECT name FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
    variables: [
      const Variable<String>('table'),
      Variable<String>(tableName),
    ],
  ).getSingleOrNull();
  return row != null;
}

Future<Set<String>> _trackingIndexNames(AppDatabase db) async {
  final rows = await db.customSelect(
    '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'index'
      AND (
        name LIKE 'tracking_sessions_%_idx' OR
        name LIKE 'tracking_point_batches_%_idx' OR
        name LIKE 'tracking_candidates_%_idx' OR
        name LIKE 'tracking_moments_%_idx' OR
        name LIKE 'tracking_events_%_idx' OR
        name LIKE 'tracking_event_media_%_idx'
      )
    ''',
  ).get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<Set<String>> _v2IndexNames(AppDatabase db) async {
  final rows = await db.customSelect(
    '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'index'
      AND (
        name LIKE 'session_journal_%_idx' OR
        name LIKE 'session_activity_window_%_idx' OR
        name LIKE 'route_point_journal_%_idx' OR
        name LIKE 'event_journal_%_idx' OR
        name LIKE 'media_journal_%_idx' OR
        name LIKE 'resolver_candidate_journal_%_idx' OR
        name LIKE 'resolver_attempt_journal_%_idx'
      )
    ''',
  ).get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

Future<Set<String>> _v2ProjectionIndexNames(AppDatabase db) async {
  final rows = await db.customSelect(
    '''
    SELECT name
    FROM sqlite_master
    WHERE type = 'index'
      AND (
        name LIKE 'timeline_projection_local_%_idx' OR
        name LIKE 'route_projection_local_%_idx' OR
        name = 'timeline_projection_local_trip_source_unique_idx' OR
        name = 'timeline_compile_cursor_updated_idx'
      )
    ''',
  ).get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

void main() {
  group('AppDatabase migration', () {
    test('upgrades schema v13 to v15 and applies resolver columns/indexes',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('dora_drift_mig_');
      final dbFile = File(p.join(tempDir.path, 'app_migration_test.db'));

      AppDatabase? seedDb;
      AppDatabase? upgradedDb;
      try {
        seedDb = AppDatabase(NativeDatabase(dbFile));
        final now = DateTime.utc(2026, 3, 23, 12, 0);
        await seedDb.into(seedDb.trips).insert(
              TripsCompanion.insert(
                id: 'trip-migration-1',
                userId: 'user-migration-1',
                name: 'Migration Trip',
                localUpdatedAt: now,
                serverUpdatedAt: now,
                syncStatus: 'synced',
                createdAt: now,
              ),
            );

        await seedDb
            .customStatement('DROP TABLE IF EXISTS tracking_event_media');
        await seedDb.customStatement('DROP TABLE IF EXISTS tracking_events');
        await seedDb.customStatement('PRAGMA user_version = 13');
        await seedDb.close();
        seedDb = null;

        upgradedDb = AppDatabase(NativeDatabase(dbFile));

        expect(await _tableExists(upgradedDb, 'tracking_sessions'), isTrue);
        expect(
            await _tableExists(upgradedDb, 'tracking_point_batches'), isTrue);
        expect(await _tableExists(upgradedDb, 'tracking_candidates'), isTrue);
        expect(await _tableExists(upgradedDb, 'tracking_moments'), isTrue);
        expect(await _tableExists(upgradedDb, 'tracking_events'), isTrue);
        expect(await _tableExists(upgradedDb, 'tracking_event_media'), isTrue);

        final eventColumns = await upgradedDb
            .customSelect('PRAGMA table_info(tracking_events)')
            .get();
        final eventColumnNames =
            eventColumns.map((row) => row.read<String>('name')).toSet();
        expect(
          eventColumnNames,
          containsAll(<String>{
            'resolved_place_id',
            'bind_confidence',
            'resolver_reason_code',
            'resolver_state',
            'resolver_version',
            'resolved_at',
            'resolution_hint_json',
          }),
        );

        final trackingIndexes = await _trackingIndexNames(upgradedDb);
        expect(
          trackingIndexes,
          containsAll(<String>{
            'tracking_sessions_trip_state_updated_idx',
            'tracking_sessions_trip_updated_idx',
            'tracking_point_batches_claim_idx',
            'tracking_point_batches_trip_created_idx',
            'tracking_point_batches_session_created_idx',
            'tracking_candidates_trip_created_idx',
            'tracking_candidates_trip_status_updated_idx',
            'tracking_candidates_action_queue_idx',
            'tracking_moments_trip_captured_idx',
            'tracking_moments_sync_pending_idx',
            'tracking_events_trip_created_idx',
            'tracking_events_sync_updated_idx',
            'tracking_events_trip_resolver_created_idx',
            'tracking_events_trip_resolved_place_created_idx',
            'tracking_event_media_event_created_idx',
            'tracking_event_media_status_updated_idx',
          }),
        );

        final trip = await (upgradedDb.select(upgradedDb.trips)
              ..where((t) => t.id.equals('trip-migration-1')))
            .getSingleOrNull();
        expect(trip, isNotNull);
        expect(trip!.name, 'Migration Trip');
      } finally {
        await seedDb?.close();
        await upgradedDb?.close();
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('upgrades schema v17 to v18 and creates fresh V2 journal tables',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('dora_drift_v2_');
      final dbFile = File(p.join(tempDir.path, 'app_migration_v2_test.db'));

      AppDatabase? seedDb;
      AppDatabase? upgradedDb;
      try {
        seedDb = AppDatabase(NativeDatabase(dbFile));
        final now = DateTime.utc(2026, 4, 10, 14, 0);
        await seedDb.into(seedDb.trips).insert(
              TripsCompanion.insert(
                id: 'trip-v2-migration-1',
                userId: 'user-v2-migration-1',
                name: 'V2 Migration Trip',
                localUpdatedAt: now,
                serverUpdatedAt: now,
                syncStatus: 'synced',
                createdAt: now,
              ),
            );

        await seedDb.customStatement('DROP TABLE IF EXISTS session_journal');
        await seedDb
            .customStatement('DROP TABLE IF EXISTS session_activity_window');
        await seedDb
            .customStatement('DROP TABLE IF EXISTS route_point_journal');
        await seedDb.customStatement('DROP TABLE IF EXISTS event_journal');
        await seedDb.customStatement('DROP TABLE IF EXISTS media_journal');
        await seedDb
            .customStatement('DROP TABLE IF EXISTS resolver_candidate_journal');
        await seedDb
            .customStatement('DROP TABLE IF EXISTS resolver_attempt_journal');
        await seedDb.customStatement('PRAGMA user_version = 17');
        await seedDb.close();
        seedDb = null;

        upgradedDb = AppDatabase(NativeDatabase(dbFile));

        expect(await _tableExists(upgradedDb, 'session_journal'), isTrue);
        expect(
            await _tableExists(upgradedDb, 'session_activity_window'), isTrue);
        expect(await _tableExists(upgradedDb, 'route_point_journal'), isTrue);
        expect(await _tableExists(upgradedDb, 'event_journal'), isTrue);
        expect(await _tableExists(upgradedDb, 'media_journal'), isTrue);
        expect(
          await _tableExists(upgradedDb, 'resolver_candidate_journal'),
          isTrue,
        );
        expect(
          await _tableExists(upgradedDb, 'resolver_attempt_journal'),
          isTrue,
        );

        final v2Indexes = await _v2IndexNames(upgradedDb);
        expect(
          v2Indexes,
          containsAll(<String>{
            'session_journal_trip_state_updated_idx',
            'session_journal_trip_started_idx',
            'session_activity_window_session_seq_idx',
            'session_activity_window_session_started_idx',
            'route_point_journal_session_captured_idx',
            'route_point_journal_trip_captured_idx',
            'route_point_journal_session_seq_idx',
            'event_journal_session_captured_idx',
            'event_journal_trip_resolver_captured_idx',
            'event_journal_trip_manual_resolver_idx',
            'event_journal_session_seq_idx',
            'media_journal_event_idx',
            'media_journal_session_upload_state_idx',
            'media_journal_trip_captured_idx',
            'resolver_candidate_journal_event_version_rank_idx',
            'resolver_candidate_journal_event_version_tie_idx',
            'resolver_attempt_journal_event_attempt_idx',
            'resolver_attempt_journal_started_idx',
          }),
        );

        final trip = await (upgradedDb.select(upgradedDb.trips)
              ..where((t) => t.id.equals('trip-v2-migration-1')))
            .getSingleOrNull();
        expect(trip, isNotNull);
        expect(trip!.name, 'V2 Migration Trip');
      } finally {
        await seedDb?.close();
        await upgradedDb?.close();
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test(
      'upgrades schema v18 to v19 and creates V2 local projection tables/cursor',
      () async {
        final tempDir =
            await Directory.systemTemp.createTemp('dora_drift_v2_proj_');
        final dbFile =
            File(p.join(tempDir.path, 'app_migration_v2_projection_test.db'));

        AppDatabase? seedDb;
        AppDatabase? upgradedDb;
        try {
          seedDb = AppDatabase(NativeDatabase(dbFile));
          final now = DateTime.utc(2026, 4, 11, 9, 30);
          await seedDb.into(seedDb.trips).insert(
                TripsCompanion.insert(
                  id: 'trip-v2-projection-migration-1',
                  userId: 'user-v2-projection-migration-1',
                  name: 'V2 Projection Migration Trip',
                  localUpdatedAt: now,
                  serverUpdatedAt: now,
                  syncStatus: 'synced',
                  createdAt: now,
                ),
              );

          await seedDb.customStatement(
              'DROP TABLE IF EXISTS timeline_projection_local');
          await seedDb
              .customStatement('DROP TABLE IF EXISTS route_projection_local');
          await seedDb
              .customStatement('DROP TABLE IF EXISTS timeline_compile_cursor');
          await seedDb.customStatement('PRAGMA user_version = 18');
          await seedDb.close();
          seedDb = null;

          upgradedDb = AppDatabase(NativeDatabase(dbFile));

          expect(
            await _tableExists(upgradedDb, 'timeline_projection_local'),
            isTrue,
          );
          expect(
              await _tableExists(upgradedDb, 'route_projection_local'), isTrue);
          expect(
            await _tableExists(upgradedDb, 'timeline_compile_cursor'),
            isTrue,
          );

          final v2ProjectionIndexes = await _v2ProjectionIndexNames(upgradedDb);
          expect(
            v2ProjectionIndexes,
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

          final trip = await (upgradedDb.select(upgradedDb.trips)
                ..where((t) => t.id.equals('trip-v2-projection-migration-1')))
              .getSingleOrNull();
          expect(trip, isNotNull);
          expect(trip!.name, 'V2 Projection Migration Trip');
        } finally {
          await seedDb?.close();
          await upgradedDb?.close();
          if (await dbFile.exists()) {
            await dbFile.delete();
          }
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        }
      },
    );
  });
}
