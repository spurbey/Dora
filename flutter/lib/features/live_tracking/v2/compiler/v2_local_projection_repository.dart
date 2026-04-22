import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/daos/v2/route_projection_local_dao.dart';
import 'package:dora/core/storage/daos/v2/timeline_compile_cursor_dao.dart';
import 'package:dora/core/storage/daos/v2/timeline_projection_local_dao.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_projection_models.dart';

class V2LocalProjectionRepository {
  static const int displayOrderNormalizeEvery = 200;
  static const double displayOrderMinGapThreshold = 1e-6;

  const V2LocalProjectionRepository({
    required TimelineProjectionLocalDao timelineDao,
    required RouteProjectionLocalDao routeDao,
    required TimelineCompileCursorDao cursorDao,
  })  : _timelineDao = timelineDao,
        _routeDao = routeDao,
        _cursorDao = cursorDao;

  final TimelineProjectionLocalDao _timelineDao;
  final RouteProjectionLocalDao _routeDao;
  final TimelineCompileCursorDao _cursorDao;

  Stream<List<V2TimelineProjectionEntry>> watchTimelineEntries(String tripId) {
    return _timelineDao.watchEntriesForTrip(tripId).map(
          (rows) => rows.map(_mapTimelineRow).toList(growable: false),
        );
  }

  Future<List<V2TimelineProjectionEntry>> listTimelineEntries(String tripId) {
    return _timelineDao
        .listEntriesForTrip(tripId)
        .then((rows) => rows.map(_mapTimelineRow).toList(growable: false));
  }

  Stream<List<V2RouteProjectionSegment>> watchRouteSegments(String tripId) {
    return _routeDao.watchSegmentsForTrip(tripId).map(
          (rows) => rows.map(_mapRouteRow).toList(growable: false),
        );
  }

  Future<List<V2RouteProjectionSegment>> listRouteSegments(String tripId) {
    return _routeDao
        .listSegmentsForTrip(tripId)
        .then((rows) => rows.map(_mapRouteRow).toList(growable: false));
  }

  Future<TimelineCompileCursorRow?> getCursor(String tripId) =>
      _cursorDao.getCursorForTrip(tripId);

  Future<void> upsertCursor({
    required String tripId,
    required int compilerVersion,
    required int projectionSchemaVersion,
    required DateTime lastCompiledAt,
    DateTime? lastEventUpdatedAt,
    DateTime? lastMediaUpdatedAt,
    DateTime? lastRoutePointCapturedAt,
    DateTime? lastSessionUpdatedAt,
    DateTime? dirtyFromCapturedAt,
    String? dirtyReason,
    int fullRebuildRequired = 0,
    DateTime? updatedAt,
  }) async {
    await _cursorDao.upsertCursor(
      TimelineCompileCursorCompanion.insert(
        tripLocalId: tripId,
        compilerVersion: compilerVersion,
        projectionSchemaVersion: projectionSchemaVersion,
        lastCompiledAt: lastCompiledAt.toUtc(),
        lastEventUpdatedAt: Value(lastEventUpdatedAt?.toUtc()),
        lastMediaUpdatedAt: Value(lastMediaUpdatedAt?.toUtc()),
        lastRoutePointCapturedAt: Value(lastRoutePointCapturedAt?.toUtc()),
        lastSessionUpdatedAt: Value(lastSessionUpdatedAt?.toUtc()),
        dirtyFromCapturedAt: Value(dirtyFromCapturedAt?.toUtc()),
        dirtyReason: Value(dirtyReason),
        fullRebuildRequired: Value(fullRebuildRequired),
        updatedAt: (updatedAt ?? DateTime.now()).toUtc(),
      ),
    );
  }

  Future<void> clearCursor(String tripId) => _cursorDao.clearCursorForTrip(
        tripId,
      );

  Future<void> replaceAllTimelineEntries({
    required String tripId,
    required List<TimelineProjectionLocalCompanion> rows,
  }) =>
      _timelineDao.replaceAllEntriesForTrip(tripLocalId: tripId, rows: rows);

  Future<void> replaceTimelineEntriesFromCapturedAt({
    required String tripId,
    required DateTime fromCapturedAt,
    required List<TimelineProjectionLocalCompanion> rows,
  }) =>
      _timelineDao.replaceEntriesForTripFromCapturedAt(
        tripLocalId: tripId,
        fromCapturedAt: fromCapturedAt,
        rows: rows,
      );

  Future<void> replaceAllRouteSegments({
    required String tripId,
    required List<RouteProjectionLocalCompanion> rows,
  }) =>
      _routeDao.replaceAllSegmentsForTrip(tripLocalId: tripId, rows: rows);

  Future<void> replaceRouteSegmentsForSessions({
    required String tripId,
    required Set<String> sessionIds,
    required List<RouteProjectionLocalCompanion> rows,
  }) =>
      _routeDao.replaceSegmentsForSessions(
        tripLocalId: tripId,
        sessionIds: sessionIds,
        rows: rows,
      );

  Future<int> countTimelineEntries(String tripId) =>
      _timelineDao.countEntriesForTrip(tripId);

  Future<Map<String, double>> listDisplayOrderByEntryIdForTrip(String tripId) =>
      _timelineDao.listDisplayOrderByEntryIdForTrip(tripId);

  Future<Map<String, double>> listDisplayOrderByEntryIdForTripFromCapturedAt({
    required String tripId,
    required DateTime fromCapturedAt,
  }) =>
      _timelineDao.listDisplayOrderByEntryIdForTripFromCapturedAt(
        tripLocalId: tripId,
        fromCapturedAt: fromCapturedAt,
      );

  Future<bool> updateEntryDisplayOrder({
    required String tripId,
    required String entryId,
    required double displayOrder,
    int? reorderOperationCount,
  }) async {
    final didUpdate = await _timelineDao.updateDisplayOrder(
      tripLocalId: tripId,
      entryId: entryId,
      displayOrder: displayOrder,
    );
    if (!didUpdate) {
      return false;
    }

    var shouldNormalize = reorderOperationCount != null &&
        reorderOperationCount >= displayOrderNormalizeEvery;
    if (!shouldNormalize) {
      final minGap = await _timelineDao.minDisplayOrderGapForTrip(tripId);
      shouldNormalize = minGap != null && minGap <= displayOrderMinGapThreshold;
    }
    if (shouldNormalize) {
      await _timelineDao.normalizeDisplayOrderForTrip(tripId);
    }
    return true;
  }

  Future<void> normalizeDisplayOrderForTrip(String tripId) =>
      _timelineDao.normalizeDisplayOrderForTrip(tripId);

  Future<double?> computeMidpointDisplayOrder({
    required String tripId,
    String? previousEntryId,
    String? nextEntryId,
  }) async {
    final orderMap =
        await _timelineDao.listDisplayOrderByEntryIdForTrip(tripId);
    final previous = previousEntryId == null ? null : orderMap[previousEntryId];
    final next = nextEntryId == null ? null : orderMap[nextEntryId];
    if (previous != null && next != null) {
      return (previous + next) / 2.0;
    }
    if (previous != null) {
      return previous + 1000.0;
    }
    if (next != null) {
      return next - 1000.0;
    }
    if (orderMap.isEmpty) {
      return null;
    }
    final values = orderMap.values.toList(growable: false);
    final minValue = values.reduce(math.min);
    return minValue - 1000.0;
  }

  Future<void> upsertFromServerProjection({
    required String tripId,
    required List<TimelineProjectionLocalCompanion> timelineRows,
    required List<RouteProjectionLocalCompanion> routeRows,
  }) async {
    final existingDisplayOrderByEntryId =
        await _timelineDao.listDisplayOrderByEntryIdForTrip(tripId);

    TimelineProjectionLocalCompanion withPreservedDisplayOrder(
      TimelineProjectionLocalCompanion row,
    ) {
      final entryId = row.entryId.present ? row.entryId.value : null;
      if (entryId == null) {
        return row;
      }
      final preservedDisplayOrder = existingDisplayOrderByEntryId[entryId];
      if (preservedDisplayOrder == null) {
        return row;
      }
      return row.copyWith(
        displayOrder: Value(preservedDisplayOrder),
      );
    }

    final normalizedTimelineRows =
        timelineRows.map(withPreservedDisplayOrder).toList(growable: false);

    await _timelineDao.replaceAllEntriesForTrip(
      tripLocalId: tripId,
      rows: normalizedTimelineRows,
    );
    await _routeDao.replaceAllSegmentsForTrip(
      tripLocalId: tripId,
      rows: routeRows,
    );
  }

  V2TimelineProjectionEntry _mapTimelineRow(TimelineProjectionLocalRow row) {
    return V2TimelineProjectionEntry(
      entryId: row.entryId,
      tripLocalId: row.tripLocalId,
      sessionId: row.sessionId,
      capturedAt: row.capturedAt.toUtc(),
      sourceKind: row.sourceKind,
      sourceId: row.sourceId,
      eventType: row.eventType,
      bucketType: row.bucketType,
      placeBindKind: row.placeBindKind,
      placeBindId: row.placeBindId,
      placeBindName: row.placeBindName,
      decisionSource: row.decisionSource,
      manualLock: row.manualLock,
      anchorLatitude: row.anchorLatitude,
      anchorLongitude: row.anchorLongitude,
      title: row.title,
      subtitle: row.subtitle,
      syncChipState: row.syncChipState,
      displayOrder: row.displayOrder ??
          row.capturedAt.toUtc().millisecondsSinceEpoch.toDouble(),
      routeSegmentKey: row.routeSegmentKey,
      routeDistanceM: row.routeDistanceM,
      renderPayloadJson: row.renderPayloadJson,
      compiledAt: row.compiledAt.toUtc(),
      compilerVersion: row.compilerVersion,
    );
  }

  V2RouteProjectionSegment _mapRouteRow(RouteProjectionLocalRow row) {
    return V2RouteProjectionSegment(
      segmentKey: row.segmentKey,
      tripLocalId: row.tripLocalId,
      sessionId: row.sessionId,
      startedAt: row.startedAt.toUtc(),
      endedAt: row.endedAt.toUtc(),
      pointsCount: row.pointsCount,
      distanceM: row.distanceM,
      bboxMinLat: row.bboxMinLat,
      bboxMinLon: row.bboxMinLon,
      bboxMaxLat: row.bboxMaxLat,
      bboxMaxLon: row.bboxMaxLon,
      geometry: _decodeGeometry(row.geometryJson),
      updatedAt: row.updatedAt.toUtc(),
      compilerVersion: row.compilerVersion,
    );
  }

  List<AppLatLng> _decodeGeometry(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) {
        return const <AppLatLng>[];
      }
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map((item) {
            final lat = _asDouble(item['lat']);
            final lon = _asDouble(item['lon']);
            if (lat == null || lon == null) {
              return null;
            }
            return AppLatLng(latitude: lat, longitude: lon);
          })
          .whereType<AppLatLng>()
          .toList(growable: false);
    } catch (_) {
      return const <AppLatLng>[];
    }
  }

  double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
