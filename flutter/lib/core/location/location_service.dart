import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'package:dora/core/location/location_permission.dart';

class LocationResult {
  const LocationResult({
    required this.accessState,
    this.position,
  });

  final LocationAccessState accessState;
  final Position? position;

  bool get isServiceDisabled =>
      accessState == LocationAccessState.serviceDisabled;

  bool get isPermissionDenied =>
      accessState == LocationAccessState.denied;

  bool get isPermissionDeniedForever =>
      accessState == LocationAccessState.deniedForever;
}

class LocationService {
  LocationService({LocationPermissionService? permissionService})
      : _permissionService = permissionService ?? const LocationPermissionService();

  final LocationPermissionService _permissionService;

  Future<LocationResult> getCurrentPositionResult({
    Duration timeLimit = const Duration(seconds: 10),
    bool requestPermission = true,
  }) async {
    final accessState = await _permissionService.ensurePermissionStatus(
      requestIfDenied: requestPermission,
    );
    if (accessState != LocationAccessState.granted) {
      return LocationResult(accessState: accessState);
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeLimit,
      );
    } on TimeoutException {
      position = await _getLastKnownPositionSafely();
    } catch (_) {
      position = await _getLastKnownPositionSafely();
    }

    return LocationResult(
      accessState: LocationAccessState.granted,
      position: position,
    );
  }

  Future<Position?> getCurrentPosition({
    Duration timeLimit = const Duration(seconds: 10),
    bool requestPermission = true,
  }) async {
    final result = await getCurrentPositionResult(
      timeLimit: timeLimit,
      requestPermission: requestPermission,
    );
    return result.position;
  }

  Future<Position?> _getLastKnownPositionSafely() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (_) {
      return null;
    }
  }
}
