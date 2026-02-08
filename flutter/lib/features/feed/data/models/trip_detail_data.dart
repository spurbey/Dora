import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/features/feed/data/models/public_trip.dart';

part 'trip_detail_data.freezed.dart';
part 'trip_detail_data.g.dart';

@freezed
class TripDetailData with _$TripDetailData {
  const factory TripDetailData({
    required PublicTrip trip,
    required List<TripPlace> places,
    required List<TripRoute> routes,
  }) = _TripDetailData;
}

@freezed
class TripPlace with _$TripPlace {
  const factory TripPlace({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? notes,
    String? visitTime,
    int? dayNumber,
    int? orderIndex,
    @Default([]) List<String> photoUrls,
  }) = _TripPlace;

  factory TripPlace.fromJson(Map<String, dynamic> json) =>
      _$TripPlaceFromJson(json);
}

@freezed
class TripRoute with _$TripRoute {
  const factory TripRoute({
    required String id,
    @Default([]) List<TripLatLng> coordinates,
    String? transportMode,
    double? distance,
    int? duration,
    int? dayNumber,
    String? polyline,
  }) = _TripRoute;

  factory TripRoute.fromJson(Map<String, dynamic> json) =>
      _$TripRouteFromJson(json);
}

@freezed
class TripLatLng with _$TripLatLng {
  const factory TripLatLng({
    required double latitude,
    required double longitude,
  }) = _TripLatLng;

  factory TripLatLng.fromJson(Map<String, dynamic> json) =>
      _$TripLatLngFromJson(json);
}
