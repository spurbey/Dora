import 'package:flutter/foundation.dart';

Future<bool> isNetworkAvailable({
  Duration timeout = const Duration(seconds: 2),
}) async {
  // Web has no dart:io InternetAddress lookup — assume online and let
  // Dio/HTTP surface real failures (browser offline API is unreliable here).
  if (kIsWeb) return true;
  return true;
}
