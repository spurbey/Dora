import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_stats.freezed.dart';
part 'trip_stats.g.dart';

@freezed
class TripStats with _$TripStats {
  const factory TripStats({
    @Default(0) int totalTrips,
    @Default(0) int totalPlaces,
    @Default(0) int totalVideos,
    @Default(0) int totalViews,
  }) = _TripStats;

  factory TripStats.fromJson(Map<String, dynamic> json) =>
      _$TripStatsFromJson(json);
}
