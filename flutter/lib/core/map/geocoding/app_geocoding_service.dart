import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'app_geocoding_service.freezed.dart';
part 'app_geocoding_service.g.dart';

/// Abstract geocoding interface — vendor-agnostic.
/// Only the adapter (e.g. MapboxGeocodingAdapter) imports vendor SDK.
abstract class AppGeocodingService {
  Future<List<GeocodingResult>> searchCities(
    String query, {
    AppLatLng? proximity,
  });

  Future<GeocodingResult?> reverseGeocode(AppLatLng coordinates);
}

@freezed
class GeocodingResult with _$GeocodingResult {
  const factory GeocodingResult({
    required String name,
    String? country,
    required AppLatLng coordinates,
  }) = _GeocodingResult;

  factory GeocodingResult.fromJson(Map<String, dynamic> json) =>
      _$GeocodingResultFromJson(json);
}
