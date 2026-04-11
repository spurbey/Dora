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
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_media_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
import 'package:dora/core/storage/daos/trip_dao.dart';
import 'package:dora/core/storage/daos/user_trips_dao.dart';
import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_projection_local_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_attempt_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/resolver_candidate_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_chunk_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_job_dao.dart';
import 'package:dora/core/storage/daos/v2/session_commit_media_item_dao.dart';
import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/daos/v2/timeline_compile_cursor_dao.dart';
import 'package:dora/core/storage/daos/v2/timeline_projection_local_dao.dart';
import 'package:dora/core/storage/tables/media_table.dart';
import 'package:dora/core/storage/tables/places_table.dart';
import 'package:dora/core/storage/tables/public_trips_table.dart';
import 'package:dora/core/storage/tables/routes_table.dart';
import 'package:dora/core/storage/tables/sync_tasks_table.dart';
import 'package:dora/core/storage/tables/tracking_candidates_table.dart';
import 'package:dora/core/storage/tables/tracking_event_media_table.dart';
import 'package:dora/core/storage/tables/tracking_events_table.dart';
import 'package:dora/core/storage/tables/tracking_moments_table.dart';
import 'package:dora/core/storage/tables/tracking_point_batches_table.dart';
import 'package:dora/core/storage/tables/tracking_sessions_table.dart';
import 'package:dora/core/storage/tables/trips_table.dart';
import 'package:dora/core/storage/tables/user_trips_table.dart';
import 'package:dora/core/storage/tables/v2/event_journal_table.dart';
import 'package:dora/core/storage/tables/v2/media_journal_table.dart';
import 'package:dora/core/storage/tables/v2/route_projection_local_table.dart';
import 'package:dora/core/storage/tables/v2/resolver_attempt_journal_table.dart';
import 'package:dora/core/storage/tables/v2/resolver_candidate_journal_table.dart';
import 'package:dora/core/storage/tables/v2/route_point_journal_table.dart';
import 'package:dora/core/storage/tables/v2/session_commit_chunk_table.dart';
import 'package:dora/core/storage/tables/v2/session_commit_job_table.dart';
import 'package:dora/core/storage/tables/v2/session_commit_media_item_table.dart';
import 'package:dora/core/storage/tables/v2/session_activity_window_table.dart';
import 'package:dora/core/storage/tables/v2/session_journal_table.dart';
import 'package:dora/core/storage/tables/v2/timeline_compile_cursor_table.dart';
import 'package:dora/core/storage/tables/v2/timeline_projection_local_table.dart';

part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Trips,
    Places,
    Routes,
    Media,
    PublicTrips,
    UserTrips,
    SyncTasks,
    TrackingSessions,
    TrackingPointBatches,
    TrackingCandidates,
    TrackingMoments,
    TrackingEvents,
    TrackingEventMedia,
    SessionJournal,
    SessionActivityWindow,
    RoutePointJournal,
    EventJournal,
    MediaJournal,
    ResolverCandidateJournal,
    ResolverAttemptJournal,
    SessionCommitJob,
    SessionCommitMediaItem,
    SessionCommitChunk,
    TimelineProjectionLocal,
    RouteProjectionLocal,
    TimelineCompileCursor,
  ],
  daos: [
    TripDao,
    PlaceDao,
    RouteDao,
    MediaDao,
    PublicTripsDao,
    UserTripsDao,
    SyncTaskDao,
    TrackingSessionDao,
    TrackingPointBatchDao,
    TrackingCandidateDao,
    TrackingMomentDao,
    TrackingEventDao,
    TrackingEventMediaDao,
    SessionJournalDao,
    RoutePointJournalDao,
    EventJournalDao,
    MediaJournalDao,
    ResolverCandidateJournalDao,
    ResolverAttemptJournalDao,
    SessionCommitJobDao,
    SessionCommitMediaItemDao,
    SessionCommitChunkDao,
    TimelineProjectionLocalDao,
    RouteProjectionLocalDao,
    TimelineCompileCursorDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 20;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await customStatement(
            '''
            CREATE UNIQUE INDEX IF NOT EXISTS tracking_sessions_single_active_idx
            ON tracking_sessions(state)
            WHERE state = 'active'
            ''',
          );
          await customStatement(
            '''
            CREATE UNIQUE INDEX IF NOT EXISTS timeline_projection_local_trip_source_unique_idx
            ON timeline_projection_local (trip_local_id, source_kind, source_id)
            ''',
          );
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

            await _backfillMediaUploadState();
          }
          if (from < 8) {
            // Trips: persistent mapping to backend trip UUID for place/media sync.
            await m.addColumn(trips, trips.serverTripId);
          }
          if (from < 9) {
            await m.createTable(syncTasks);
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
          if (from < 12) {
            await _addColumnIfMissing(
              tableName: 'sync_tasks',
              columnName: 'pending_requeue',
              definition: 'INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (from < 13) {
            await m.createTable(trackingSessions);
            await m.createTable(trackingPointBatches);
            await m.createTable(trackingCandidates);
            await m.createTable(trackingMoments);
            await m.createIndex(trackingSessionsTripStateUpdatedIdx);
            await m.createIndex(trackingSessionsTripUpdatedIdx);
            await m.createIndex(trackingPointBatchesClaimIdx);
            await m.createIndex(trackingPointBatchesTripCreatedIdx);
            await m.createIndex(trackingPointBatchesSessionCreatedIdx);
            await m.createIndex(trackingCandidatesTripCreatedIdx);
            await m.createIndex(trackingCandidatesTripStatusUpdatedIdx);
            await m.createIndex(trackingCandidatesActionQueueIdx);
            await m.createIndex(trackingMomentsTripCapturedIdx);
            await m.createIndex(trackingMomentsSyncPendingIdx);
          }
          if (from < 14) {
            await m.createTable(trackingEvents);
            await m.createTable(trackingEventMedia);
            await m.createIndex(trackingEventsTripCreatedIdx);
            await m.createIndex(trackingEventsSyncUpdatedIdx);
            await m.createIndex(trackingEventMediaEventCreatedIdx);
            await m.createIndex(trackingEventMediaStatusUpdatedIdx);
          }
          if (from < 15) {
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'resolved_place_id',
              definition: 'TEXT',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'bind_confidence',
              definition: 'REAL',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'resolver_reason_code',
              definition: 'TEXT',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'resolver_state',
              definition: "TEXT NOT NULL DEFAULT 'on_route_unresolved'",
            );
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'resolver_version',
              definition: 'INTEGER NOT NULL DEFAULT 1',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'resolved_at',
              definition: 'INTEGER',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_events',
              columnName: 'resolution_hint_json',
              definition: 'TEXT',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS tracking_events_trip_resolver_created_idx
              ON tracking_events (trip_id, resolver_state, created_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS tracking_events_trip_resolved_place_created_idx
              ON tracking_events (trip_id, resolved_place_id, created_at)
              ''',
            );
          }
          if (from < 16) {
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'bind_mode',
              definition: "TEXT NOT NULL DEFAULT 'route'",
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'bind_state',
              definition: "TEXT NOT NULL DEFAULT 'awaiting_bind_choice'",
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'trip_place_id',
              definition: 'TEXT',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'anchor_latitude',
              definition: 'REAL',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'anchor_longitude',
              definition: 'REAL',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'captured_at',
              definition: 'INTEGER NOT NULL DEFAULT 0',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'upload_ref',
              definition: 'TEXT',
            );
            await _addColumnIfMissing(
              tableName: 'tracking_event_media',
              columnName: 'remote_media_id',
              definition: 'TEXT',
            );
            await customStatement(
              '''
              UPDATE tracking_event_media
              SET bind_state = CASE
                WHEN upload_status = 'awaiting_place_binding' THEN 'awaiting_bind_choice'
                WHEN upload_status = 'queued' THEN 'queued_route_upload'
                WHEN upload_status = 'uploaded' THEN 'linked_to_event'
                WHEN upload_status = 'failed' THEN 'failed_retryable'
                WHEN upload_status = 'blocked' THEN 'blocked_validation'
                ELSE bind_state
              END
              ''',
            );
            await customStatement(
              '''
              UPDATE tracking_event_media
              SET captured_at = COALESCE(captured_at, created_at)
              ''',
            );
            await customStatement(
              '''
              UPDATE tracking_event_media
              SET sync_status = 'pending'
              WHERE sync_status = 'local_only'
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS tracking_event_media_trip_bind_state_created_idx
              ON tracking_event_media (trip_id, bind_state, created_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS tracking_event_media_sync_updated_idx
              ON tracking_event_media (sync_status, updated_at)
              ''',
            );
          }
          if (from < 17) {
            await customStatement(
              '''
              WITH ranked AS (
                SELECT
                  id,
                  ROW_NUMBER() OVER (
                    ORDER BY COALESCE(local_updated_at, updated_at, created_at) DESC, id DESC
                  ) AS rn
                FROM tracking_sessions
                WHERE state = 'active'
              )
              UPDATE tracking_sessions
              SET
                state = 'abandoned',
                abandoned_at = COALESCE(
                  abandoned_at,
                  CAST(strftime('%s','now') AS INTEGER) * 1000
                ),
                sync_status = 'pending',
                local_updated_at = CAST(strftime('%s','now') AS INTEGER) * 1000,
                updated_at = CAST(strftime('%s','now') AS INTEGER) * 1000
              WHERE id IN (SELECT id FROM ranked WHERE rn > 1)
              ''',
            );
            await customStatement(
              '''
              CREATE UNIQUE INDEX IF NOT EXISTS tracking_sessions_single_active_idx
              ON tracking_sessions(state)
              WHERE state = 'active'
              ''',
            );
          }
          if (from < 18) {
            await m.createTable(sessionJournal);
            await m.createTable(sessionActivityWindow);
            await m.createTable(routePointJournal);
            await m.createTable(eventJournal);
            await m.createTable(mediaJournal);
            await m.createTable(resolverCandidateJournal);
            await m.createTable(resolverAttemptJournal);

            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_journal_trip_state_updated_idx
              ON session_journal (trip_local_id, control_state, updated_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_journal_trip_started_idx
              ON session_journal (trip_local_id, started_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_activity_window_session_seq_idx
              ON session_activity_window (session_id, window_seq)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_activity_window_session_started_idx
              ON session_activity_window (session_id, started_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS route_point_journal_session_captured_idx
              ON route_point_journal (session_id, captured_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS route_point_journal_trip_captured_idx
              ON route_point_journal (trip_local_id, captured_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS route_point_journal_session_seq_idx
              ON route_point_journal (session_id, point_seq)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS event_journal_session_captured_idx
              ON event_journal (session_id, captured_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS event_journal_trip_resolver_captured_idx
              ON event_journal (trip_local_id, resolver_state, captured_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS event_journal_trip_manual_resolver_idx
              ON event_journal (trip_local_id, manual_lock, resolver_state)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS event_journal_session_seq_idx
              ON event_journal (session_id, event_seq)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS media_journal_event_idx
              ON media_journal (event_id)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS media_journal_session_upload_state_idx
              ON media_journal (session_id, upload_state)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS media_journal_trip_captured_idx
              ON media_journal (trip_local_id, captured_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS resolver_candidate_journal_event_version_rank_idx
              ON resolver_candidate_journal (event_id, candidate_version, rank_index)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS resolver_candidate_journal_event_version_tie_idx
              ON resolver_candidate_journal (event_id, candidate_version, is_top_tied)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS resolver_attempt_journal_event_attempt_idx
              ON resolver_attempt_journal (event_id, attempt_no)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS resolver_attempt_journal_started_idx
              ON resolver_attempt_journal (started_at)
              ''',
            );
          }
          if (from < 19) {
            await m.createTable(timelineProjectionLocal);
            await m.createTable(routeProjectionLocal);
            await m.createTable(timelineCompileCursor);

            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS timeline_projection_local_trip_captured_idx
              ON timeline_projection_local (trip_local_id, captured_at DESC)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS timeline_projection_local_trip_bucket_captured_idx
              ON timeline_projection_local (trip_local_id, bucket_type, captured_at DESC)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS timeline_projection_local_trip_captured_session_idx
              ON timeline_projection_local (trip_local_id, captured_at DESC, session_id)
              ''',
            );
            await customStatement(
              '''
              CREATE UNIQUE INDEX IF NOT EXISTS timeline_projection_local_trip_source_unique_idx
              ON timeline_projection_local (trip_local_id, source_kind, source_id)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS route_projection_local_trip_started_idx
              ON route_projection_local (trip_local_id, started_at DESC)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS route_projection_local_trip_session_started_idx
              ON route_projection_local (trip_local_id, session_id, started_at DESC)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS timeline_compile_cursor_updated_idx
              ON timeline_compile_cursor (updated_at)
              ''',
            );
          }
          if (from < 20) {
            await _addColumnIfMissing(
              tableName: 'session_journal',
              columnName: 'stop_client_event_id',
              definition: 'TEXT',
            );
            await m.createTable(sessionCommitJob);
            await m.createTable(sessionCommitMediaItem);
            await m.createTable(sessionCommitChunk);

            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_job_state_retry_idx
              ON session_commit_job (job_state, next_retry_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_job_session_idx
              ON session_commit_job (session_id)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_job_trip_created_idx
              ON session_commit_job (trip_local_id, created_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_job_lease_idx
              ON session_commit_job (is_executing, execution_started_at)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_media_item_job_state_idx
              ON session_commit_media_item (job_id, upload_state)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_media_item_media_idx
              ON session_commit_media_item (media_id)
              ''',
            );
            await customStatement(
              '''
              CREATE INDEX IF NOT EXISTS session_commit_chunk_job_state_idx
              ON session_commit_chunk (job_id, chunk_state)
              ''',
            );
            await customStatement(
              '''
              CREATE UNIQUE INDEX IF NOT EXISTS session_commit_chunk_job_index_unique_idx
              ON session_commit_chunk (job_id, chunk_index)
              ''',
            );
          }
        },
      );

  Future<void> _repairSchemaForV11(Migrator m) async {
    await _addColumnIfMissing(
      tableName: 'trips',
      columnName: 'server_trip_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      tableName: 'places',
      columnName: 'server_place_id',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'thumbnail_path',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'mime_type',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'file_size_bytes',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'width',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'height',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'upload_status',
      definition: "TEXT NOT NULL DEFAULT 'queued'",
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'upload_progress',
      definition: 'REAL NOT NULL DEFAULT 0.0',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'retry_count',
      definition: 'INTEGER NOT NULL DEFAULT 0',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'error_message',
      definition: 'TEXT',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'uploaded_at',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'next_attempt_at',
      definition: 'INTEGER',
    );
    await _addColumnIfMissing(
      tableName: 'media',
      columnName: 'worker_session_id',
      definition: 'TEXT',
    );
    await _backfillMediaUploadState();
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
    if (!await _tableExists(tableName)) {
      return;
    }
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
        const Variable<String>('table'),
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
        CASE
          WHEN r.start_place_id IS NOT NULL AND TRIM(r.start_place_id) != '' THEN 'place'
          WHEN r.end_place_id IS NOT NULL AND TRIM(r.end_place_id) != '' THEN 'place'
          ELSE 'trip'
        END,
        CASE
          WHEN r.start_place_id IS NOT NULL AND TRIM(r.start_place_id) != '' THEN r.start_place_id
          WHEN r.end_place_id IS NOT NULL AND TRIM(r.end_place_id) != '' THEN r.end_place_id
          ELSE r.trip_id
        END,
        ?,
        ?
      FROM routes r
      WHERE r.server_route_id IS NULL OR TRIM(r.server_route_id) = ''
      ''',
      [now, now],
    );
  }

  Future<void> _backfillMediaUploadState() async {
    if (!await _tableExists('media') ||
        !await _columnExists(tableName: 'media', columnName: 'upload_status') ||
        !await _columnExists(
            tableName: 'media', columnName: 'upload_progress') ||
        !await _columnExists(tableName: 'media', columnName: 'uploaded_at') ||
        !await _columnExists(tableName: 'media', columnName: 'url')) {
      return;
    }

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

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'dora.db'));
      return NativeDatabase(file);
    });
  }
}
