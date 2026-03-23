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
        name LIKE 'tracking_moments_%_idx'
      )
    ''',
  ).get();
  return rows.map((row) => row.read<String>('name')).toSet();
}

void main() {
  group('AppDatabase migration', () {
    test('upgrades schema v12 to v13 and creates live-tracking tables',
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

        await seedDb.customStatement('DROP TABLE IF EXISTS tracking_moments');
        await seedDb
            .customStatement('DROP TABLE IF EXISTS tracking_candidates');
        await seedDb
            .customStatement('DROP TABLE IF EXISTS tracking_point_batches');
        await seedDb.customStatement('DROP TABLE IF EXISTS tracking_sessions');
        await seedDb.customStatement('PRAGMA user_version = 12');
        await seedDb.close();
        seedDb = null;

        upgradedDb = AppDatabase(NativeDatabase(dbFile));

        expect(await _tableExists(upgradedDb, 'tracking_sessions'), isTrue);
        expect(
            await _tableExists(upgradedDb, 'tracking_point_batches'), isTrue);
        expect(await _tableExists(upgradedDb, 'tracking_candidates'), isTrue);
        expect(await _tableExists(upgradedDb, 'tracking_moments'), isTrue);

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
  });
}
