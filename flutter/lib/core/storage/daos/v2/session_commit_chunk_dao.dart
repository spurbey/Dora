import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/session_commit_chunk_table.dart';

part 'session_commit_chunk_dao.g.dart';

@DriftAccessor(tables: [SessionCommitChunk])
class SessionCommitChunkDao extends DatabaseAccessor<AppDatabase>
    with _$SessionCommitChunkDaoMixin {
  SessionCommitChunkDao(super.db);

  Future<List<SessionCommitChunkRow>> listChunksForJob(String jobId) =>
      (select(sessionCommitChunk)
            ..where((row) => row.jobId.equals(jobId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.chunkIndex,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<void> replaceChunksForJob({
    required String jobId,
    required List<SessionCommitChunkCompanion> rows,
  }) async {
    await transaction(() async {
      await (delete(sessionCommitChunk)
            ..where((row) => row.jobId.equals(jobId)))
          .go();
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(sessionCommitChunk, rows);
      });
    });
  }

  Future<int> upsertChunk(SessionCommitChunkCompanion row) =>
      into(sessionCommitChunk).insertOnConflictUpdate(row);
}
