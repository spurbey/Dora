import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/location/location_permission.dart';
import 'package:dora/core/location/location_service.dart';

final locationPermissionProvider = Provider<LocationPermissionService>((ref) {
  return const LocationPermissionService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final permissionService = ref.watch(locationPermissionProvider);
  return LocationService(permissionService: permissionService);
});
