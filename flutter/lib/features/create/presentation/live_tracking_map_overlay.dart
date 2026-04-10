import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/map/models/app_marker.dart';
import 'package:dora/core/map/models/app_route.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/live_tracking_runtime_repository.dart';
import 'package:dora/features/create/presentation/live_tracking_path_filter.dart';

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
  final samples = <LiveTrackingPathSample>[];
  var sequence = 0;
  for (final batch in batches) {
    if (batch.status == 'dropped_stale_session') {
      continue;
    }
    final payload = _decodePoints(batch.pointsJson);
    for (final rawPoint in payload) {
      final latitude = _asDouble(rawPoint['latitude']);
      final longitude = _asDouble(rawPoint['longitude']);
      if (latitude == null || longitude == null) {
        continue;
      }
      samples.add(
        LiveTrackingPathSample(
          latitude: latitude,
          longitude: longitude,
          recordedAt: _asDateTime(rawPoint['recorded_at']),
          accuracyM: _asDouble(rawPoint['accuracy_m']),
          speedMps: _asDouble(rawPoint['speed_mps']),
          sequence: sequence,
        ),
      );
      sequence += 1;
    }
  }
  return buildStableLiveTrackingPathPoints(samples);
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

DateTime? _asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toUtc();
}
