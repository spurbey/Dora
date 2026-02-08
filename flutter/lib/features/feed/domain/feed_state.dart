import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_filter.dart';
import 'package:dora/features/trips/data/models/user_trip.dart';

part 'feed_state.freezed.dart';

@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    @Default([]) List<PublicTrip> trips,
    @Default(1) int currentPage,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
    UserTrip? activeTrip,
    TripFilter? filter,
  }) = _FeedState;
}
