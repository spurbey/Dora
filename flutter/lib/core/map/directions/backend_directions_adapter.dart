import 'dart:math' as math;

import 'package:dio/dio.dart';

import 'package:dora/core/map/directions/app_directions_service.dart';
import 'package:dora/core/map/models/app_latlng.dart';

class BackendDirectionsAdapter implements AppDirectionsService {
  BackendDirectionsAdapter(this._dio);

  final Dio _dio;

  static const _modeMap = {
    'car': 'driving',
    'foot': 'walking',
    'walk': 'walking',
    'walking': 'walking',
    'bike': 'cycling',
    'cycling': 'cycling',
  };

  @override
  Future<DirectionsResult> getRoute(
    List<AppLatLng> waypoints,
    String mode,
  ) async {
    final backendMode = _modeMap[mode] ?? 'driving';
    final coordinates =
        waypoints.map((p) => [p.longitude, p.latitude]).toList();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/routes/generate',
        data: {
          'coordinates': coordinates,
          'mode': backendMode,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const DirectionsException('Empty response from server');
      }

      final geojson = data['route_geojson'] as Map<String, dynamic>?;
      final rawCoords = geojson?['coordinates'] as List<dynamic>?;
      if (rawCoords == null || rawCoords.isEmpty) {
        throw const DirectionsException('No coordinates in route response');
      }

      final parsedCoords = rawCoords.map((c) {
        final pair = c as List<dynamic>;
        return AppLatLng(
          latitude: (pair[1] as num).toDouble(),
          longitude: (pair[0] as num).toDouble(),
        );
      }).toList();

      final distanceKm = (data['distance_km'] as num?)?.toDouble() ??
          _fallbackDistanceKm(waypoints);
      final durationMins = (data['duration_mins'] as num?)?.toInt() ??
          _fallbackDurationMins(distanceKm, mode);

      return DirectionsResult(
        coordinates: parsedCoords,
        distanceKm: distanceKm,
        durationMins: durationMins,
      );
    } on DioException catch (e) {
      throw DirectionsException('HTTP ${e.response?.statusCode}: ${e.message}');
    } catch (e) {
      if (e is DirectionsException) rethrow;
      throw DirectionsException(e.toString());
    }
  }

  static double _fallbackDistanceKm(List<AppLatLng> waypoints) {
    if (waypoints.length < 2) return 0;
    const earthRadius = 6371.0;
    final start = waypoints.first;
    final end = waypoints.last;
    final dLat = _deg2rad(end.latitude - start.latitude);
    final dLon = _deg2rad(end.longitude - start.longitude);
    final sinDLat = math.sin(dLat / 2);
    final sinDLon = math.sin(dLon / 2);
    final a = sinDLat * sinDLat +
        math.cos(_deg2rad(start.latitude)) *
            math.cos(_deg2rad(end.latitude)) *
            sinDLon *
            sinDLon;
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static int _fallbackDurationMins(double distanceKm, String mode) {
    final speedKmh = switch (mode) {
      'foot' || 'walk' || 'walking' => 5,
      'bike' || 'cycling' => 15,
      _ => 60,
    };
    return (distanceKm / speedKmh * 60).round().clamp(1, 999999);
  }

  static double _deg2rad(double deg) => deg * math.pi / 180.0;
}
