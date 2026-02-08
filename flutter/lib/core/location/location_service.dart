import 'package:geolocator/geolocator.dart';

import 'package:dora/core/location/location_permission.dart';

class LocationService {
  LocationService({LocationPermissionService? permissionService})
      : _permissionService = permissionService ?? const LocationPermissionService();

  final LocationPermissionService _permissionService;

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _permissionService.ensurePermission();
    if (!hasPermission) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
