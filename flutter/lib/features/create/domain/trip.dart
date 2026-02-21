import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/core/map/models/app_latlng.dart';

part 'trip.freezed.dart';
part 'trip.g.dart';

@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    String? serverTripId,
    required String userId,
    required String name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    @Default([]) List<String> tags,
    @Default('private') String visibility,
    AppLatLng? centerPoint,
    @Default(12.0) double zoom,
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    @Default('pending') String syncStatus,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
