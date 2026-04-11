import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_projection_repository.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';
import 'package:dora/features/live_tracking/v2/data/event_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/media_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/route_point_journal_repository.dart';
import 'package:dora/features/live_tracking/v2/data/session_journal_repository.dart';

class V2LocalTimelineCompiler {
  V2LocalTimelineCompiler({
    required AppDatabase database,
    required V2LocalProjectionRepository projectionRepository,
    required V2SessionJournalRepository sessionRepository,
    required V2EventJournalRepository eventRepository,
    required V2MediaJournalRepository mediaRepository,
    required V2RoutePointJournalRepository routePointRepository,
    DateTime Function()? now,
  })  : _database = database,
        _projectionRepository = projectionRepository,
        _sessionRepository = sessionRepository,
        _eventRepository = eventRepository,
        _mediaRepository = mediaRepository,
        _routePointRepository = routePointRepository,
        _now = now ?? DateTime.now;

  static const int compilerVersion = 1;
  static const int projectionSchemaVersion = 1;
  static const double routeAssociationThresholdM = 100.0;

  final AppDatabase _database;
  final V2LocalProjectionRepository _projectionRepository;
  final V2SessionJournalRepository _sessionRepository;
  final V2EventJournalRepository _eventRepository;
  final V2MediaJournalRepository _mediaRepository;
  final V2RoutePointJournalRepository _routePointRepository;
  final DateTime Function() _now;
  final Map<String, Future<void>> _inFlightCompiles = <String, Future<void>>{};

  Future<void> compileTrip({
    required String tripId,
    bool forceFullRebuild = false,
    String? reason,
  }) {
    final inFlight = _inFlightCompiles[tripId];
    if (inFlight != null) {
      return inFlight;
    }
    final future = _compileTripInternal(
      tripId: tripId,
      forceFullRebuild: forceFullRebuild,
      reason: reason,
    ).whenComplete(() {
      _inFlightCompiles.remove(tripId);
    });
    _inFlightCompiles[tripId] = future;
    return future;
  }

  Future<void> _compileTripInternal({
    required String tripId,
    required bool forceFullRebuild,
    String? reason,
  }) async {
    final now = _now().toUtc();
    final cursor = await _projectionRepository.getCursor(tripId);
    final hasAnySourceRows = await _hasAnySourceRows(tripId);
    final hasIntegrityIssue = await _hasProjectionIntegrityIssue(tripId);
    final currentWatermarks = await _loadCurrentWatermarks(tripId);
    final existingProjectionCount =
        await _projectionRepository.countTimelineEntries(tripId);

    final requiresFullRebuild = forceFullRebuild ||
        cursor == null ||
        cursor.compilerVersion != compilerVersion ||
        cursor.projectionSchemaVersion != projectionSchemaVersion ||
        cursor.fullRebuildRequired == 1 ||
        hasIntegrityIssue ||
        (existingProjectionCount == 0 && hasAnySourceRows);

    if (!hasAnySourceRows) {
      await _database.transaction(() async {
        await _projectionRepository.replaceAllTimelineEntries(
          tripId: tripId,
          rows: const <TimelineProjectionLocalCompanion>[],
        );
        await _projectionRepository.replaceAllRouteSegments(
          tripId: tripId,
          rows: const <RouteProjectionLocalCompanion>[],
        );
        await _projectionRepository.upsertCursor(
          tripId: tripId,
          compilerVersion: compilerVersion,
          projectionSchemaVersion: projectionSchemaVersion,
          lastCompiledAt: now,
          dirtyReason: reason,
          fullRebuildRequired: 0,
        );
      });
      return;
    }

    final touchedSessions = requiresFullRebuild
        ? (await _sessionRepository.listSessionsForTrip(tripId))
            .map((session) => session.sessionId)
            .toSet()
        : await _resolveTouchedSessions(
            tripId: tripId,
            cursor: cursor,
          );

    final dirtyFrom = requiresFullRebuild
        ? await _minCapturedAtForTrip(tripId)
        : await _resolveDirtyFromCapturedAt(
            tripId: tripId,
            cursor: cursor,
            touchedSessions: touchedSessions,
          );

    if (!requiresFullRebuild && dirtyFrom == null && touchedSessions.isEmpty) {
      await _projectionRepository.upsertCursor(
        tripId: tripId,
        compilerVersion: compilerVersion,
        projectionSchemaVersion: projectionSchemaVersion,
        lastCompiledAt: now,
        lastEventUpdatedAt: currentWatermarks.maxEventUpdatedAt,
        lastMediaUpdatedAt: currentWatermarks.maxMediaUpdatedAt,
        lastRoutePointCapturedAt: currentWatermarks.maxRoutePointCapturedAt,
        lastSessionUpdatedAt: currentWatermarks.maxSessionUpdatedAt,
        dirtyReason: reason,
        fullRebuildRequired: 0,
      );
      return;
    }

    final sessions = await _sessionRepository.listSessionsForTrip(tripId);
    final sessionById = <String, SessionJournalRow>{
      for (final session in sessions) session.sessionId: session,
    };
    final routeRows = await _buildRouteSegments(
      tripId: tripId,
      sessions: sessions,
      touchedSessions: touchedSessions,
      fullRebuild: requiresFullRebuild,
      now: now,
    );

    await _database.transaction(() async {
      if (requiresFullRebuild) {
        await _projectionRepository.replaceAllRouteSegments(
          tripId: tripId,
          rows: routeRows,
        );
      } else if (touchedSessions.isNotEmpty) {
        await _projectionRepository.replaceRouteSegmentsForSessions(
          tripId: tripId,
          sessionIds: touchedSessions,
          rows: routeRows,
        );
      }

      final routeSegments =
          await _projectionRepository.listRouteSegments(tripId);
      final routeBySession = <String, V2RouteProjectionSegment>{
        for (final segment in routeSegments) segment.sessionId: segment,
      };

      final events = requiresFullRebuild
          ? await _eventRepository.listEventsForTripChronological(tripId)
          : await _eventRepository.listEventsForTripFromCapturedAt(
              tripId,
              dirtyFrom!,
            );
      final media = requiresFullRebuild
          ? await _mediaRepository.listMediaForTrip(tripId)
          : await _mediaRepository.listMediaForTripFromCapturedAt(
              tripId,
              dirtyFrom!,
            );
      final mediaByEvent = <String, List<MediaJournalRow>>{};
      for (final item in media) {
        mediaByEvent
            .putIfAbsent(item.eventId, () => <MediaJournalRow>[])
            .add(item);
      }
      for (final list in mediaByEvent.values) {
        list.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
      }

      final timelineRows = _buildTimelineRows(
        events: events,
        mediaByEvent: mediaByEvent,
        sessionById: sessionById,
        routeBySession: routeBySession,
        now: now,
      );

      if (requiresFullRebuild) {
        await _projectionRepository.replaceAllTimelineEntries(
          tripId: tripId,
          rows: timelineRows,
        );
      } else {
        await _projectionRepository.replaceTimelineEntriesFromCapturedAt(
          tripId: tripId,
          fromCapturedAt: dirtyFrom!,
          rows: timelineRows,
        );
      }

      await _projectionRepository.upsertCursor(
        tripId: tripId,
        compilerVersion: compilerVersion,
        projectionSchemaVersion: projectionSchemaVersion,
        lastCompiledAt: now,
        lastEventUpdatedAt: currentWatermarks.maxEventUpdatedAt,
        lastMediaUpdatedAt: currentWatermarks.maxMediaUpdatedAt,
        lastRoutePointCapturedAt: currentWatermarks.maxRoutePointCapturedAt,
        lastSessionUpdatedAt: currentWatermarks.maxSessionUpdatedAt,
        dirtyFromCapturedAt: null,
        dirtyReason: reason,
        fullRebuildRequired: 0,
      );
    });
  }

  Future<_SourceWatermarks> _loadCurrentWatermarks(String tripId) async {
    final maxEventUpdatedAt = await _readSingleDateTime(
      '''
      SELECT MAX(updated_at) AS value
      FROM event_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    final maxMediaUpdatedAt = await _readSingleDateTime(
      '''
      SELECT MAX(updated_at) AS value
      FROM media_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    final maxRoutePointCapturedAt = await _readSingleDateTime(
      '''
      SELECT MAX(captured_at) AS value
      FROM route_point_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    final maxSessionUpdatedAt = await _readSingleDateTime(
      '''
      SELECT MAX(updated_at) AS value
      FROM session_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    return _SourceWatermarks(
      maxEventUpdatedAt: maxEventUpdatedAt,
      maxMediaUpdatedAt: maxMediaUpdatedAt,
      maxRoutePointCapturedAt: maxRoutePointCapturedAt,
      maxSessionUpdatedAt: maxSessionUpdatedAt,
    );
  }

  Future<bool> _hasAnySourceRows(String tripId) async {
    final row = await _database.customSelect(
      '''
      SELECT
        (SELECT COUNT(1) FROM event_journal WHERE trip_local_id = ?) AS event_count,
        (SELECT COUNT(1) FROM media_journal WHERE trip_local_id = ?) AS media_count,
        (SELECT COUNT(1) FROM route_point_journal WHERE trip_local_id = ?) AS point_count
      ''',
      variables: <Variable<Object>>[
        Variable<String>(tripId),
        Variable<String>(tripId),
        Variable<String>(tripId),
      ],
      readsFrom: {
        _database.eventJournal,
        _database.mediaJournal,
        _database.routePointJournal,
      },
    ).getSingle();
    final eventCount = row.read<int>('event_count');
    final mediaCount = row.read<int>('media_count');
    final pointCount = row.read<int>('point_count');
    return eventCount > 0 || mediaCount > 0 || pointCount > 0;
  }

  Future<bool> _hasProjectionIntegrityIssue(String tripId) async {
    final row = await _database.customSelect(
      '''
      SELECT EXISTS (
        SELECT 1
        FROM timeline_projection_local AS t
        LEFT JOIN event_journal AS e
          ON t.source_kind = 'event'
         AND e.event_id = t.source_id
        LEFT JOIN media_journal AS m
          ON t.source_kind = 'media'
         AND m.media_id = t.source_id
        WHERE t.trip_local_id = ?
          AND (
            (t.source_kind = 'event' AND e.event_id IS NULL) OR
            (t.source_kind = 'media' AND m.media_id IS NULL)
          )
      ) AS has_issue
      ''',
      variables: <Variable<Object>>[Variable<String>(tripId)],
      readsFrom: {
        _database.timelineProjectionLocal,
        _database.eventJournal,
        _database.mediaJournal,
      },
    ).getSingle();
    return row.read<int>('has_issue') == 1;
  }

  Future<DateTime?> _minCapturedAtForTrip(String tripId) async {
    final eventMin = await _readSingleDateTime(
      '''
      SELECT MIN(captured_at) AS value
      FROM event_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    final mediaMin = await _readSingleDateTime(
      '''
      SELECT MIN(captured_at) AS value
      FROM media_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    final pointMin = await _readSingleDateTime(
      '''
      SELECT MIN(captured_at) AS value
      FROM route_point_journal
      WHERE trip_local_id = ?
      ''',
      <Variable<Object>>[Variable<String>(tripId)],
      'value',
    );
    return _minDateTime(<DateTime?>[eventMin, mediaMin, pointMin]);
  }

  Future<DateTime?> _resolveDirtyFromCapturedAt({
    required String tripId,
    required TimelineCompileCursorRow? cursor,
    required Set<String> touchedSessions,
  }) async {
    if (cursor == null) {
      return _minCapturedAtForTrip(tripId);
    }
    final eventMin = cursor.lastEventUpdatedAt == null
        ? await _readSingleDateTime(
            '''
            SELECT MIN(captured_at) AS value
            FROM event_journal
            WHERE trip_local_id = ?
            ''',
            <Variable<Object>>[Variable<String>(tripId)],
            'value',
          )
        : await _readSingleDateTime(
            '''
            SELECT MIN(captured_at) AS value
            FROM event_journal
            WHERE trip_local_id = ?
              AND updated_at > ?
            ''',
            <Variable<Object>>[
              Variable<String>(tripId),
              Variable<DateTime>(cursor.lastEventUpdatedAt!.toUtc()),
            ],
            'value',
          );
    final mediaEventMin = cursor.lastMediaUpdatedAt == null
        ? await _readSingleDateTime(
            '''
            SELECT MIN(e.captured_at) AS value
            FROM media_journal AS m
            JOIN event_journal AS e ON e.event_id = m.event_id
            WHERE m.trip_local_id = ?
            ''',
            <Variable<Object>>[Variable<String>(tripId)],
            'value',
          )
        : await _readSingleDateTime(
            '''
            SELECT MIN(e.captured_at) AS value
            FROM media_journal AS m
            JOIN event_journal AS e ON e.event_id = m.event_id
            WHERE m.trip_local_id = ?
              AND m.updated_at > ?
            ''',
            <Variable<Object>>[
              Variable<String>(tripId),
              Variable<DateTime>(cursor.lastMediaUpdatedAt!.toUtc()),
            ],
            'value',
          );
    final pointMin = cursor.lastRoutePointCapturedAt == null
        ? await _readSingleDateTime(
            '''
            SELECT MIN(captured_at) AS value
            FROM route_point_journal
            WHERE trip_local_id = ?
            ''',
            <Variable<Object>>[Variable<String>(tripId)],
            'value',
          )
        : await _readSingleDateTime(
            '''
            SELECT MIN(captured_at) AS value
            FROM route_point_journal
            WHERE trip_local_id = ?
              AND captured_at > ?
            ''',
            <Variable<Object>>[
              Variable<String>(tripId),
              Variable<DateTime>(cursor.lastRoutePointCapturedAt!.toUtc()),
            ],
            'value',
          );
    DateTime? sessionDerivedMin;
    if (touchedSessions.isNotEmpty) {
      final rawSessions = touchedSessions.toList();
      final rows = await _database.customSelect(
        '''
        SELECT MIN(captured_at) AS value
        FROM event_journal
        WHERE trip_local_id = ?
          AND session_id IN (${List.filled(rawSessions.length, '?').join(',')})
        ''',
        variables: <Variable<Object>>[
          Variable<String>(tripId),
          ...rawSessions.map((sessionId) => Variable<String>(sessionId)),
        ],
        readsFrom: {
          _database.eventJournal,
        },
      ).getSingle();
      sessionDerivedMin = _asDateTime(rows.data['value']);
    }
    return _minDateTime(
      <DateTime?>[
        eventMin,
        mediaEventMin,
        pointMin,
        sessionDerivedMin,
      ],
    );
  }

  Future<Set<String>> _resolveTouchedSessions({
    required String tripId,
    required TimelineCompileCursorRow? cursor,
  }) async {
    if (cursor == null) {
      final sessions = await _sessionRepository.listSessionsForTrip(tripId);
      return sessions.map((row) => row.sessionId).toSet();
    }
    final touched = <String>{};
    touched.addAll(
      await _readSessionIds(
        cursor.lastEventUpdatedAt == null
            ? '''
              SELECT DISTINCT session_id
              FROM event_journal
              WHERE trip_local_id = ?
              '''
            : '''
              SELECT DISTINCT session_id
              FROM event_journal
              WHERE trip_local_id = ?
                AND updated_at > ?
              ''',
        cursor.lastEventUpdatedAt == null
            ? <Variable<Object>>[Variable<String>(tripId)]
            : <Variable<Object>>[
                Variable<String>(tripId),
                Variable<DateTime>(cursor.lastEventUpdatedAt!.toUtc()),
              ],
      ),
    );
    touched.addAll(
      await _readSessionIds(
        cursor.lastMediaUpdatedAt == null
            ? '''
              SELECT DISTINCT e.session_id AS session_id
              FROM media_journal AS m
              JOIN event_journal AS e ON e.event_id = m.event_id
              WHERE m.trip_local_id = ?
              '''
            : '''
              SELECT DISTINCT e.session_id AS session_id
              FROM media_journal AS m
              JOIN event_journal AS e ON e.event_id = m.event_id
              WHERE m.trip_local_id = ?
                AND m.updated_at > ?
              ''',
        cursor.lastMediaUpdatedAt == null
            ? <Variable<Object>>[Variable<String>(tripId)]
            : <Variable<Object>>[
                Variable<String>(tripId),
                Variable<DateTime>(cursor.lastMediaUpdatedAt!.toUtc()),
              ],
      ),
    );
    touched.addAll(
      await _readSessionIds(
        cursor.lastRoutePointCapturedAt == null
            ? '''
              SELECT DISTINCT session_id
              FROM route_point_journal
              WHERE trip_local_id = ?
              '''
            : '''
              SELECT DISTINCT session_id
              FROM route_point_journal
              WHERE trip_local_id = ?
                AND captured_at > ?
              ''',
        cursor.lastRoutePointCapturedAt == null
            ? <Variable<Object>>[Variable<String>(tripId)]
            : <Variable<Object>>[
                Variable<String>(tripId),
                Variable<DateTime>(cursor.lastRoutePointCapturedAt!.toUtc()),
              ],
      ),
    );
    touched.addAll(
      await _readSessionIds(
        cursor.lastSessionUpdatedAt == null
            ? '''
              SELECT DISTINCT session_id
              FROM session_journal
              WHERE trip_local_id = ?
              '''
            : '''
              SELECT DISTINCT session_id
              FROM session_journal
              WHERE trip_local_id = ?
                AND updated_at > ?
              ''',
        cursor.lastSessionUpdatedAt == null
            ? <Variable<Object>>[Variable<String>(tripId)]
            : <Variable<Object>>[
                Variable<String>(tripId),
                Variable<DateTime>(cursor.lastSessionUpdatedAt!.toUtc()),
              ],
      ),
    );
    return touched;
  }

  Future<List<RouteProjectionLocalCompanion>> _buildRouteSegments({
    required String tripId,
    required List<SessionJournalRow> sessions,
    required Set<String> touchedSessions,
    required bool fullRebuild,
    required DateTime now,
  }) async {
    final sessionIds = fullRebuild
        ? sessions.map((session) => session.sessionId).toList(growable: false)
        : touchedSessions.toList(growable: false);
    if (sessionIds.isEmpty) {
      return const <RouteProjectionLocalCompanion>[];
    }
    final sessionById = <String, SessionJournalRow>{
      for (final session in sessions) session.sessionId: session,
    };
    final rows = <RouteProjectionLocalCompanion>[];
    for (final sessionId in sessionIds) {
      final points =
          await _routePointRepository.listPointsForSession(sessionId);
      if (points.length < 2) {
        continue;
      }
      final session = sessionById[sessionId];
      if (session == null) {
        continue;
      }
      final geometry = points
          .map(
            (point) => AppLatLng(
              latitude: point.latitude,
              longitude: point.longitude,
            ),
          )
          .toList(growable: false);
      final distanceM = _pathDistanceMeters(geometry);
      final bbox = _bbox(geometry);
      final startedAt = session.startedAt ?? points.first.capturedAt;
      final endedAt = session.endedAt ?? points.last.capturedAt;
      rows.add(
        RouteProjectionLocalCompanion.insert(
          segmentKey: 'seg:$tripId:$sessionId',
          tripLocalId: tripId,
          sessionId: sessionId,
          startedAt: startedAt.toUtc(),
          endedAt: endedAt.toUtc(),
          pointsCount: geometry.length,
          distanceM: distanceM,
          bboxMinLat: bbox.minLat,
          bboxMinLon: bbox.minLon,
          bboxMaxLat: bbox.maxLat,
          bboxMaxLon: bbox.maxLon,
          geometryJson: jsonEncode(
            geometry
                .map(
                  (point) => <String, dynamic>{
                    'lat': point.latitude,
                    'lon': point.longitude,
                  },
                )
                .toList(growable: false),
          ),
          updatedAt: now,
          compilerVersion: compilerVersion,
        ),
      );
    }
    return rows;
  }

  List<TimelineProjectionLocalCompanion> _buildTimelineRows({
    required List<EventJournalRow> events,
    required Map<String, List<MediaJournalRow>> mediaByEvent,
    required Map<String, SessionJournalRow> sessionById,
    required Map<String, V2RouteProjectionSegment> routeBySession,
    required DateTime now,
  }) {
    final rows = <TimelineProjectionLocalCompanion>[];
    for (final event in events) {
      final session = sessionById[event.sessionId];
      final routeSegment = routeBySession[event.sessionId];
      final bucket = _bucketForResolverState(event.resolverState);
      final routeAssociation = _resolveRouteAssociation(
        routeSegment: routeSegment,
        anchor: AppLatLng(
          latitude: event.latitude,
          longitude: event.longitude,
        ),
        bucketType: bucket,
      );
      rows.add(
        TimelineProjectionLocalCompanion.insert(
          entryId: 'event:${event.eventId}',
          tripLocalId: event.tripLocalId,
          sessionId: event.sessionId,
          capturedAt: event.capturedAt.toUtc(),
          sourceKind: 'event',
          sourceId: event.eventId,
          eventType: event.eventType,
          bucketType: bucket,
          placeBindKind: Value(event.placeBindKind),
          placeBindId: Value(event.placeBindId),
          placeBindName: Value(event.placeBindName),
          decisionSource: Value(event.decisionSource),
          manualLock: Value(event.manualLock),
          anchorLatitude: event.latitude,
          anchorLongitude: event.longitude,
          title: _titleForEvent(event),
          subtitle: Value(_subtitleForEvent(event)),
          syncChipState: _syncChipStateForSession(session),
          routeSegmentKey: Value(routeAssociation.segmentKey),
          routeDistanceM: Value(routeAssociation.distanceM),
          renderPayloadJson: Value(
            jsonEncode(
              <String, dynamic>{
                'resolver_state': event.resolverState,
                'payload_json': event.payloadJson,
                'geotag_final_reason': event.geotagFinalReason,
              },
            ),
          ),
          compiledAt: now,
          compilerVersion: compilerVersion,
        ),
      );

      final mediaItems =
          mediaByEvent[event.eventId] ?? const <MediaJournalRow>[];
      for (final media in mediaItems) {
        rows.add(
          TimelineProjectionLocalCompanion.insert(
            entryId: 'media:${media.mediaId}',
            tripLocalId: media.tripLocalId,
            sessionId: media.sessionId,
            capturedAt: media.capturedAt.toUtc(),
            sourceKind: 'media',
            sourceId: media.mediaId,
            eventType: media.mediaType,
            bucketType: bucket,
            placeBindKind: Value(event.placeBindKind),
            placeBindId: Value(event.placeBindId),
            placeBindName: Value(event.placeBindName),
            decisionSource: Value(event.decisionSource),
            manualLock: Value(event.manualLock),
            anchorLatitude: event.latitude,
            anchorLongitude: event.longitude,
            title: _titleForMedia(media),
            subtitle: Value(_subtitleForMedia(media)),
            syncChipState: _syncChipStateForSession(session),
            routeSegmentKey: Value(routeAssociation.segmentKey),
            routeDistanceM: Value(routeAssociation.distanceM),
            renderPayloadJson: Value(
              jsonEncode(
                <String, dynamic>{
                  'event_id': media.eventId,
                  'local_uri': media.localUri,
                  'upload_state': media.uploadState,
                },
              ),
            ),
            compiledAt: now,
            compilerVersion: compilerVersion,
          ),
        );
      }
    }
    return rows;
  }

  _RouteAssociation _resolveRouteAssociation({
    required V2RouteProjectionSegment? routeSegment,
    required AppLatLng anchor,
    required String bucketType,
  }) {
    if (routeSegment == null || bucketType != 'on_route') {
      return const _RouteAssociation();
    }
    var minDistance = double.infinity;
    for (final point in routeSegment.geometry) {
      final distance = _haversineMeters(
        anchor.latitude,
        anchor.longitude,
        point.latitude,
        point.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    if (!minDistance.isFinite || minDistance > routeAssociationThresholdM) {
      return const _RouteAssociation();
    }
    return _RouteAssociation(
      segmentKey: routeSegment.segmentKey,
      distanceM: minDistance,
    );
  }

  String _bucketForResolverState(String resolverState) {
    switch (resolverState) {
      case 'place_bound':
        return 'place';
      case 'geotag_final':
        return 'on_route';
      case 'review_required':
      case 'geotag_unresolved':
      default:
        return 'needs_review';
    }
  }

  String _syncChipStateForSession(SessionJournalRow? session) {
    if (session == null) {
      return 'local_only';
    }
    switch (session.controlState) {
      case 'sealed':
        return 'commit_pending';
      case 'planned':
      case 'active':
      case 'paused':
      default:
        return 'local_only';
    }
  }

  String _titleForEvent(EventJournalRow event) {
    final note = _extractNote(event.payloadJson);
    if (note != null && note.isNotEmpty) {
      return note;
    }
    switch (event.eventType) {
      case 'warn':
        return 'Warning';
      case 'tag':
        return 'Tag';
      case 'photo':
        return 'Photo';
      case 'media':
        return 'Media';
      case 'note':
      default:
        return 'Note';
    }
  }

  String? _subtitleForEvent(EventJournalRow event) {
    if (event.placeBindName != null && event.placeBindName!.trim().isNotEmpty) {
      return 'Bound to ${event.placeBindName!.trim()}';
    }
    if (event.resolverState == 'review_required') {
      return 'Needs place review';
    }
    if (event.resolverState == 'geotag_unresolved') {
      return 'Pending local resolve';
    }
    if (event.resolverState == 'geotag_final') {
      return 'Geotag (On Route)';
    }
    return null;
  }

  String _titleForMedia(MediaJournalRow media) {
    switch (media.mediaType) {
      case 'photo':
        return 'Photo';
      case 'media':
        return 'Media';
      default:
        return 'Capture';
    }
  }

  String? _subtitleForMedia(MediaJournalRow media) {
    switch (media.uploadState) {
      case 'local_only':
        return 'Pending commit';
      case 'staged_for_commit':
        return 'Ready for commit';
      default:
        return null;
    }
  }

  String? _extractNote(String? payloadJson) {
    if (payloadJson == null || payloadJson.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final note = decoded['note'];
      if (note is String && note.trim().isNotEmpty) {
        return note.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<DateTime?> _readSingleDateTime(
    String sql,
    List<Variable<Object>> variables,
    String alias,
  ) async {
    final row = await _database.customSelect(
      sql,
      variables: variables,
      readsFrom: {
        _database.eventJournal,
        _database.mediaJournal,
        _database.routePointJournal,
        _database.sessionJournal,
      },
    ).getSingle();
    return _asDateTime(row.data[alias]);
  }

  Future<Set<String>> _readSessionIds(
    String sql,
    List<Variable<Object>> variables,
  ) async {
    final rows = await _database.customSelect(
      sql,
      variables: variables,
      readsFrom: {
        _database.eventJournal,
        _database.mediaJournal,
        _database.routePointJournal,
        _database.sessionJournal,
      },
    ).get();
    return rows
        .map((row) => row.read<String?>('session_id')?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is int) {
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    if (value is String) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }

  DateTime? _minDateTime(List<DateTime?> values) {
    DateTime? minValue;
    for (final value in values) {
      if (value == null) {
        continue;
      }
      if (minValue == null || value.isBefore(minValue)) {
        minValue = value;
      }
    }
    return minValue;
  }

  _Bounds _bbox(List<AppLatLng> geometry) {
    var minLat = geometry.first.latitude;
    var maxLat = geometry.first.latitude;
    var minLon = geometry.first.longitude;
    var maxLon = geometry.first.longitude;
    for (final point in geometry.skip(1)) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLon = math.min(minLon, point.longitude);
      maxLon = math.max(maxLon, point.longitude);
    }
    return _Bounds(
      minLat: minLat,
      minLon: minLon,
      maxLat: maxLat,
      maxLon: maxLon,
    );
  }

  double _pathDistanceMeters(List<AppLatLng> points) {
    if (points.length < 2) {
      return 0;
    }
    var distance = 0.0;
    for (var i = 1; i < points.length; i += 1) {
      final prev = points[i - 1];
      final next = points[i];
      distance += _haversineMeters(
        prev.latitude,
        prev.longitude,
        next.latitude,
        next.longitude,
      );
    }
    return distance;
  }

  double _haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusM = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180.0;
}

class _SourceWatermarks {
  const _SourceWatermarks({
    required this.maxEventUpdatedAt,
    required this.maxMediaUpdatedAt,
    required this.maxRoutePointCapturedAt,
    required this.maxSessionUpdatedAt,
  });

  final DateTime? maxEventUpdatedAt;
  final DateTime? maxMediaUpdatedAt;
  final DateTime? maxRoutePointCapturedAt;
  final DateTime? maxSessionUpdatedAt;
}

class _Bounds {
  const _Bounds({
    required this.minLat,
    required this.minLon,
    required this.maxLat,
    required this.maxLon,
  });

  final double minLat;
  final double minLon;
  final double maxLat;
  final double maxLon;
}

class _RouteAssociation {
  const _RouteAssociation({
    this.segmentKey,
    this.distanceM,
  });

  final String? segmentKey;
  final double? distanceM;
}
