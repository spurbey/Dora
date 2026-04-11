import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/session_commit_media_item_table.dart';

part 'session_commit_media_item_dao.g.dart';

@DriftAccessor(tables: [SessionCommitMediaItem])
class SessionCommitMediaItemDao extends DatabaseAccessor<AppDatabase>
    with _$SessionCommitMediaItemDaoMixin {
  SessionCommitMediaItemDao(super.db);

  Future<List<SessionCommitMediaItemRow>> listItemsForJob(String jobId) =>
      (select(sessionCommitMediaItem)
            ..where((row) => row.jobId.equals(jobId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.createdAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<List<SessionCommitMediaItemRow>> listItemsForJobByState(
    String jobId,
    Set<String> states,
  ) {
    if (states.isEmpty) {
      return Future<List<SessionCommitMediaItemRow>>.value(
        const <SessionCommitMediaItemRow>[],
      );
    }
    return (select(sessionCommitMediaItem)
          ..where(
            (row) => row.jobId.equals(jobId) &
                row.uploadState.isIn(states.toList(growable: false)),
          )
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  Future<void> replaceItemsForJob({
    required String jobId,
    required List<SessionCommitMediaItemCompanion> rows,
  }) async {
    await transaction(() async {
      await (delete(sessionCommitMediaItem)
            ..where((row) => row.jobId.equals(jobId)))
          .go();
      if (rows.isEmpty) {
        return;
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(sessionCommitMediaItem, rows);
      });
    });
  }

  Future<int> upsertItem(SessionCommitMediaItemCompanion row) =>
      into(sessionCommitMediaItem).insertOnConflictUpdate(row);

  Future<int> updateItemById(
    String itemId,
    SessionCommitMediaItemCompanion patch,
  ) {
    return (update(sessionCommitMediaItem)
          ..where((row) => row.itemId.equals(itemId)))
        .write(patch);
  }
}

