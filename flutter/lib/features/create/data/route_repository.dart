import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/directions/app_directions_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/data/arc_generator.dart';
import 'package:dora/features/create/domain/route.dart';

class RouteRepository {
  RouteRepository(this._db, {AppDirectionsService? directionsService})
      : _directionsService = directionsService;

  final AppDatabase _db;
  final AppDirectionsService? _directionsService;

  Future<List<Route>> getRoutes(String tripId) async {
    final rows = await _db.routeDao.getRoutesForTrip(tripId);
    return rows.map(_mapRow).toList();
  }

  Future<Route?> getRoute(String id) async {
    final row = await _db.routeDao.getRouteById(id);
    return row == null ? null : _mapRow(row);
  }

  Future<Route> addRoute(Route route) async {
    final now = DateTime.now();
    final updated = route.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.routeDao.insertRoute(_toCompanion(updated));
    return updated;
  }

  Future<void> updateRoute(Route route) async {
    final now = DateTime.now();
    final updated = route.copyWith(
      localUpdatedAt: now,
      syncStatus: 'pending',
    );
    await _db.routeDao.updateRoute(_toCompanion(updated));
  }

  Future<void> deleteRoute(String id) async {
    await _db.routeDao.deleteRoute(id);
  }

  Future<void> saveRoutes(List<Route> routes) async {
    if (routes.isEmpty) {
      return;
    }
    final now = DateTime.now();
    final companions = routes
        .map((route) => _toCompanion(
              route.copyWith(
                localUpdatedAt: now,
                syncStatus: 'pending',
              ),
            ))
        .toList();
    await _db.routeDao.insertRoutes(companions);
  }

  Route generateRoute({
    required String tripId,
    required AppLatLng start,
    required AppLatLng end,
    String transportMode = 'car',
    String? startPlaceId,
    String? endPlaceId,
    int orderIndex = 0,
  }) {
    final distance = _haversineKm(start, end);
    final duration = _estimateDuration(distance, transportMode);
    final routeCategory = transportMode == 'air' ? 'air' : 'ground';
    final now = DateTime.now();

    return Route(
      id: const Uuid().v4(),
      tripId: tripId,
      coordinates: [start, end],
      transportMode: transportMode,
      distance: distance,
      duration: duration,
      routeCategory: routeCategory,
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      orderIndex: orderIndex,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  /// Generate air route with great-circle arc interpolation (slerp).
  Route generateAirRoute({
    required String tripId,
    required AppLatLng start,
    required AppLatLng end,
    String? startPlaceId,
    String? endPlaceId,
    int orderIndex = 0,
  }) {
    final arcCoordinates = ArcGenerator.generateArc(start, end, points: 50);
    final distance = _haversineKm(start, end);
    final duration = _estimateDuration(distance, 'air');
    final now = DateTime.now();

    return Route(
      id: const Uuid().v4(),
      tripId: tripId,
      coordinates: arcCoordinates,
      transportMode: 'air',
      distance: distance,
      duration: duration,
      routeCategory: 'air',
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      orderIndex: orderIndex,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  /// Generate a route via the backend Directions API (real road geometry).
  /// Falls back to haversine straight-line if the API call fails.
  Future<Route> generateRouteViaApi({
    required String tripId,
    required AppLatLng start,
    required AppLatLng end,
    required String mode,
    String? startPlaceId,
    String? endPlaceId,
    int orderIndex = 0,
  }) async {
    if (_directionsService == null) {
      throw StateError('Directions service is not configured');
    }

    final result = await _directionsService!.getRoute([start, end], mode);
    final now = DateTime.now();
    return Route(
      id: const Uuid().v4(),
      tripId: tripId,
      transportMode: mode,
      coordinates: result.coordinates,
      distance: result.distanceKm,
      duration: result.durationMins,
      routeCategory: 'ground',
      startPlaceId: startPlaceId,
      endPlaceId: endPlaceId,
      orderIndex: orderIndex,
      routeGeojson: result.routeGeojson,
      localUpdatedAt: now,
      serverUpdatedAt: now,
      syncStatus: 'pending',
    );
  }

  Route _mapRow(RouteRow row) {
    return Route(
      id: row.id,
      tripId: row.tripId,
      coordinates: row.coordinates,
      transportMode: row.transportMode,
      distance: row.distance,
      duration: row.duration,
      dayNumber: row.dayNumber,
      name: row.name,
      description: row.description,
      routeCategory: row.routeCategory,
      startPlaceId: row.startPlaceId,
      endPlaceId: row.endPlaceId,
      orderIndex: row.orderIndex,
      routeGeojson: row.routeGeojson,
      waypoints: row.waypointsJson,
      localUpdatedAt: row.localUpdatedAt,
      serverUpdatedAt: row.serverUpdatedAt,
      syncStatus: row.syncStatus,
    );
  }

  RoutesCompanion _toCompanion(Route route) {
    return RoutesCompanion(
      id: Value(route.id),
      tripId: Value(route.tripId),
      coordinates: Value(route.coordinates),
      transportMode: Value(route.transportMode),
      distance: Value(route.distance),
      duration: Value(route.duration),
      dayNumber: Value(route.dayNumber),
      name: Value(route.name),
      description: Value(route.description),
      routeCategory: Value(route.routeCategory),
      startPlaceId: Value(route.startPlaceId),
      endPlaceId: Value(route.endPlaceId),
      orderIndex: Value(route.orderIndex),
      routeGeojson: Value(route.routeGeojson),
      waypointsJson: Value(route.waypoints),
      localUpdatedAt: Value(route.localUpdatedAt),
      serverUpdatedAt: Value(route.serverUpdatedAt),
      syncStatus: Value(route.syncStatus),
    );
  }

  static double _haversineKm(AppLatLng start, AppLatLng end) {
    const earthRadius = 6371.0;
    final dLat = _degToRad(end.latitude - start.latitude);
    final dLon = _degToRad(end.longitude - start.longitude);
    final lat1 = _degToRad(start.latitude);
    final lat2 = _degToRad(end.latitude);

    final a = pow(sin(dLat / 2), 2) +
        cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static int _estimateDuration(double distanceKm, String mode) {
    final speedKmh = switch (mode) {
      // Keep backward compatibility for legacy 'walk' while using 'foot' as canonical.
      'foot' || 'walk' || 'walking' => 5,
      'bike' || 'cycling' => 15,
      'air' => 700,
      _ => 60,
    };
    return max(1, (distanceKm / speedKmh * 60).round());
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
}
