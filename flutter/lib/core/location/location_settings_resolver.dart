import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocationSettingsResolver {
  const LocationSettingsResolver();

  static const MethodChannel _channel = MethodChannel(
    'com.dora.travel/location_settings',
  );

  Future<bool> promptEnableLocation() async {
    // Browser location prompts are handled by geolocator itself.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>('promptEnableLocation');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
