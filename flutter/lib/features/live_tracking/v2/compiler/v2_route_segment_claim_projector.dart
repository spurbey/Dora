import 'dart:math' as math;

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_local_projection_repository.dart';
import 'package:dora/features/live_tracking/v2/compiler/v2_route_segment_claim_repository.dart';

class V2RouteSegmentClaimProjector {
  V2RouteSegmentClaimProjector({
    required AppDatabase database,
    required V2LocalProjectionRepository projectionRepository,
    required V2RouteSegmentClaimRepository claimRepository,
    DateTime Function()? now,
  })  : _database = database,
        _projectionRepository = projectionRepository,
        _claimRepository = claimRepository,
        _now = now ?? DateTime.now;

  static const double claimDistanceThresholdM = 120.0;
  static const String heuristicClaimSource = 'heuristic_local';

  final AppDatabase _database;
  final V2LocalProjectionRepository _projectionRepository;
  final V2RouteSegmentClaimRepository _claimRepository;
  final DateTime Function() _now;
  final Map<String, Future<void>> _inFlightByTrip = <String, Future<void>>{};

  Future<void> projectTripClaims(String tripId) {
    final existing = _inFlightByTrip[tripId];
    if (existing != null) {
      return existing;
    }
    final future = _projectTripClaimsInternal(tripId).whenComplete(() {
      _inFlightByTrip.remove(tripId);
    });
    _inFlightByTrip[tripId] = future;
    return future;
  }

  Future<void> _projectTripClaimsInternal(String tripId) async {
    final manualRoutes = await _database.routeDao.getRoutesForTrip(tripId);
    final segments = await _projectionRepository.listRouteSegments(tripId);
    final now = _now().toUtc();
    if (manualRoutes.isEmpty || segments.isEmpty) {
      await _claimRepository.replaceClaimsForTrip(
        tripId: tripId,
        claims: const <RouteSegmentClaimLocalCompanion>[],
      );
      return;
    }

    final claims = <RouteSegmentClaimLocalCompanion>[];
    for (final route in manualRoutes) {
      if (route.coordinates.length < 2) {
        continue;
      }
      for (final segment in segments) {
        if (segment.geometry.length < 2) {
          continue;
        }
        final distanceM = _minDistanceMeters(
          route.coordinates,
          segment.geometry,
        );
        if (!distanceM.isFinite || distanceM > claimDistanceThresholdM) {
          continue;
        }
        final confidence =
            (1.0 - (distanceM / claimDistanceThresholdM)).clamp(0.0, 1.0);
        claims.add(
          RouteSegmentClaimLocalCompanion.insert(
            tripLocalId: tripId,
            manualRouteId: route.id,
            routeSegmentKey: segment.segmentKey,
            claimSource: heuristicClaimSource,
            confidence: confidence,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    await _claimRepository.replaceClaimsForTrip(
      tripId: tripId,
      claims: claims,
    );
  }

  double _minDistanceMeters(
    List<AppLatLng> manualRouteGeometry,
    List<AppLatLng> segmentGeometry,
  ) {
    var minDistance = double.infinity;
    for (final segmentPoint in segmentGeometry) {
      for (final manualPoint in manualRouteGeometry) {
        final distance = _haversineMeters(
          segmentPoint.latitude,
          segmentPoint.longitude,
          manualPoint.latitude,
          manualPoint.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
        }
      }
    }
    return minDistance;
  }

  double _haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radiusM = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final rLat1 = _degToRad(lat1);
    final rLat2 = _degToRad(lat2);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rLat1) * math.cos(rLat2) * math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return radiusM * c;
  }

  double _degToRad(double value) => value * math.pi / 180.0;
}
