import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_trip.freezed.dart';
part 'public_trip.g.dart';

@freezed
class PublicTrip with _$PublicTrip {
  const factory PublicTrip({
    required String id,
    required String name,
    String? description,
    String? coverPhotoUrl,
    required String userId,
    required String username,
    required int placeCount,
    int? duration,
    @Default([]) List<String> tags,
    @Default('public') String visibility,
    @Default(0) int viewCount,
    required DateTime createdAt,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('synced') String syncStatus,
  }) = _PublicTrip;

  factory PublicTrip.fromJson(Map<String, dynamic> json) =>
      _$PublicTripFromJson(json);
}
