import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';

class LiveTrackingMapOverlay {
  const LiveTrackingMapOverlay({
    this.pathRoute,
    this.currentMarker,
  });

  final AppRoute? pathRoute;
  final AppMarker? currentMarker;
}

LiveTrackingMapOverlay buildLiveTrackingMapOverlay({
  required LiveTrackingRuntimeSnapshot? snapshot,
  required List<TrackingPointBatchRow> sessionBatches,
}) {
  if (snapshot == null ||
      snapshot.state == LiveTrackingRuntimeState.planned ||
      snapshot.sessionId == null ||
      snapshot.sessionId!.isEmpty) {
    return const LiveTrackingMapOverlay();
  }

  final pathPoints = _extractPathPoints(sessionBatches);
  if (pathPoints.isEmpty) {
    return const LiveTrackingMapOverlay();
  }

  final sessionId = snapshot.sessionId!;
  final pathRoute = pathPoints.length >= 2
      ? AppRoute(
          id: '_live_tracking_path_$sessionId',
          coordinates: pathPoints,
          color: const Color(0xFF0EA5E9),
          width: 5.0,
          dashed: false,
        )
      : null;
  final currentMarker = AppMarker(
    id: '_live_tracking_current_$sessionId',
    position: pathPoints.last,
    title: 'Live position',
    color: const Color(0xFF0EA5E9),
    markerType: 'tracking_current',
    label: 'Live',
  );

  return LiveTrackingMapOverlay(
    pathRoute: pathRoute,
    currentMarker: currentMarker,
  );
}

List<AppLatLng> _extractPathPoints(List<TrackingPointBatchRow> batches) {
  final points = <AppLatLng>[];
  for (final batch in batches) {
    final payload = _decodePoints(batch.pointsJson);
    for (final rawPoint in payload) {
      final latitude = _asDouble(rawPoint['latitude']);
      final longitude = _asDouble(rawPoint['longitude']);
      if (latitude == null || longitude == null) {
        continue;
      }
      final point = AppLatLng(latitude: latitude, longitude: longitude);
      if (points.isEmpty || points.last != point) {
        points.add(point);
      }
    }
  }
  return points;
}

List<Map<String, dynamic>> _decodePoints(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <Map<String, dynamic>>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  } catch (_) {
    return const <Map<String, dynamic>>[];
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
