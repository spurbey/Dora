import 'dart:convert';
import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/sync/live_tracking_sync_primitives.dart';
import 'package:dora/features/live_capture/data/live_tracking_event_resolver.dart';
import 'package:dora/features/live_capture/domain/resolved_place_decision.dart';

enum LiveTrackingEventType {
  note,
  warn,
  tag,
  photo,
  media,
}

extension LiveTrackingEventTypeWire on LiveTrackingEventType {
  String get wireName {
    switch (this) {
      case LiveTrackingEventType.note:
        return 'note';
      case LiveTrackingEventType.warn:
        return 'warn';
      case LiveTrackingEventType.tag:
        return 'tag';
      case LiveTrackingEventType.photo:
        return 'photo';
      case LiveTrackingEventType.media:
        return 'media';
    }
  }
}

class LiveTrackingEventRepository {
  LiveTrackingEventRepository({
    required TrackingEventDao trackingEventDao,
    required SyncTaskDao syncTaskDao,
    required LiveTrackingEventResolver resolver,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingEventDao = trackingEventDao,
        _syncTaskDao = syncTaskDao,
        _resolver = resolver,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingEventDao _trackingEventDao;
  final SyncTaskDao _syncTaskDao;
  final LiveTrackingEventResolver _resolver;
  final DateTime Function() _now;
  final Uuid _uuid;

  Stream<List<TrackingEventRow>> watchEventsForTrip(String tripId) {
    return _trackingEventDao.watchEventsForTrip(tripId);
  }

  Future<List<TrackingEventRow>> getEventsForTrip(String tripId) {
    return _trackingEventDao.getEventsForTrip(tripId);
  }

  Future<String> createEventNow({
    required String tripId,
    required LiveTrackingEventType eventType,
    String? note,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? payload,
  }) async {
    final now = _now().toUtc();
    final eventId = _uuid.v4();
    await _trackingEventDao.upsertEvent(
      TrackingEventsCompanion.insert(
        id: eventId,
        tripId: tripId,
        eventType: eventType.wireName,
        note: Value(_normalizeNote(note)),
        latitude: Value(latitude),
        longitude: Value(longitude),
        payloadJson: Value(_encodeJson(payload ?? const <String, dynamic>{})),
        clientEventId: Value(_uuid.v4()),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        serverUpdatedAt: const Value(null),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.trackingEvent,
      entityId: eventId,
      operation: 'upload',
    );
    unawaited(
      _resolver.resolveEventNow(eventId).catchError((_) => const ResolvedPlaceDecision(
            state: 'on_route_unresolved',
            confidence: 0,
            reasonCode: 'no_candidate',
          )),
    );
    return eventId;
  }

  Future<ResolvedPlaceDecision> resolveEventNow(String eventId) =>
      _resolver.resolveEventNow(eventId);

  Future<int> reconcileUnresolved(
    String tripId, {
    int limit = 20,
  }) =>
      _resolver.reconcileUnresolved(tripId, limit: limit);

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

  static String _encodeJson(Object value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return '{}';
    }
  }
}
