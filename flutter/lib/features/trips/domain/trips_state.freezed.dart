// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trips_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TripsState {
  List<UserTrip> get trips => throw _privateConstructorUsedError;
  List<UserTrip> get allTrips => throw _privateConstructorUsedError;
  TripsFilter get currentFilter => throw _privateConstructorUsedError;
  TripsViewMode get viewMode => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  bool get syncFailed => throw _privateConstructorUsedError;

  /// Create a copy of TripsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripsStateCopyWith<TripsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripsStateCopyWith<$Res> {
  factory $TripsStateCopyWith(
          TripsState value, $Res Function(TripsState) then) =
      _$TripsStateCopyWithImpl<$Res, TripsState>;
  @useResult
  $Res call(
      {List<UserTrip> trips,
      List<UserTrip> allTrips,
      TripsFilter currentFilter,
      TripsViewMode viewMode,
      String searchQuery,
      bool syncFailed});
}

/// @nodoc
class _$TripsStateCopyWithImpl<$Res, $Val extends TripsState>
    implements $TripsStateCopyWith<$Res> {
  _$TripsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trips = null,
    Object? allTrips = null,
    Object? currentFilter = null,
    Object? viewMode = null,
    Object? searchQuery = null,
    Object? syncFailed = null,
  }) {
    return _then(_value.copyWith(
      trips: null == trips
          ? _value.trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<UserTrip>,
      allTrips: null == allTrips
          ? _value.allTrips
          : allTrips // ignore: cast_nullable_to_non_nullable
              as List<UserTrip>,
      currentFilter: null == currentFilter
          ? _value.currentFilter
          : currentFilter // ignore: cast_nullable_to_non_nullable
              as TripsFilter,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as TripsViewMode,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      syncFailed: null == syncFailed
          ? _value.syncFailed
          : syncFailed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripsStateImplCopyWith<$Res>
    implements $TripsStateCopyWith<$Res> {
  factory _$$TripsStateImplCopyWith(
          _$TripsStateImpl value, $Res Function(_$TripsStateImpl) then) =
      __$$TripsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<UserTrip> trips,
      List<UserTrip> allTrips,
      TripsFilter currentFilter,
      TripsViewMode viewMode,
      String searchQuery,
      bool syncFailed});
}

/// @nodoc
class __$$TripsStateImplCopyWithImpl<$Res>
    extends _$TripsStateCopyWithImpl<$Res, _$TripsStateImpl>
    implements _$$TripsStateImplCopyWith<$Res> {
  __$$TripsStateImplCopyWithImpl(
      _$TripsStateImpl _value, $Res Function(_$TripsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trips = null,
    Object? allTrips = null,
    Object? currentFilter = null,
    Object? viewMode = null,
    Object? searchQuery = null,
    Object? syncFailed = null,
  }) {
    return _then(_$TripsStateImpl(
      trips: null == trips
          ? _value._trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<UserTrip>,
      allTrips: null == allTrips
          ? _value._allTrips
          : allTrips // ignore: cast_nullable_to_non_nullable
              as List<UserTrip>,
      currentFilter: null == currentFilter
          ? _value.currentFilter
          : currentFilter // ignore: cast_nullable_to_non_nullable
              as TripsFilter,
      viewMode: null == viewMode
          ? _value.viewMode
          : viewMode // ignore: cast_nullable_to_non_nullable
              as TripsViewMode,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      syncFailed: null == syncFailed
          ? _value.syncFailed
          : syncFailed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TripsStateImpl implements _TripsState {
  const _$TripsStateImpl(
      {final List<UserTrip> trips = const [],
      final List<UserTrip> allTrips = const [],
      this.currentFilter = TripsFilter.all,
      this.viewMode = TripsViewMode.grid,
      this.searchQuery = '',
      this.syncFailed = false})
      : _trips = trips,
        _allTrips = allTrips;

  final List<UserTrip> _trips;
  @override
  @JsonKey()
  List<UserTrip> get trips {
    if (_trips is EqualUnmodifiableListView) return _trips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trips);
  }

  final List<UserTrip> _allTrips;
  @override
  @JsonKey()
  List<UserTrip> get allTrips {
    if (_allTrips is EqualUnmodifiableListView) return _allTrips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allTrips);
  }

  @override
  @JsonKey()
  final TripsFilter currentFilter;
  @override
  @JsonKey()
  final TripsViewMode viewMode;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final bool syncFailed;

  @override
  String toString() {
    return 'TripsState(trips: $trips, allTrips: $allTrips, currentFilter: $currentFilter, viewMode: $viewMode, searchQuery: $searchQuery, syncFailed: $syncFailed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripsStateImpl &&
            const DeepCollectionEquality().equals(other._trips, _trips) &&
            const DeepCollectionEquality().equals(other._allTrips, _allTrips) &&
            (identical(other.currentFilter, currentFilter) ||
                other.currentFilter == currentFilter) &&
            (identical(other.viewMode, viewMode) ||
                other.viewMode == viewMode) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.syncFailed, syncFailed) ||
                other.syncFailed == syncFailed));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_trips),
      const DeepCollectionEquality().hash(_allTrips),
      currentFilter,
      viewMode,
      searchQuery,
      syncFailed);

  /// Create a copy of TripsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripsStateImplCopyWith<_$TripsStateImpl> get copyWith =>
      __$$TripsStateImplCopyWithImpl<_$TripsStateImpl>(this, _$identity);
}

abstract class _TripsState implements TripsState {
  const factory _TripsState(
      {final List<UserTrip> trips,
      final List<UserTrip> allTrips,
      final TripsFilter currentFilter,
      final TripsViewMode viewMode,
      final String searchQuery,
      final bool syncFailed}) = _$TripsStateImpl;

  @override
  List<UserTrip> get trips;
  @override
  List<UserTrip> get allTrips;
  @override
  TripsFilter get currentFilter;
  @override
  TripsViewMode get viewMode;
  @override
  String get searchQuery;
  @override
  bool get syncFailed;

  /// Create a copy of TripsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripsStateImplCopyWith<_$TripsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
