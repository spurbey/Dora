import 'package:drift/drift.dart';

import 'package:dora/core/storage/daos/v2/session_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

class V2SessionJournalRepository {
  const V2SessionJournalRepository(this._dao);

  final SessionJournalDao _dao;

  Future<SessionJournalRow?> getSessionById(String sessionId) =>
      _dao.getSessionById(sessionId);

  Future<List<SessionJournalRow>> listSessionsForTrip(String tripLocalId) =>
      _dao.listSessionsForTrip(tripLocalId);

  Stream<List<SessionJournalRow>> watchSessionsForTrip(String tripLocalId) =>
      _dao.watchSessionsForTrip(tripLocalId);

  Future<SessionJournalRow?> getLatestSessionForTrip(String tripLocalId) =>
      _dao.getLatestSessionForTrip(tripLocalId);

  Stream<SessionJournalRow?> watchLatestSessionForTrip(String tripLocalId) =>
      _dao.watchLatestSessionForTrip(tripLocalId);

  Future<SessionJournalRow?> getActiveOrPausedSessionForTrip(
          String tripLocalId) =>
      _dao.getActiveOrPausedSessionForTrip(tripLocalId);

  Future<List<SessionJournalRow>> listSessionsByStates(Set<String> states) =>
      _dao.listSessionsByStates(states);

  Future<int> upsertSession({
    required String sessionId,
    required String tripLocalId,
    String? serverTripId,
    required String controlState,
    int stopServerPending = 0,
    DateTime? startAckAt,
    DateTime? stopAckAt,
    DateTime? startedAt,
    DateTime? endedAt,
    String? stopClientEventId,
    int sealVersion = 0,
    int startRequestSeq = 0,
    required int sessionSeq,
    required String deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = (updatedAt ?? DateTime.now()).toUtc();
    return _dao.upsertSession(
      SessionJournalCompanion.insert(
        sessionId: sessionId,
        tripLocalId: tripLocalId,
        controlState: controlState,
        stopServerPending: Value(stopServerPending),
        startAckAt: Value(startAckAt?.toUtc()),
        stopAckAt: Value(stopAckAt?.toUtc()),
        startedAt: Value(startedAt?.toUtc()),
        endedAt: Value(endedAt?.toUtc()),
        stopClientEventId: Value(stopClientEventId),
        createdAt: (createdAt ?? now).toUtc(),
        updatedAt: now,
        sealVersion: Value(sealVersion),
        startRequestSeq: Value(startRequestSeq),
        sessionSeq: sessionSeq,
        deviceId: deviceId,
        serverTripId: Value(serverTripId),
      ),
    );
  }

  Future<int> upsertActivityWindow({
    required String windowId,
    required String sessionId,
    required String tripLocalId,
    required String windowKind,
    required DateTime startedAt,
    DateTime? endedAt,
    required int windowSeq,
  }) {
    return _dao.upsertActivityWindow(
      SessionActivityWindowCompanion.insert(
        windowId: windowId,
        sessionId: sessionId,
        tripLocalId: tripLocalId,
        windowKind: windowKind,
        startedAt: startedAt.toUtc(),
        endedAt: Value(endedAt?.toUtc()),
        windowSeq: windowSeq,
      ),
    );
  }

  Future<List<SessionActivityWindowRow>> listActivityWindowsForSession(
    String sessionId,
  ) =>
      _dao.listActivityWindowsForSession(sessionId);

  Stream<List<SessionActivityWindowRow>> watchActivityWindowsForSession(
    String sessionId,
  ) =>
      _dao.watchActivityWindowsForSession(sessionId);
}
