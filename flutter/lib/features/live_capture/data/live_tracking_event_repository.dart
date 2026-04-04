import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/sync_task_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_dao.dart';
import 'package:dora/core/storage/daos/tracking_event_media_dao.dart';
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

enum LiveTrackingMediaBindMode {
  place,
  route,
}

class LiveTrackingMediaCaptureResult {
  const LiveTrackingMediaCaptureResult({
    required this.eventId,
    required this.mediaId,
    required this.decision,
  });

  final String eventId;
  final String mediaId;
  final ResolvedPlaceDecision decision;
}

class LiveTrackingPlaceHint {
  const LiveTrackingPlaceHint({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.confidence,
    required this.reason,
    this.placeId,
  });

  final String name;
  final double latitude;
  final double longitude;
  final double confidence;
  final String reason;
  final String? placeId;
}

class LiveTrackingConfirmPlaceResult {
  const LiveTrackingConfirmPlaceResult({
    required this.placeId,
    required this.syncedRouteMediaIds,
    this.syncedRouteMediaRemoteIds = const <String>[],
  });

  final String placeId;
  /// Local row IDs for local state tracking.
  final List<String> syncedRouteMediaIds;
  /// Server-assigned IDs for backend rebind calls. Only includes media that
  /// has already synced and received a remote ID.
  final List<String> syncedRouteMediaRemoteIds;
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

extension LiveTrackingMediaBindModeWire on LiveTrackingMediaBindMode {
  String get wireName {
    switch (this) {
      case LiveTrackingMediaBindMode.place:
        return 'place';
      case LiveTrackingMediaBindMode.route:
        return 'route';
    }
  }
}

class LiveTrackingEventRepository {
  LiveTrackingEventRepository({
    required TrackingEventDao trackingEventDao,
    required TrackingEventMediaDao trackingEventMediaDao,
    required SyncTaskDao syncTaskDao,
    required LiveTrackingEventResolver resolver,
    DateTime Function()? now,
    Uuid? uuid,
  })  : _trackingEventDao = trackingEventDao,
        _trackingEventMediaDao = trackingEventMediaDao,
        _syncTaskDao = syncTaskDao,
        _resolver = resolver,
        _now = now ?? DateTime.now,
        _uuid = uuid ?? const Uuid();

  final TrackingEventDao _trackingEventDao;
  final TrackingEventMediaDao _trackingEventMediaDao;
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

  Stream<List<TrackingEventMediaRow>> watchMediaForTrip(String tripId) {
    return _trackingEventMediaDao.watchMediaForTrip(tripId);
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

  Future<LiveTrackingMediaCaptureResult> createMediaCaptureNow({
    required String tripId,
    required LiveTrackingEventType eventType,
    required String localPath,
    double? latitude,
    double? longitude,
    String? mimeType,
    int? fileSizeBytes,
    int? width,
    int? height,
    Map<String, dynamic>? payload,
  }) async {
    final now = _now().toUtc();
    final eventId = _uuid.v4();
    await _trackingEventDao.upsertEvent(
      TrackingEventsCompanion.insert(
        id: eventId,
        tripId: tripId,
        eventType: eventType.wireName,
        note: const Value(null),
        latitude: Value(latitude),
        longitude: Value(longitude),
        payloadJson: Value(
          _encodeJson(
            <String, dynamic>{
              ...?payload,
              'local_path': localPath,
            },
          ),
        ),
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

    final decision = await _resolver.resolveEventNow(eventId);
    final shouldBindToPlace =
        decision.state == 'resolved' && _normalizeText(decision.placeId) != null;
    final bindMode =
        shouldBindToPlace ? LiveTrackingMediaBindMode.place : LiveTrackingMediaBindMode.route;
    final bindState = bindMode == LiveTrackingMediaBindMode.place
        ? 'queued_place_upload'
        : 'queued_route_upload';
    final resolvedPlaceId = shouldBindToPlace ? _normalizeText(decision.placeId) : null;

    final mediaId = _uuid.v4();
    final effectiveMimeType = mimeType?.trim().isNotEmpty == true
        ? mimeType!.trim()
        : _inferMimeTypeFromPath(localPath);
    final effectiveFileSizeBytes = fileSizeBytes ?? _tryReadFileSize(localPath);

    await _trackingEventMediaDao.upsertMedia(
      TrackingEventMediaCompanion.insert(
        id: mediaId,
        tripId: tripId,
        eventId: eventId,
        bindMode: Value(bindMode.wireName),
        bindState: Value(bindState),
        tripPlaceId: Value(resolvedPlaceId),
        anchorLatitude: Value(latitude),
        anchorLongitude: Value(longitude),
        capturedAt: now,
        localPath: localPath,
        uploadRef: const Value(null),
        remoteMediaId: const Value(null),
        mimeType: Value(effectiveMimeType),
        fileSizeBytes: Value(effectiveFileSizeBytes),
        width: Value(width),
        height: Value(height),
        uploadStatus: Value(bindState),
        uploadProgress: const Value(0),
        retryCount: const Value(0),
        errorMessage: const Value(null),
        nextAttemptAt: const Value(null),
        workerSessionId: const Value(null),
        payloadJson: Value(_encodeJson(payload ?? const <String, dynamic>{})),
        syncStatus: const Value('pending'),
        localUpdatedAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await _syncTaskDao.upsertQueuedTask(
      id: _uuid.v4(),
      entityType: SyncEntityTypes.trackingEventMedia,
      entityId: mediaId,
      operation: 'upload',
      dependsOnEntityType: SyncEntityTypes.trackingEvent,
      dependsOnEntityId: eventId,
    );
    return LiveTrackingMediaCaptureResult(
      eventId: eventId,
      mediaId: mediaId,
      decision: decision,
    );
  }

  Future<ResolvedPlaceDecision> resolveEventNow(String eventId) =>
      _resolver.resolveEventNow(eventId);

  Future<int> reconcileUnresolved(
    String tripId, {
    int limit = 20,
  }) =>
      _resolver.reconcileUnresolved(tripId, limit: limit);

  Future<LiveTrackingConfirmPlaceResult?> confirmPlaceForReviewEvent({
    required String eventId,
    required LiveTrackingPlaceHint hint,
  }) async {
    final decision = await _resolver.confirmPlaceForEvent(
      eventId: eventId,
      tripPlaceId: hint.placeId,
      suggestedName: hint.name,
      suggestedCoordinate: AppLatLng(
        latitude: hint.latitude,
        longitude: hint.longitude,
      ),
    );
    final placeId = _normalizeText(decision.placeId);
    if (placeId == null) {
      return null;
    }

    await _trackingEventMediaDao.promotePendingMediaToPlace(
      eventId: eventId,
      tripPlaceId: placeId,
    );
    final syncedRoute = await _trackingEventMediaDao.getSyncedRouteMediaForEvent(
      eventId,
    );
    return LiveTrackingConfirmPlaceResult(
      placeId: placeId,
      // Local IDs for local state tracking.
      syncedRouteMediaIds: syncedRoute.map((row) => row.id).toList(growable: false),
      // Remote IDs for backend rebind calls — only include media that has synced.
      syncedRouteMediaRemoteIds: syncedRoute
          .where((row) => row.remoteMediaId != null && row.remoteMediaId!.trim().isNotEmpty)
          .map((row) => row.remoteMediaId!)
          .toList(growable: false),
    );
  }

  Future<void> keepReviewEventOnRoute(String eventId) async {
    await _resolver.keepEventOnRoute(eventId);
    await _trackingEventMediaDao.forcePendingMediaOnRoute(eventId: eventId);
  }

  List<LiveTrackingPlaceHint> parsePlaceHints(String? hintJson) {
    if (hintJson == null || hintJson.trim().isEmpty) {
      return const <LiveTrackingPlaceHint>[];
    }
    try {
      final decoded = jsonDecode(hintJson);
      if (decoded is! List) {
        return const <LiveTrackingPlaceHint>[];
      }
      final results = <LiveTrackingPlaceHint>[];
      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final name = _normalizeText(item['name']?.toString());
        final latitude = _asDouble(item['latitude']);
        final longitude = _asDouble(item['longitude']);
        final confidence = _asDouble(item['confidence']) ?? 0;
        final reason = _normalizeText(item['reason']?.toString()) ?? 'unknown';
        if (name == null || latitude == null || longitude == null) {
          continue;
        }
        results.add(
          LiveTrackingPlaceHint(
            name: name,
            latitude: latitude,
            longitude: longitude,
            confidence: confidence,
            reason: reason,
            placeId: _normalizeText(item['place_id']?.toString()),
          ),
        );
      }
      return results;
    } catch (_) {
      return const <LiveTrackingPlaceHint>[];
    }
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

  static String? _normalizeText(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  static String? _inferMimeTypeFromPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    if (normalized.endsWith('.webp')) {
      return 'image/webp';
    }
    if (normalized.endsWith('.mp4')) {
      return 'video/mp4';
    }
    if (normalized.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (normalized.endsWith('.webm')) {
      return 'video/webm';
    }
    return null;
  }

  static int? _tryReadFileSize(String path) {
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

  static double? _asDouble(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toDouble();
    }
    return double.tryParse(raw.toString());
  }
}
