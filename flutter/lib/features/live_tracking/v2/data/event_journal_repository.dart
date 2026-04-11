import 'package:drift/drift.dart';

import 'package:dora/core/storage/daos/v2/event_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

class V2EventJournalRepository {
  const V2EventJournalRepository(this._dao);

  final EventJournalDao _dao;

  Future<EventJournalRow?> getEventById(String eventId) =>
      _dao.getEventById(eventId);

  Future<int> upsertEvent({
    required String eventId,
    required String sessionId,
    required String tripLocalId,
    required String eventType,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    double? anchorAccuracyM,
    String? payloadJson,
    required String resolverState,
    String? decisionSource,
    int manualLock = 0,
    String? placeBindKind,
    String? placeBindId,
    String? placeBindName,
    String? geotagFinalReason,
    int capturedWhilePaused = 0,
    int candidateSetVersion = 0,
    DateTime? resolvedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
    required int eventSeq,
  }) {
    final now = (updatedAt ?? DateTime.now()).toUtc();
    return _dao.upsertEvent(
      EventJournalCompanion.insert(
        eventId: eventId,
        sessionId: sessionId,
        tripLocalId: tripLocalId,
        eventType: eventType,
        capturedAt: capturedAt.toUtc(),
        latitude: latitude,
        longitude: longitude,
        anchorAccuracyM: Value(anchorAccuracyM),
        payloadJson: Value(payloadJson),
        resolverState: resolverState,
        decisionSource: Value(decisionSource),
        manualLock: Value(manualLock),
        placeBindKind: Value(placeBindKind),
        placeBindId: Value(placeBindId),
        placeBindName: Value(placeBindName),
        geotagFinalReason: Value(geotagFinalReason),
        capturedWhilePaused: Value(capturedWhilePaused),
        candidateSetVersion: Value(candidateSetVersion),
        resolvedAt: Value(resolvedAt?.toUtc()),
        createdAt: createdAt.toUtc(),
        updatedAt: now,
        eventSeq: eventSeq,
      ),
    );
  }

  Future<List<EventJournalRow>> listEventsForSession(String sessionId) =>
      _dao.listEventsForSession(sessionId);

  Future<List<EventJournalRow>> listEventsForTrip(String tripLocalId) =>
      _dao.listEventsForTrip(tripLocalId);

  Stream<List<EventJournalRow>> watchEventsForTrip(String tripLocalId) =>
      _dao.watchEventsForTrip(tripLocalId);

  Future<List<EventJournalRow>> listUnresolvedEventsForTrip(
    String tripLocalId, {
    int limit = 50,
  }) =>
      _dao.listUnresolvedEventsForTrip(tripLocalId, limit: limit);

  Stream<List<EventJournalRow>> watchUnresolvedEventsForTrip(
    String tripLocalId, {
    int limit = 50,
  }) =>
      _dao.watchUnresolvedEventsForTrip(tripLocalId, limit: limit);

  Future<int> updateResolverOutcome({
    required String eventId,
    required String resolverState,
    String? decisionSource,
    int? manualLock,
    String? placeBindKind,
    String? placeBindId,
    String? placeBindName,
    String? geotagFinalReason,
    int? candidateSetVersion,
    DateTime? resolvedAt,
    DateTime? updatedAt,
  }) {
    return _dao.updateResolverOutcome(
      eventId: eventId,
      resolverState: resolverState,
      decisionSource: decisionSource,
      manualLock: manualLock,
      placeBindKind: placeBindKind,
      placeBindId: placeBindId,
      placeBindName: placeBindName,
      geotagFinalReason: geotagFinalReason,
      candidateSetVersion: candidateSetVersion,
      resolvedAt: resolvedAt,
      updatedAt: updatedAt,
    );
  }
}
