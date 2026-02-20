import 'dart:math';

import 'package:dora/core/map/models/app_latlng.dart';

/// Pure Dart utility for generating great-circle arcs via spherical
/// linear interpolation (slerp).
class ArcGenerator {
  ArcGenerator._();

  /// Generate [points] intermediate coordinates along the great-circle arc
  /// from [start] to [end].
  static List<AppLatLng> generateArc(
    AppLatLng start,
    AppLatLng end, {
    int points = 50,
  }) {
    final lat1 = _toRad(start.latitude);
    final lon1 = _toRad(start.longitude);
    final lat2 = _toRad(end.latitude);
    final lon2 = _toRad(end.longitude);

    // Central angle between the two points.
    final d = 2 *
        asin(sqrt(
          pow(sin((lat1 - lat2) / 2), 2) +
              cos(lat1) * cos(lat2) * pow(sin((lon1 - lon2) / 2), 2),
        ));

    if (d < 1e-10) {
      return [start, end];
    }

    final result = <AppLatLng>[];
    for (int i = 0; i <= points; i++) {
      final f = i / points;
      final a = sin((1 - f) * d) / sin(d);
      final b = sin(f * d) / sin(d);

      final x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2);
      final y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2);
      final z = a * sin(lat1) + b * sin(lat2);

      final lat = atan2(z, sqrt(x * x + y * y));
      final lon = atan2(y, x);

      result.add(AppLatLng(
        latitude: _toDeg(lat),
        longitude: _toDeg(lon),
      ));
    }
    return result;
  }

  static double _toRad(double deg) => deg * pi / 180.0;
  static double _toDeg(double rad) => rad * 180.0 / pi;
}
