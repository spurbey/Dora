import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/storage/daos/media_attachments_dao.dart';
import 'package:dora/core/storage/daos/media_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/core/live_tracking/live_tracking_shared_models.dart'
    show LiveTrackingEventType;
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

class V2MediaCaptureResult {
  const V2MediaCaptureResult({
    required this.eventId,
    required this.mediaId,
    required this.resolverState,
  });

  final String eventId;
  final String mediaId;
  final String resolverState;
}

enum V2CapturedMediaKind {
  photo,
  video,
}

class V2LiveCaptureWriteException implements Exception {
  const V2LiveCaptureWriteException({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;

  @override
  String toString() => 'V2LiveCaptureWriteException($code): $message';
}

class V2LiveCaptureJournalRepository {
  V2LiveCaptureJournalRepository({
    required V2SessionJournalRepository sessionRepository,
    required V2EventJournalRepository eventRepository,
    required MediaDao mediaDao,
    required MediaAttachmentsDao mediaAttachmentsDao,
    required String Function() resolveOwnerUserId,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _sessionRepository = sessionRepository,
        _eventRepository = eventRepository,
        _mediaDao = mediaDao,
        _mediaAttachmentsDao = mediaAttachmentsDao,
        _resolveOwnerUserId = resolveOwnerUserId,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final V2SessionJournalRepository _sessionRepository;
  final V2EventJournalRepository _eventRepository;
  final MediaDao _mediaDao;
  final MediaAttachmentsDao _mediaAttachmentsDao;
  final String Function() _resolveOwnerUserId;
  final DateTime Function() _now;
  final Uuid _uuid;
  final Map<String, int> _eventSeqBySession = <String, int>{};

  Stream<List<EventJournalRow>> watchEventsForTrip(String tripId) {
    return _eventRepository.watchEventsForTrip(tripId);
  }

  Future<String> createEventNow({
    required String tripId,
    required LiveTrackingEventType eventType,
    required String note,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? payload,
  }) async {
    final session = await _activeSessionOrThrow(tripId);
    if (latitude == null || longitude == null) {
      throw const V2LiveCaptureWriteException(
        code: 'location_unavailable',
        message: 'Location is required to capture this event.',
      );
    }
    final now = _now().toUtc();
    final eventId = _uuid.v4();
    final eventSeq = await _nextEventSeq(session.sessionId);
    await _eventRepository.upsertEvent(
      eventId: eventId,
      sessionId: session.sessionId,
      tripLocalId: tripId,
      eventType: _eventTypeWireName(eventType),
      capturedAt: now,
      latitude: latitude,
      longitude: longitude,
      payloadJson: payload == null ? null : jsonEncode(payload),
      resolverState: 'geotag_unresolved',
      decisionSource: null,
      manualLock: 0,
      placeBindKind: null,
      placeBindId: null,
      placeBindName: null,
      geotagFinalReason: null,
      capturedWhilePaused: session.controlState == 'paused' ? 1 : 0,
      candidateSetVersion: 0,
      createdAt: now,
      updatedAt: now,
      eventSeq: eventSeq,
    );
    return eventId;
  }

  Future<V2MediaCaptureResult> createMediaCaptureNow({
    required String tripId,
    required LiveTrackingEventType eventType,
    required V2CapturedMediaKind mediaKind,
    required String localPath,
    double? latitude,
    double? longitude,
    String? mimeType,
    Map<String, dynamic>? payload,
  }) async {
    final session = await _activeSessionOrThrow(tripId);
    if (latitude == null || longitude == null) {
      throw const V2LiveCaptureWriteException(
        code: 'location_unavailable',
        message: 'Location is required to capture this media.',
      );
    }
    final now = _now().toUtc();
    final eventId = _uuid.v4();
    final eventSeq = await _nextEventSeq(session.sessionId);

    await _eventRepository.upsertEvent(
      eventId: eventId,
      sessionId: session.sessionId,
      tripLocalId: tripId,
      eventType: _eventTypeWireName(eventType),
      capturedAt: now,
      latitude: latitude,
      longitude: longitude,
      payloadJson: jsonEncode(
        <String, dynamic>{
          ...?payload,
          'local_path': localPath,
        },
      ),
      resolverState: 'geotag_unresolved',
      decisionSource: null,
      manualLock: 0,
      placeBindKind: null,
      placeBindId: null,
      placeBindName: null,
      geotagFinalReason: null,
      capturedWhilePaused: session.controlState == 'paused' ? 1 : 0,
      candidateSetVersion: 0,
      createdAt: now,
      updatedAt: now,
      eventSeq: eventSeq,
    );

    final mediaId = _uuid.v4();
    final ownerUserId = _resolveOwnerUserId();
    final resolvedMimeType =
        _resolveMimeType(path: localPath, mimeType: mimeType);
    final bytesSize = _readFileSize(localPath);

    await _mediaDao.insertMedia(
      MediaCompanion.insert(
        id: mediaId,
        ownerUserId: ownerUserId,
        originScope: 'live_capture',
        mediaType: Value(mediaKind.name),
        localUri: Value(localPath),
        mimeType: Value(resolvedMimeType),
        bytesSize: Value(bytesSize),
        capturedAt: now,
        latitude: Value(latitude),
        longitude: Value(longitude),
        uploadState: const Value('local_only'),
        uploadProgress: const Value(0.0),
        retryCount: const Value(0),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _mediaAttachmentsDao.insertAttachment(
      MediaAttachmentsCompanion.insert(
        id: _uuid.v4(),
        mediaId: mediaId,
        targetKind: 'trip_event',
        targetLocalId: eventId,
        role: 'capture',
        source: const Value('auto_geotag'),
        attachedAt: now,
      ),
    );

    await _mediaAttachmentsDao.insertAttachment(
      MediaAttachmentsCompanion.insert(
        id: _uuid.v4(),
        mediaId: mediaId,
        targetKind: 'trip',
        targetLocalId: tripId,
        role: 'capture',
        source: const Value('auto_geotag'),
        attachedAt: now,
      ),
    );

    return V2MediaCaptureResult(
      eventId: eventId,
      mediaId: mediaId,
      resolverState: 'geotag_unresolved',
    );
  }

  Future<SessionJournalRow> _activeSessionOrThrow(String tripId) async {
    final session = await _sessionRepository.getActiveOrPausedSessionForTrip(
      tripId,
    );
    if (session == null) {
      throw const V2LiveCaptureWriteException(
        code: 'no_active_session',
        message: 'Start live tracking before capturing events.',
      );
    }
    return session;
  }

  Future<int> _nextEventSeq(String sessionId) async {
    final cached = _eventSeqBySession[sessionId];
    if (cached != null) {
      final next = cached + 1;
      _eventSeqBySession[sessionId] = next;
      return next;
    }
    final existing = await _eventRepository.listEventsForSession(sessionId);
    final next = existing.isEmpty
        ? 1
        : existing.map((row) => row.eventSeq).reduce((a, b) => a > b ? a : b) +
            1;
    _eventSeqBySession[sessionId] = next;
    return next;
  }

  String? _resolveMimeType({
    required String path,
    required String? mimeType,
  }) {
    if (mimeType != null && mimeType.trim().isNotEmpty) {
      return mimeType.trim();
    }
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    if (lower.endsWith('.mp4')) {
      return 'video/mp4';
    }
    if (lower.endsWith('.mov')) {
      return 'video/quicktime';
    }
    return null;
  }

  int? _readFileSize(String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) {
        return null;
      }
      return file.lengthSync();
    } catch (_) {
      return null;
    }
  }

  String _eventTypeWireName(LiveTrackingEventType eventType) {
    switch (eventType) {
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
