import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_candidate_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/daos/tracking_point_batch_dao.dart';
import 'package:dora/core/storage/daos/tracking_session_dao.dart';
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
