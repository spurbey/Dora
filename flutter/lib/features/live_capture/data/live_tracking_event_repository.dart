import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/drift_database.dart';

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
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingEventDao = trackingEventDao,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingEventDao _trackingEventDao;
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
        syncStatus: const Value('local_only'),
        localUpdatedAt: now,
        serverUpdatedAt: const Value(null),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return eventId;
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

  static String _encodeJson(Object value) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return '{}';
    }
  }
}
