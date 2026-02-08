import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:dora/features/trips/data/models/user_trip.dart';

part 'trips_state.freezed.dart';

enum TripsFilter { all, active, completed, shared }

enum TripsViewMode { grid, list }

@freezed
class TripsState with _$TripsState {
  const factory TripsState({
    @Default([]) List<UserTrip> trips,
    @Default([]) List<UserTrip> allTrips,
    @Default(TripsFilter.all) TripsFilter currentFilter,
    @Default(TripsViewMode.grid) TripsViewMode viewMode,
    @Default('') String searchQuery,
    @Default(false) bool syncFailed,
  }) = _TripsState;
}

extension TripsFilterX on TripsFilter {
  String get label {
    switch (this) {
      case TripsFilter.all:
        return 'All';
      case TripsFilter.active:
        return 'Active';
      case TripsFilter.completed:
        return 'Completed';
      case TripsFilter.shared:
        return 'Shared';
    }
  }
}
