import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/daos/media_attachments_dao.dart';
import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/daos/stories_dao.dart';
import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
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
import 'package:dora/core/storage/daos/v2/trip_publish_state_dao.dart';
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

final mediaDaoProvider = Provider<MediaDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MediaDao(db);
});

final mediaAttachmentsDaoProvider = Provider<MediaAttachmentsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MediaAttachmentsDao(db);
});

final storiesDaoProvider = Provider<StoriesDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return StoriesDao(db);
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

final v2TripPublishStateDaoProvider = Provider<TripPublishStateDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TripPublishStateDao(db);
});
