import 'dart:math' as math;

import 'package:dora/core/map/models/app_latlng.dart';

const double maxOverlayAccuracyM = 65.0;
const double minRenderableMoveM = 2.0;
const double maxRenderableSpeedMps = 55.0;
const double minSpikeJumpM = 120.0;
const double walkingSpikeJumpM = 45.0;
const double maxSpikeDirectDistanceM = 60.0;
const int maxSpikeWindowSeconds = 120;

class LiveTrackingPathSample {
  const LiveTrackingPathSample({
    required this.latitude,
    required this.longitude,
    this.recordedAt,
    this.accuracyM,
    this.speedMps,
    required this.sequence,
  });

  final double latitude;
  final double longitude;
  final DateTime? recordedAt;
  final double? accuracyM;
  final double? speedMps;
  final int sequence;
}

List<AppLatLng> buildStableLiveTrackingPathPoints(
  List<LiveTrackingPathSample> samples,
) {
  if (samples.isEmpty) {
    return const <AppLatLng>[];
  }
  final valid = samples.where((sample) {
    if (!_isValidCoordinate(
      latitude: sample.latitude,
      longitude: sample.longitude,
    )) {
      return false;
    }
    final accuracy = sample.accuracyM;
    if (accuracy != null && accuracy > maxOverlayAccuracyM) {
      return false;
    }
    return true;
  }).toList(growable: false);
  if (valid.isEmpty) {
    return const <AppLatLng>[];
  }

  final ordered = valid.toList(growable: false)
    ..sort((left, right) {
      final leftTime = left.recordedAt;
      final rightTime = right.recordedAt;
      if (leftTime != null && rightTime != null) {
        final byTime = leftTime.compareTo(rightTime);
        if (byTime != 0) {
          return byTime;
        }
      }
      return left.sequence.compareTo(right.sequence);
    });

  final filtered = _removeSpeedAndJitterOutliers(ordered);
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

List<LiveTrackingPathSample> _removeSpeedAndJitterOutliers(
  List<LiveTrackingPathSample> points,
) {
  if (points.isEmpty) {
    return const <LiveTrackingPathSample>[];
  }
  final kept = <LiveTrackingPathSample>[points.first];
  for (final point in points.skip(1)) {
    final previous = kept.last;
    final distanceM = _distanceMeters(
      lat1: previous.latitude,
      lon1: previous.longitude,
      lat2: point.latitude,
      lon2: point.longitude,
    );
    if (distanceM <= minRenderableMoveM) {
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
  required LiveTrackingPathSample previous,
  required LiveTrackingPathSample current,
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
  if (inferredSpeed > maxRenderableSpeedMps && distanceM >= 80) {
    return false;
  }

  final observedSpeed = current.speedMps ?? previous.speedMps;
  if (observedSpeed != null &&
      observedSpeed > (maxRenderableSpeedMps * 1.2) &&
      distanceM >= 40) {
    return false;
  }

  return true;
}

List<LiveTrackingPathSample> _removeSpikePoints(
  List<LiveTrackingPathSample> points,
) {
  if (points.length <= 2) {
    return points;
  }

  final result = <LiveTrackingPathSample>[points.first];
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
  required LiveTrackingPathSample previous,
  required LiveTrackingPathSample current,
  required LiveTrackingPathSample next,
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
  final minSpikeJump = (averageSpeedMps != null && averageSpeedMps < 2.0)
      ? walkingSpikeJumpM
      : minSpikeJumpM;
  if (toCurrentM < minSpikeJump || fromCurrentM < minSpikeJump) {
    return false;
  }

  final directM = _distanceMeters(
    lat1: previous.latitude,
    lon1: previous.longitude,
    lat2: next.latitude,
    lon2: next.longitude,
  );
  if (directM > maxSpikeDirectDistanceM) {
    return false;
  }

  final previousTime = previous.recordedAt;
  final nextTime = next.recordedAt;
  if (previousTime == null || nextTime == null) {
    return false;
  }

  final windowSeconds = nextTime.difference(previousTime).inSeconds;
  return windowSeconds > 0 && windowSeconds <= maxSpikeWindowSeconds;
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
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_radians(lat1)) *
          math.cos(_radians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusMeters * c;
}

double _radians(double value) => value * math.pi / 180.0;
