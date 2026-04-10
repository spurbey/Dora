import 'package:drift/drift.dart';

import 'package:dora/core/storage/daos/v2/route_point_journal_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

class V2RoutePointJournalRepository {
  const V2RoutePointJournalRepository(this._dao);

  final RoutePointJournalDao _dao;

  Future<RoutePointJournalRow?> getPointById(String pointId) =>
      _dao.getPointById(pointId);

  Future<int> upsertPoint({
    required String pointId,
    required String sessionId,
    required String tripLocalId,
    required DateTime capturedAt,
    required double latitude,
    required double longitude,
    double? accuracyM,
    double? speedMps,
    double? bearingDeg,
    double? altitudeM,
    String source = 'device_gps',
    required int pointSeq,
  }) {
    return _dao.upsertPoint(
      RoutePointJournalCompanion.insert(
        pointId: pointId,
        sessionId: sessionId,
        tripLocalId: tripLocalId,
        capturedAt: capturedAt.toUtc(),
        latitude: latitude,
        longitude: longitude,
        accuracyM: Value(accuracyM),
        speedMps: Value(speedMps),
        bearingDeg: Value(bearingDeg),
        altitudeM: Value(altitudeM),
        source: Value(source),
        pointSeq: pointSeq,
      ),
    );
  }

  Future<void> upsertPoints(Iterable<RoutePointJournalCompanion> rows) =>
      _dao.upsertPoints(rows);

  Future<List<RoutePointJournalRow>> listPointsForSession(String sessionId) =>
      _dao.listPointsForSession(sessionId);

  Stream<List<RoutePointJournalRow>> watchPointsForSession(String sessionId) =>
      _dao.watchPointsForSession(sessionId);

  Future<List<RoutePointJournalRow>> listPointsForTrip(String tripLocalId) =>
      _dao.listPointsForTrip(tripLocalId);
}
