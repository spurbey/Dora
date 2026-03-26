import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_moment_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';

class LiveTrackingMomentRepository {
  LiveTrackingMomentRepository({
    required TrackingMomentDao trackingMomentDao,
    required SyncTaskDao syncTaskDao,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingMomentDao = trackingMomentDao,
        _syncTaskDao = syncTaskDao,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingMomentDao _trackingMomentDao;
  final SyncTaskDao _syncTaskDao;
  final DateTime Function() _now;
  final Uuid _uuid;

  Stream<List<TrackingMomentRow>> watchMomentsForTrip(String tripId) {
    return _trackingMomentDao.watchMomentsForTrip(tripId);
  }

  Future<List<TrackingMomentRow>> getMomentsForTrip(String tripId) {
    return _trackingMomentDao.getMomentsForTrip(tripId);
  }

  Future<String> createMomentNow({
    required String tripId,
    String? note,
    double? latitude,
    double? longitude,
    DateTime? capturedAt,
    String? candidateId,
    String? linkedTripPlaceId,
  }) async {
    final now = _now().toUtc();
    final momentId = _uuid.v4();
    final normalizedNote = _normalizeNote(note);
    const operation = 'create';
    await _trackingMomentDao.upsertMoment(
      TrackingMomentsCompanion.insert(
        id: momentId,
        tripId: tripId,
        candidateId: Value(candidateId),
        linkedTripPlaceId: Value(linkedTripPlaceId),
        source: const Value('manual'),
        capturedAt: (capturedAt ?? now).toUtc(),
        latitude: Value(latitude),
        longitude: Value(longitude),
        note: Value(normalizedNote),
        pendingOperation: const Value('create'),
        clientEventId: Value(_uuid.v4()),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.moment,
      entityId: momentId,
      operation: operation,
    );
    return momentId;
  }

  Future<bool> queueMomentUpdate({
    required String tripId,
    required String momentId,
    required String? note,
    required String? linkedTripPlaceId,
  }) async {
    final row = await _trackingMomentDao.getMomentById(momentId);
    if (row == null) {
      throw StateError('Moment not found: $momentId');
    }
    if (row.tripId != tripId) {
      throw StateError('Moment $momentId does not belong to trip $tripId');
    }

    final normalizedNote = _normalizeNote(note);
    final existingNote = _normalizeNote(row.note);
    if (normalizedNote == existingNote &&
        linkedTripPlaceId == row.linkedTripPlaceId) {
      return false;
    }

    final now = _now().toUtc();
    final operation = (row.pendingOperation ?? '').toLowerCase() == 'create'
        ? 'create'
        : 'update';
    await _trackingMomentDao.upsertMoment(
      TrackingMomentsCompanion.insert(
        id: row.id,
        tripId: row.tripId,
        candidateId: Value(row.candidateId),
        linkedTripPlaceId: Value(linkedTripPlaceId),
        source: Value(row.source),
        confidence: Value(row.confidence),
        capturedAt: row.capturedAt,
        latitude: Value(row.latitude),
        longitude: Value(row.longitude),
        note: Value(normalizedNote),
        mediaRefsJson: Value(row.mediaRefsJson),
        extraPayloadJson: Value(row.extraPayloadJson),
        lockedFieldsJson: Value(row.lockedFieldsJson),
        pendingOperation: Value(operation),
        clientEventId: Value(_uuid.v4()),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        serverUpdatedAt: Value(row.serverUpdatedAt),
        createdAt: row.createdAt,
        updatedAt: now,
      ),
    );
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.moment,
      entityId: row.id,
      operation: operation,
    );
    return true;
  }

  static String? _normalizeNote(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
