import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/geocoding/app_geocoding_service.dart';
import 'package:dora/core/map/geocoding/mapbox_geocoding_adapter.dart';

part 'geocoding_provider.g.dart';

@riverpod
AppGeocodingService geocodingService(GeocodingServiceRef ref) {
  return MapboxGeocodingAdapter();
}
