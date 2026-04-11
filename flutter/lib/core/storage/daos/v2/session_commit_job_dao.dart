import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/session_commit_job_table.dart';

part 'session_commit_job_dao.g.dart';

@DriftAccessor(tables: [SessionCommitJob])
class SessionCommitJobDao extends DatabaseAccessor<AppDatabase>
    with _$SessionCommitJobDaoMixin {
  SessionCommitJobDao(super.db);

  Future<SessionCommitJobRow?> getJobById(String jobId) =>
      (select(sessionCommitJob)..where((row) => row.jobId.equals(jobId)))
          .getSingleOrNull();

  Future<List<SessionCommitJobRow>> listJobsForSession(String sessionId) =>
      (select(sessionCommitJob)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.createdAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .get();

  Future<SessionCommitJobRow?> findActiveJobForSession(String sessionId) =>
      (select(sessionCommitJob)
            ..where(
              (row) =>
                  row.sessionId.equals(sessionId) &
                  row.jobState.isIn(
                    const [
                      'commit_pending',
                      'committing',
                      'commit_failed_retryable',
                    ],
                  ),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<SessionCommitJobRow>> listRunnableJobs({
    required DateTime now,
    int limit = 20,
  }) =>
      (select(sessionCommitJob)
            ..where(
              (row) =>
                  row.jobState.isIn(
                    const ['commit_pending', 'commit_failed_retryable'],
                  ) &
                  (row.nextRetryAt.isNull() |
                      row.nextRetryAt.isSmallerOrEqualValue(now.toUtc())),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.asc,
                  ),
            ])
            ..limit(limit))
          .get();

  Stream<List<SessionCommitJobRow>> watchJobsForTrip(String tripLocalId) =>
      (select(sessionCommitJob)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.updatedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch();

  Future<int> upsertJob(SessionCommitJobCompanion row) =>
      into(sessionCommitJob).insertOnConflictUpdate(row);

  Future<int> updateJobById(
    String jobId,
    SessionCommitJobCompanion patch,
  ) {
    return (update(sessionCommitJob)..where((row) => row.jobId.equals(jobId)))
        .write(patch);
  }

  Future<int> markReusedAsPending({
    required String jobId,
    required DateTime now,
  }) {
    return updateJobById(
      jobId,
      SessionCommitJobCompanion(
        jobState: const Value('commit_pending'),
        nextRetryAt: const Value(null),
        lastErrorCode: const Value(null),
        lastErrorMessage: const Value(null),
        updatedAt: Value(now.toUtc()),
      ),
    );
  }
}

