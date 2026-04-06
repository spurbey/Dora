import 'dart:convert';
import 'dart:math' as math;

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

const double _maxOverlayAccuracyM = 65.0;
const double _minRenderableMoveM = 2.0;
const double _maxRenderableSpeedMps = 55.0;
const double _minSpikeJumpM = 120.0;
const double _walkingSpikeJumpM = 45.0;
const double _maxSpikeDirectDistanceM = 60.0;
const int _maxSpikeWindowSeconds = 120;

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
  final orderedPoints = <_OverlayPoint>[];
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
      if (!_isValidCoordinate(latitude: latitude, longitude: longitude)) {
        continue;
      }
      final accuracyM = _asDouble(rawPoint['accuracy_m']);
      if (accuracyM != null && accuracyM > _maxOverlayAccuracyM) {
        continue;
      }
      orderedPoints.add(
        _OverlayPoint(
          latitude: latitude,
          longitude: longitude,
          recordedAt: _asDateTime(rawPoint['recorded_at']),
          accuracyM: accuracyM,
          speedMps: _asDouble(rawPoint['speed_mps']),
          sequence: sequence,
        ),
      );
      sequence += 1;
    }
  }

  if (orderedPoints.isEmpty) {
    return const <AppLatLng>[];
  }

  orderedPoints.sort(_compareOverlayPoints);
  final filtered = _removeSpeedAndJitterOutliers(orderedPoints);
  final despiked = _removeSpikePoints(filtered);
  return despiked
      .map(
        (point) => AppLatLng(
          latitude: point.latitude,
          longitude: point.longitude,
        ),
      )
      .toList(growable: false);
}

int _compareOverlayPoints(_OverlayPoint left, _OverlayPoint right) {
  final leftTime = left.recordedAt;
  final rightTime = right.recordedAt;
  if (leftTime != null && rightTime != null) {
    final byTime = leftTime.compareTo(rightTime);
    if (byTime != 0) {
      return byTime;
    }
  }
  return left.sequence.compareTo(right.sequence);
}

List<_OverlayPoint> _removeSpeedAndJitterOutliers(List<_OverlayPoint> points) {
  if (points.isEmpty) {
    return const <_OverlayPoint>[];
  }
  final kept = <_OverlayPoint>[points.first];
  for (final point in points.skip(1)) {
    final previous = kept.last;
    final distanceM = _distanceMeters(
      lat1: previous.latitude,
      lon1: previous.longitude,
      lat2: point.latitude,
      lon2: point.longitude,
    );
    if (distanceM <= _minRenderableMoveM) {
      continue;
    }
    if (!_isReasonableTransition(
      previous: previous,
      current: point,
      distanceM: distanceM,
    )) {
      continue;
    }
    kept.add(point);
  }
  return kept;
}

bool _isReasonableTransition({
  required _OverlayPoint previous,
  required _OverlayPoint current,
  required double distanceM,
}) {
  final prevTime = previous.recordedAt;
  final currTime = current.recordedAt;
  if (prevTime == null || currTime == null) {
    return true;
  }

  final deltaSeconds = currTime.difference(prevTime).inSeconds;
  if (deltaSeconds <= 0) {
    return false;
  }

  final inferredSpeed = distanceM / deltaSeconds;
  if (inferredSpeed > _maxRenderableSpeedMps && distanceM >= 80) {
    return false;
  }

  final observedSpeed = current.speedMps ?? previous.speedMps;
  if (observedSpeed != null &&
      observedSpeed > (_maxRenderableSpeedMps * 1.2) &&
      distanceM >= 40) {
    return false;
  }

  return true;
}

List<_OverlayPoint> _removeSpikePoints(List<_OverlayPoint> points) {
  if (points.length <= 2) {
    return points;
  }

  final result = <_OverlayPoint>[points.first];
  for (var i = 1; i < points.length - 1; i += 1) {
    final previous = result.last;
    final current = points[i];
    final next = points[i + 1];
    if (_looksLikeSpike(previous: previous, current: current, next: next)) {
      continue;
    }
    result.add(current);
  }
  result.add(points.last);
  return result;
}

bool _looksLikeSpike({
  required _OverlayPoint previous,
  required _OverlayPoint current,
  required _OverlayPoint next,
}) {
  final toCurrentM = _distanceMeters(
    lat1: previous.latitude,
    lon1: previous.longitude,
    lat2: current.latitude,
    lon2: current.longitude,
  );
  final fromCurrentM = _distanceMeters(
    lat1: current.latitude,
    lon1: current.longitude,
    lat2: next.latitude,
    lon2: next.longitude,
  );
  final speedSamples = <double>[
    if (previous.speedMps != null) previous.speedMps!,
    if (current.speedMps != null) current.speedMps!,
    if (next.speedMps != null) next.speedMps!,
  ];
  final averageSpeedMps = speedSamples.isEmpty
      ? null
      : speedSamples.reduce((a, b) => a + b) / speedSamples.length;
  final minSpikeJumpM = (averageSpeedMps != null && averageSpeedMps < 2.0)
      ? _walkingSpikeJumpM
      : _minSpikeJumpM;
  if (toCurrentM < minSpikeJumpM || fromCurrentM < minSpikeJumpM) {
    return false;
  }

  final directM = _distanceMeters(
    lat1: previous.latitude,
    lon1: previous.longitude,
    lat2: next.latitude,
    lon2: next.longitude,
  );
  if (directM > _maxSpikeDirectDistanceM) {
    return false;
  }

  final previousTime = previous.recordedAt;
  final nextTime = next.recordedAt;
  if (previousTime == null || nextTime == null) {
    return false;
  }

  final windowSeconds = nextTime.difference(previousTime).inSeconds;
  return windowSeconds > 0 && windowSeconds <= _maxSpikeWindowSeconds;
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

bool _isValidCoordinate({
  required double latitude,
  required double longitude,
}) {
  return latitude >= -90.0 &&
      latitude <= 90.0 &&
      longitude >= -180.0 &&
      longitude <= 180.0;
}

double _distanceMeters({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const earthRadiusMeters = 6371000.0;
  final dLat = _radians(lat2 - lat1);
  final dLon = _radians(lon2 - lon1);
  final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
      math.cos(_radians(lat1)) *
          math.cos(_radians(lat2)) *
          (math.sin(dLon / 2) * math.sin(dLon / 2));
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

double _radians(double degrees) => degrees * (math.pi / 180.0);

class _OverlayPoint {
  const _OverlayPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.accuracyM,
    required this.speedMps,
    required this.sequence,
  });

  final double latitude;
  final double longitude;
  final DateTime? recordedAt;
  final double? accuracyM;
  final double? speedMps;
  final int sequence;
}
