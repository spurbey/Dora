import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;

/// Mobile Mapbox binding — only compiled on dart:io platforms.
/// main.dart imports this conditionally via `if (dart.library.io)`.
void configureMapbox(String token) {
  if (token.isNotEmpty) {
    mb.MapboxOptions.setAccessToken(token);
  }
}
