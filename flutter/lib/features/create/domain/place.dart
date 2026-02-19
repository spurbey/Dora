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

    // Place classification
    String? placeType, // 'city', 'restaurant', 'hotel', 'attraction', 'museum', 'park', 'shopping', 'nightlife', 'cafe'
    int? rating, // 0-5

    // Sync metadata
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
