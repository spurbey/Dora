import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_latlng.freezed.dart';
part 'app_latlng.g.dart';

@freezed
class AppLatLng with _$AppLatLng {
  const factory AppLatLng({
    required double latitude,
    required double longitude,
  }) = _AppLatLng;

  factory AppLatLng.fromJson(Map<String, dynamic> json) =>
      _$AppLatLngFromJson(json);
}
