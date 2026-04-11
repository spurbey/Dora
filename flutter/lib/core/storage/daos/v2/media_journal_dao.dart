import 'package:drift/drift.dart';

import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/storage/tables/v2/media_journal_table.dart';

part 'media_journal_dao.g.dart';

@DriftAccessor(tables: [MediaJournal])
class MediaJournalDao extends DatabaseAccessor<AppDatabase>
    with _$MediaJournalDaoMixin {
  MediaJournalDao(super.db);

  Future<MediaJournalRow?> getMediaById(String mediaId) =>
      (select(mediaJournal)..where((row) => row.mediaId.equals(mediaId)))
          .getSingleOrNull();

  Future<int> upsertMedia(MediaJournalCompanion row) =>
      into(mediaJournal).insertOnConflictUpdate(row);

  Future<List<MediaJournalRow>> listMediaForEvent(String eventId) =>
      (select(mediaJournal)
            ..where((row) => row.eventId.equals(eventId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Stream<List<MediaJournalRow>> watchMediaForEvent(String eventId) =>
      (select(mediaJournal)
            ..where((row) => row.eventId.equals(eventId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .watch();

  Future<List<MediaJournalRow>> listMediaForSession(String sessionId) =>
      (select(mediaJournal)
            ..where((row) => row.sessionId.equals(sessionId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<List<MediaJournalRow>> listMediaForTrip(String tripLocalId) =>
      (select(mediaJournal)
            ..where((row) => row.tripLocalId.equals(tripLocalId))
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
              (row) => OrderingTerm(
                    expression: row.mediaId,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<List<MediaJournalRow>> listMediaForTripFromCapturedAt(
    String tripLocalId,
    DateTime fromCapturedAt,
  ) =>
      (select(mediaJournal)
            ..where(
              (row) =>
                  row.tripLocalId.equals(tripLocalId) &
                  row.capturedAt.isBiggerOrEqualValue(fromCapturedAt.toUtc()),
            )
            ..orderBy([
              (row) => OrderingTerm(
                    expression: row.capturedAt,
                    mode: OrderingMode.asc,
                  ),
              (row) => OrderingTerm(
                    expression: row.mediaId,
                    mode: OrderingMode.asc,
                  ),
            ]))
          .get();

  Future<int> markUploadState({
    required String mediaId,
    required String uploadState,
    String? uploadRef,
    DateTime? updatedAt,
  }) {
    final now = (updatedAt ?? DateTime.now()).toUtc();
    return (update(mediaJournal)..where((row) => row.mediaId.equals(mediaId)))
        .write(
      MediaJournalCompanion(
        uploadState: Value(uploadState),
        uploadRef: Value(uploadRef),
        updatedAt: Value(now),
      ),
    );
  }
}
