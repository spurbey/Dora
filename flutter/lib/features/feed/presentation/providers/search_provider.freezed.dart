// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchState {
  String? get query => throw _privateConstructorUsedError;
  List<PlaceSearchResult> get places => throw _privateConstructorUsedError;
  List<PublicTrip> get trips => throw _privateConstructorUsedError;
  List<String> get recentSearches => throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call(
      {String? query,
      List<PlaceSearchResult> places,
      List<PublicTrip> trips,
      List<String> recentSearches});
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? places = null,
    Object? trips = null,
    Object? recentSearches = null,
  }) {
    return _then(_value.copyWith(
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      places: null == places
          ? _value.places
          : places // ignore: cast_nullable_to_non_nullable
              as List<PlaceSearchResult>,
      trips: null == trips
          ? _value.trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<PublicTrip>,
      recentSearches: null == recentSearches
          ? _value.recentSearches
          : recentSearches // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? query,
      List<PlaceSearchResult> places,
      List<PublicTrip> trips,
      List<String> recentSearches});
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
      _$SearchStateImpl _value, $Res Function(_$SearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = freezed,
    Object? places = null,
    Object? trips = null,
    Object? recentSearches = null,
  }) {
    return _then(_$SearchStateImpl(
      query: freezed == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String?,
      places: null == places
          ? _value._places
          : places // ignore: cast_nullable_to_non_nullable
              as List<PlaceSearchResult>,
      trips: null == trips
          ? _value._trips
          : trips // ignore: cast_nullable_to_non_nullable
              as List<PublicTrip>,
      recentSearches: null == recentSearches
          ? _value._recentSearches
          : recentSearches // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl(
      {this.query,
      final List<PlaceSearchResult> places = const [],
      final List<PublicTrip> trips = const [],
      final List<String> recentSearches = const []})
      : _places = places,
        _trips = trips,
        _recentSearches = recentSearches;

  @override
  final String? query;
  final List<PlaceSearchResult> _places;
  @override
  @JsonKey()
  List<PlaceSearchResult> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  final List<PublicTrip> _trips;
  @override
  @JsonKey()
  List<PublicTrip> get trips {
    if (_trips is EqualUnmodifiableListView) return _trips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trips);
  }

  final List<String> _recentSearches;
  @override
  @JsonKey()
  List<String> get recentSearches {
    if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentSearches);
  }

  @override
  String toString() {
    return 'SearchState(query: $query, places: $places, trips: $trips, recentSearches: $recentSearches)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            const DeepCollectionEquality().equals(other._trips, _trips) &&
            const DeepCollectionEquality()
                .equals(other._recentSearches, _recentSearches));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      const DeepCollectionEquality().hash(_places),
      const DeepCollectionEquality().hash(_trips),
      const DeepCollectionEquality().hash(_recentSearches));

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState(
      {final String? query,
      final List<PlaceSearchResult> places,
      final List<PublicTrip> trips,
      final List<String> recentSearches}) = _$SearchStateImpl;

  @override
  String? get query;
  @override
  List<PlaceSearchResult> get places;
  @override
  List<PublicTrip> get trips;
  @override
  List<String> get recentSearches;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
