import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'app_bounds.freezed.dart';
part 'app_bounds.g.dart';

@freezed
class AppLatLngBounds with _$AppLatLngBounds {
  const factory AppLatLngBounds({
    required AppLatLng southwest,
    required AppLatLng northeast,
  }) = _AppLatLngBounds;

  factory AppLatLngBounds.fromJson(Map<String, dynamic> json) =>
      _$AppLatLngBoundsFromJson(json);
}
