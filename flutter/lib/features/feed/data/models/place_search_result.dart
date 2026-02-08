import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_search_result.freezed.dart';
part 'place_search_result.g.dart';

@freezed
class PlaceSearchResult with _$PlaceSearchResult {
  const factory PlaceSearchResult({
    required String id,
    required String name,
    required String category,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    String? priceLevel,
    String? photoUrl,
  }) = _PlaceSearchResult;

  factory PlaceSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PlaceSearchResultFromJson(json);
}
