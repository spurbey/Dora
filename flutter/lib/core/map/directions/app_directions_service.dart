import 'package:dora/core/map/models/app_latlng.dart';

abstract class AppDirectionsService {
  Future<DirectionsResult> getRoute(List<AppLatLng> waypoints, String mode);
}

class DirectionsResult {
  const DirectionsResult({
    required this.coordinates,
    required this.distanceKm,
    required this.durationMins,
  });

  final List<AppLatLng> coordinates;
  final double distanceKm;
  final int durationMins;
}

class DirectionsException implements Exception {
  const DirectionsException(this.message);

  final String message;

  @override
  String toString() => 'DirectionsException: $message';
}
