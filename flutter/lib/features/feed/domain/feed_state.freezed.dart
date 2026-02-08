// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FeedState {
  List<PublicTrip> get trips => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  TripFilter? get filter => throw _privateConstructorUsedError;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedStateCopyWith<FeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedStateCopyWith<$Res> {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) then) =
      _$FeedStateCopyWithImpl<$Res, FeedState>;
  @useResult
  $Res call(
      {List<PublicTrip> trips,
      int currentPage,
      bool hasMore,
      bool isLoadingMore,
      TripFilter? filter});

  $TripFilterCopyWith<$Res>? get filter;
}

/// @nodoc
class _$FeedStateCopyWithImpl<$Res, $Val extends FeedState>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trips = null,
    Object? currentPage = null,
    Object? hasMore = null,
    Object? isLoadingMore = null,
    Object? filter = freezed,
  }) {
    return _then(_value.copyWith(
      trips: null == trips
          ? _value.trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<PublicTrip>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as TripFilter?,
    ) as $Val);
  }

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripFilterCopyWith<$Res>? get filter {
    if (_value.filter == null) {
      return null;
    }

    return $TripFilterCopyWith<$Res>(_value.filter!, (value) {
      return _then(_value.copyWith(filter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedStateImplCopyWith<$Res>
    implements $FeedStateCopyWith<$Res> {
  factory _$$FeedStateImplCopyWith(
          _$FeedStateImpl value, $Res Function(_$FeedStateImpl) then) =
      __$$FeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PublicTrip> trips,
      int currentPage,
      bool hasMore,
      bool isLoadingMore,
      TripFilter? filter});

  @override
  $TripFilterCopyWith<$Res>? get filter;
}

/// @nodoc
class __$$FeedStateImplCopyWithImpl<$Res>
    extends _$FeedStateCopyWithImpl<$Res, _$FeedStateImpl>
    implements _$$FeedStateImplCopyWith<$Res> {
  __$$FeedStateImplCopyWithImpl(
      _$FeedStateImpl _value, $Res Function(_$FeedStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trips = null,
    Object? currentPage = null,
    Object? hasMore = null,
    Object? isLoadingMore = null,
    Object? filter = freezed,
  }) {
    return _then(_$FeedStateImpl(
      trips: null == trips
          ? _value._trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<PublicTrip>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as TripFilter?,
    ));
  }
}

/// @nodoc

class _$FeedStateImpl implements _FeedState {
  const _$FeedStateImpl(
      {final List<PublicTrip> trips = const [],
      this.currentPage = 1,
      this.hasMore = false,
      this.isLoadingMore = false,
      this.filter})
      : _trips = trips;

  final List<PublicTrip> _trips;
  @override
  @JsonKey()
  List<PublicTrip> get trips {
    if (_trips is EqualUnmodifiableListView) return _trips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trips);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  final TripFilter? filter;

  @override
  String toString() {
    return 'FeedState(trips: $trips, currentPage: $currentPage, hasMore: $hasMore, isLoadingMore: $isLoadingMore, filter: $filter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedStateImpl &&
            const DeepCollectionEquality().equals(other._trips, _trips) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_trips),
      currentPage,
      hasMore,
      isLoadingMore,
      filter);

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      __$$FeedStateImplCopyWithImpl<_$FeedStateImpl>(this, _$identity);
}

abstract class _FeedState implements FeedState {
  const factory _FeedState(
      {final List<PublicTrip> trips,
      final int currentPage,
      final bool hasMore,
      final bool isLoadingMore,
      final TripFilter? filter}) = _$FeedStateImpl;

  @override
  List<PublicTrip> get trips;
  @override
  int get currentPage;
  @override
  bool get hasMore;
  @override
  bool get isLoadingMore;
  @override
  TripFilter? get filter;

  /// Create a copy of FeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedStateImplCopyWith<_$FeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
