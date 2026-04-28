import 'package:geolocator/geolocator.dart';

import 'package:dora/core/location/location_settings_resolver.dart';

enum LocationAccessState {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationPermissionService {
  const LocationPermissionService({
    LocationSettingsResolver locationSettingsResolver =
        const LocationSettingsResolver(),
  }) : _locationSettingsResolver = locationSettingsResolver;

  final LocationSettingsResolver _locationSettingsResolver;

  Future<LocationAccessState> ensurePermissionStatus({
    bool requestIfDenied = true,
  }) async {
    var permission = await Geolocator.checkPermission();
    if (requestIfDenied && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAccessState.deniedForever;
    }

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return LocationAccessState.denied;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessState.serviceDisabled;
    }

    return LocationAccessState.granted;
  }

  Future<bool> ensurePermission({bool requestIfDenied = true}) async {
    final status = await ensurePermissionStatus(
      requestIfDenied: requestIfDenied,
    );
    return status == LocationAccessState.granted;
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() async {
    final resolved = await _locationSettingsResolver.promptEnableLocation();
    if (resolved) {
      return true;
    }
    return Geolocator.openLocationSettings();
  }
}
