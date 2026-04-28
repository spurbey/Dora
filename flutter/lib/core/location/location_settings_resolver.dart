import 'dart:io';

import 'package:flutter/services.dart';

class LocationSettingsResolver {
  const LocationSettingsResolver();

  static const MethodChannel _channel = MethodChannel(
    'com.dora.travel/location_settings',
  );

  Future<bool> promptEnableLocation() async {
    if (!Platform.isAndroid) {
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
