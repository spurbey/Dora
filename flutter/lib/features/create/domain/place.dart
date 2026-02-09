import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'place.freezed.dart';
part 'place.g.dart';

@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String tripId,
    required String name,
    String? address,
    required AppLatLng coordinates,
    String? notes,
    String? visitTime,
    int? dayNumber,
    required int orderIndex,
    @Default([]) List<String> photoUrls,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
