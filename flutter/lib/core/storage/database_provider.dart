import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_media_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
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
import 'package:dora/core/storage/drift_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final appDatabaseInitProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  // Force open/initialize the database at startup.
  await db.customSelect('SELECT 1').get();
});

final syncTaskDaoProvider = Provider<SyncTaskDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SyncTaskDao(db);
});

final trackingSessionDaoProvider = Provider<TrackingSessionDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingSessionDao(db);
});

final trackingPointBatchDaoProvider = Provider<TrackingPointBatchDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingPointBatchDao(db);
});

final trackingCandidateDaoProvider = Provider<TrackingCandidateDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingCandidateDao(db);
});

final trackingMomentDaoProvider = Provider<TrackingMomentDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingMomentDao(db);
});

final trackingEventDaoProvider = Provider<TrackingEventDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingEventDao(db);
});

final trackingEventMediaDaoProvider = Provider<TrackingEventMediaDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrackingEventMediaDao(db);
});

final v2SessionJournalDaoProvider = Provider<SessionJournalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionJournalDao(db);
});

final v2RoutePointJournalDaoProvider = Provider<RoutePointJournalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoutePointJournalDao(db);
});

final v2EventJournalDaoProvider = Provider<EventJournalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EventJournalDao(db);
});

final v2MediaJournalDaoProvider = Provider<MediaJournalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MediaJournalDao(db);
});

final v2ResolverCandidateJournalDaoProvider =
    Provider<ResolverCandidateJournalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ResolverCandidateJournalDao(db);
});

final v2ResolverAttemptJournalDaoProvider =
    Provider<ResolverAttemptJournalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ResolverAttemptJournalDao(db);
});

final v2TimelineProjectionLocalDaoProvider =
    Provider<TimelineProjectionLocalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TimelineProjectionLocalDao(db);
});

final v2RouteProjectionLocalDaoProvider =
    Provider<RouteProjectionLocalDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RouteProjectionLocalDao(db);
});

final v2TimelineCompileCursorDaoProvider =
    Provider<TimelineCompileCursorDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TimelineCompileCursorDao(db);
});

final v2SessionCommitJobDaoProvider = Provider<SessionCommitJobDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionCommitJobDao(db);
});

final v2SessionCommitMediaItemDaoProvider =
    Provider<SessionCommitMediaItemDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionCommitMediaItemDao(db);
});

final v2SessionCommitChunkDaoProvider = Provider<SessionCommitChunkDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SessionCommitChunkDao(db);
});
