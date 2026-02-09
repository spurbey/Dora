import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'route.freezed.dart';
part 'route.g.dart';

@freezed
class Route with _$Route {
  const factory Route({
    required String id,
    required String tripId,
    required List<AppLatLng> coordinates,
    @Default('car') String transportMode,
    double? distance,
    int? duration,
    int? dayNumber,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Route;

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
}
