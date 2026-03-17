import 'package:geolocator/geolocator.dart';

enum LocationAccessState {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationPermissionService {
  const LocationPermissionService();

  Future<LocationAccessState> ensurePermissionStatus({
    bool requestIfDenied = true,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessState.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (requestIfDenied && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return LocationAccessState.granted;
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAccessState.deniedForever;
    }

    return LocationAccessState.denied;
  }

  Future<bool> ensurePermission({bool requestIfDenied = true}) async {
    final status = await ensurePermissionStatus(
      requestIfDenied: requestIfDenied,
    );
    return status == LocationAccessState.granted;
  }
}
