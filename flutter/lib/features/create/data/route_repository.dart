import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:dora/core/map/models/app_latlng.dart';
import 'package:dora/core/storage/drift_database.dart';
import 'package:dora/features/create/domain/route.dart';

class RouteRepository {
  RouteRepository(this._db);

  final AppDatabase _db;

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
  }) {
    final distance = _haversineKm(start, end);
    final duration = _estimateDuration(distance, transportMode);
    final now = DateTime.now();

    return Route(
      id: const Uuid().v4(),
      tripId: tripId,
      coordinates: [start, end],
      transportMode: transportMode,
      distance: distance,
      duration: duration,
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
      'walk' => 5,
      'bike' => 15,
      'air' => 700,
      _ => 60,
    };
    return max(1, (distanceKm / speedKmh * 60).round());
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
}
