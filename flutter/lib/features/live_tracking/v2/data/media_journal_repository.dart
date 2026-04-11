import 'package:drift/drift.dart';

import 'package:dora/core/storage/daos/v2/media_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

class V2MediaJournalRepository {
  const V2MediaJournalRepository(this._dao);

  final MediaJournalDao _dao;

  Future<MediaJournalRow?> getMediaById(String mediaId) =>
      _dao.getMediaById(mediaId);

  Future<int> upsertMedia({
    required String mediaId,
    required String eventId,
    required String sessionId,
    required String tripLocalId,
    required String mediaType,
    required String localUri,
    String? mimeType,
    int? bytesSize,
    int? durationMs,
    required DateTime capturedAt,
    int? widthPx,
    int? heightPx,
    String uploadState = 'local_only',
    String? uploadRef,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) {
    final now = (updatedAt ?? DateTime.now()).toUtc();
    return _dao.upsertMedia(
      MediaJournalCompanion.insert(
        mediaId: mediaId,
        eventId: eventId,
        sessionId: sessionId,
        tripLocalId: tripLocalId,
        mediaType: mediaType,
        localUri: localUri,
        mimeType: Value(mimeType),
        bytesSize: Value(bytesSize),
        durationMs: Value(durationMs),
        capturedAt: capturedAt.toUtc(),
        widthPx: Value(widthPx),
        heightPx: Value(heightPx),
        uploadState: Value(uploadState),
        uploadRef: Value(uploadRef),
        createdAt: createdAt.toUtc(),
        updatedAt: now,
      ),
    );
  }

  Future<List<MediaJournalRow>> listMediaForEvent(String eventId) =>
      _dao.listMediaForEvent(eventId);

  Stream<List<MediaJournalRow>> watchMediaForEvent(String eventId) =>
      _dao.watchMediaForEvent(eventId);

  Future<List<MediaJournalRow>> listMediaForSession(String sessionId) =>
      _dao.listMediaForSession(sessionId);

  Future<List<MediaJournalRow>> listMediaForTrip(String tripLocalId) =>
      _dao.listMediaForTrip(tripLocalId);

  Future<List<MediaJournalRow>> listMediaForTripFromCapturedAt(
    String tripLocalId,
    DateTime fromCapturedAt,
  ) =>
      _dao.listMediaForTripFromCapturedAt(tripLocalId, fromCapturedAt);

  Future<int> markUploadState({
    required String mediaId,
    required String uploadState,
    String? uploadRef,
    DateTime? updatedAt,
  }) =>
      _dao.markUploadState(
        mediaId: mediaId,
        uploadState: uploadState,
        uploadRef: uploadRef,
        updatedAt: updatedAt,
      );
}
