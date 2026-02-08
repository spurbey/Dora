import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_filter.freezed.dart';

@freezed
class TripFilter with _$TripFilter {
  const factory TripFilter({
    String? duration,
    String? budget,
    String? travelStyle,
  }) = _TripFilter;

  factory TripFilter.empty() => const TripFilter();
}
