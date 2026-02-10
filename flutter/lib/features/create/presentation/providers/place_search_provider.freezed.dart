// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_search_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlaceSearchState {
  String get query => throw _privateConstructorUsedError;
  List<PlaceSearchResult> get results => throw _privateConstructorUsedError;
  bool get offline => throw _privateConstructorUsedError;
  bool get searching => throw _privateConstructorUsedError;

  /// Create a copy of PlaceSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceSearchStateCopyWith<PlaceSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceSearchStateCopyWith<$Res> {
  factory $PlaceSearchStateCopyWith(
          PlaceSearchState value, $Res Function(PlaceSearchState) then) =
      _$PlaceSearchStateCopyWithImpl<$Res, PlaceSearchState>;
  @useResult
  $Res call(
      {String query,
      List<PlaceSearchResult> results,
      bool offline,
      bool searching});
}

/// @nodoc
class _$PlaceSearchStateCopyWithImpl<$Res, $Val extends PlaceSearchState>
    implements $PlaceSearchStateCopyWith<$Res> {
  _$PlaceSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? results = null,
    Object? offline = null,
    Object? searching = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PlaceSearchResult>,
      offline: null == offline
          ? _value.offline
          : offline // ignore: cast_nullable_to_non_nullable
              as bool,
      searching: null == searching
          ? _value.searching
          : searching // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlaceSearchStateImplCopyWith<$Res>
    implements $PlaceSearchStateCopyWith<$Res> {
  factory _$$PlaceSearchStateImplCopyWith(_$PlaceSearchStateImpl value,
          $Res Function(_$PlaceSearchStateImpl) then) =
      __$$PlaceSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      List<PlaceSearchResult> results,
      bool offline,
      bool searching});
}

/// @nodoc
class __$$PlaceSearchStateImplCopyWithImpl<$Res>
    extends _$PlaceSearchStateCopyWithImpl<$Res, _$PlaceSearchStateImpl>
    implements _$$PlaceSearchStateImplCopyWith<$Res> {
  __$$PlaceSearchStateImplCopyWithImpl(_$PlaceSearchStateImpl _value,
      $Res Function(_$PlaceSearchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlaceSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? results = null,
    Object? offline = null,
    Object? searching = null,
  }) {
    return _then(_$PlaceSearchStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<PlaceSearchResult>,
      offline: null == offline
          ? _value.offline
          : offline // ignore: cast_nullable_to_non_nullable
              as bool,
      searching: null == searching
          ? _value.searching
          : searching // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PlaceSearchStateImpl implements _PlaceSearchState {
  const _$PlaceSearchStateImpl(
      {this.query = '',
      final List<PlaceSearchResult> results = const [],
      this.offline = false,
      this.searching = false})
      : _results = results;

  @override
  @JsonKey()
  final String query;
  final List<PlaceSearchResult> _results;
  @override
  @JsonKey()
  List<PlaceSearchResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  @JsonKey()
  final bool offline;
  @override
  @JsonKey()
  final bool searching;

  @override
  String toString() {
    return 'PlaceSearchState(query: $query, results: $results, offline: $offline, searching: $searching)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceSearchStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.offline, offline) || other.offline == offline) &&
            (identical(other.searching, searching) ||
                other.searching == searching));
  }

  @override
  int get hashCode => Object.hash(runtimeType, query,
      const DeepCollectionEquality().hash(_results), offline, searching);

  /// Create a copy of PlaceSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceSearchStateImplCopyWith<_$PlaceSearchStateImpl> get copyWith =>
      __$$PlaceSearchStateImplCopyWithImpl<_$PlaceSearchStateImpl>(
          this, _$identity);
}

abstract class _PlaceSearchState implements PlaceSearchState {
  const factory _PlaceSearchState(
      {final String query,
      final List<PlaceSearchResult> results,
      final bool offline,
      final bool searching}) = _$PlaceSearchStateImpl;

  @override
  String get query;
  @override
  List<PlaceSearchResult> get results;
  @override
  bool get offline;
  @override
  bool get searching;

  /// Create a copy of PlaceSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceSearchStateImplCopyWith<_$PlaceSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
