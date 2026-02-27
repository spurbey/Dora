import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:dora/core/map/models/app_latlng.dart'; // ignore: unused_import
import 'package:dora/core/storage/converters.dart'; // ignore: unused_import
import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/place_dao.dart';
import 'package:dora/core/storage/daos/public_trips_dao.dart';
import 'package:dora/core/storage/daos/route_dao.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/trip_dao.dart';
import 'package:dora/core/storage/daos/user_trips_dao.dart';
import 'package:dora/core/storage/tables/media_table.dart';
import 'package:dora/core/storage/tables/places_table.dart';
import 'package:dora/core/storage/tables/public_trips_table.dart';
import 'package:dora/core/storage/tables/routes_table.dart';
import 'package:dora/core/storage/tables/sync_tasks_table.dart';
import 'package:dora/core/storage/tables/trips_table.dart';
import 'package:dora/core/storage/tables/user_trips_table.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [Trips, Places, Routes, Media, PublicTrips, UserTrips, SyncTasks],
  daos: [
    TripDao,
    PlaceDao,
    RouteDao,
    MediaDao,
    PublicTripsDao,
    UserTripsDao,
    SyncTaskDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(publicTrips);
          }
          if (from < 3) {
            await m.createTable(userTrips);
          }
          if (from < 4) {
            await m.addColumn(trips, trips.tags);
            await m.addColumn(trips, trips.centerPoint);
            await m.addColumn(trips, trips.zoom);
            await m.deleteTable('places');
            await m.deleteTable('routes');
            await m.createTable(places);
            await m.createTable(routes);
          }
          if (from >= 4 && from < 5) {
            // Places: add placeType, rating
            // (Skipped if from < 4: tables were just recreated with full v5 schema)
            await m.addColumn(places, places.placeType);
            await m.addColumn(places, places.rating);
            // Routes: add name, description, routeCategory, startPlaceId,
            // endPlaceId, orderIndex, routeGeojson
            await m.addColumn(routes, routes.name);
            await m.addColumn(routes, routes.description);
            await m.addColumn(routes, routes.routeCategory);
            await m.addColumn(routes, routes.startPlaceId);
            await m.addColumn(routes, routes.endPlaceId);
            await m.addColumn(routes, routes.orderIndex);
            await m.addColumn(routes, routes.routeGeojson);
          }
          if (from >= 5 && from < 6) {
            // Routes: add waypointsJson for user-defined intermediate waypoints
            await m.addColumn(routes, routes.waypointsJson);
          }
          if (from >= 6 && from < 7) {
            // Places: persistent mapping to backend place UUID for media uploads.
            await m.addColumn(places, places.serverPlaceId);

            // Media: queue and upload lifecycle metadata.
            await m.addColumn(media, media.thumbnailPath);
            await m.addColumn(media, media.mimeType);
            await m.addColumn(media, media.fileSizeBytes);
            await m.addColumn(media, media.width);
            await m.addColumn(media, media.height);
            await m.addColumn(media, media.uploadStatus);
            await m.addColumn(media, media.uploadProgress);
            await m.addColumn(media, media.retryCount);
            await m.addColumn(media, media.errorMessage);
            await m.addColumn(media, media.uploadedAt);
            await m.addColumn(media, media.nextAttemptAt);
            await m.addColumn(media, media.workerSessionId);

            // Backfill upload state from legacy rows.
            await customStatement('''
              UPDATE media
              SET
                upload_status = 'uploaded',
                upload_progress = 1.0,
                uploaded_at = COALESCE(uploaded_at, created_at)
              WHERE url IS NOT NULL AND TRIM(url) != ''
            ''');

            await customStatement('''
              UPDATE media
              SET
                upload_status = 'queued',
                upload_progress = 0.0
              WHERE url IS NULL OR TRIM(url) = ''
            ''');
          }
          if (from < 8) {
            // Trips: persistent mapping to backend trip UUID for place/media sync.
            await m.addColumn(trips, trips.serverTripId);
          }
          if (from < 9) {
            await m.createTable(syncTasks);
            await _backfillSyncTasksForUnsyncedEntities();
          }
          if (from >= 9 && from < 10) {
            await _addColumnIfMissing(
              tableName: 'sync_tasks',
              columnName: 'remote_entity_id',
              definition: 'TEXT',
            );
          }
          if (from >= 4 && from < 10) {
            await _addColumnIfMissing(
              tableName: 'routes',
              columnName: 'server_route_id',
              definition: 'TEXT',
            );
          }
          if (from < 11) {
            await _repairSchemaForV11(m);
          }
        },
      );

  Future<void> _repairSchemaForV11(Migrator m) async {
    await _ensureTableExists(m, 'sync_tasks');
    await _addColumnIfMissing(
      tableName: 'sync_tasks',
      columnName: 'remote_entity_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      tableName: 'routes',
      columnName: 'server_route_id',
      definition: 'TEXT',
    );
    await _backfillSyncTasksForUnsyncedEntities();
  }

  Future<void> _ensureTableExists(Migrator m, String tableName) async {
    final exists = await _tableExists(tableName);
    if (exists) {
      return;
    }

    if (tableName == 'sync_tasks') {
      await m.createTable(syncTasks);
    }
  }

  Future<void> _addColumnIfMissing({
    required String tableName,
    required String columnName,
    required String definition,
  }) async {
    final exists = await _columnExists(
      tableName: tableName,
      columnName: columnName,
    );
    if (exists) {
      return;
    }
    await customStatement(
      'ALTER TABLE $tableName ADD COLUMN $columnName $definition',
    );
  }

  Future<bool> _tableExists(String tableName) async {
    final row = await customSelect(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ? LIMIT 1',
      variables: [
        Variable<String>('table'),
        Variable<String>(tableName),
      ],
    ).getSingleOrNull();
    return row != null;
  }

  Future<bool> _columnExists({
    required String tableName,
    required String columnName,
  }) async {
    if (!await _tableExists(tableName)) {
      return false;
    }
    final rows = await customSelect('PRAGMA table_info($tableName)').get();
    return rows.any((row) => row.read<String>('name') == columnName);
  }

  Future<void> _backfillSyncTasksForUnsyncedEntities() async {
    final now = DateTime.now();

    // Any trip without a backend identity gets a create task.
    await customStatement(
      '''
      INSERT OR IGNORE INTO sync_tasks (
        id,
        entity_type,
        entity_id,
        operation,
        status,
        retry_count,
        created_at,
        updated_at
      )
      SELECT
        lower(hex(randomblob(16))),
        'trip',
        t.id,
        'create',
        'queued',
        0,
        ?,
        ?
      FROM trips t
      WHERE t.server_trip_id IS NULL OR TRIM(t.server_trip_id) = ''
      ''',
      [now, now],
    );

    // Any place without a backend identity gets a create task that depends on trip.
    await customStatement(
      '''
      INSERT OR IGNORE INTO sync_tasks (
        id,
        entity_type,
        entity_id,
        operation,
        status,
        retry_count,
        depends_on_entity_type,
        depends_on_entity_id,
        created_at,
        updated_at
      )
      SELECT
        lower(hex(randomblob(16))),
        'place',
        p.id,
        'create',
        'queued',
        0,
        'trip',
        p.trip_id,
        ?,
        ?
      FROM places p
      WHERE p.server_place_id IS NULL OR TRIM(p.server_place_id) = ''
      ''',
      [now, now],
    );

    await _backfillRouteSyncTasks();
  }

  Future<void> _backfillRouteSyncTasks() async {
    final now = DateTime.now();
    await customStatement(
      '''
      INSERT OR IGNORE INTO sync_tasks (
        id,
        entity_type,
        entity_id,
        operation,
        status,
        retry_count,
        depends_on_entity_type,
        depends_on_entity_id,
        created_at,
        updated_at
      )
      SELECT
        lower(hex(randomblob(16))),
        'route',
        r.id,
        'create',
        'queued',
        0,
        'trip',
        r.trip_id,
        ?,
        ?
      FROM routes r
      WHERE r.server_route_id IS NULL OR TRIM(r.server_route_id) = ''
      ''',
      [now, now],
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'dora.db'));
      return NativeDatabase(file);
    });
  }
}
