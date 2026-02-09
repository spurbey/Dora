// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimelineState {
  List<Place> get places => throw _privateConstructorUsedError;
  List<Route> get routes => throw _privateConstructorUsedError;
  String? get selectedItemId => throw _privateConstructorUsedError;
  String? get selectedItemType => throw _privateConstructorUsedError;
  bool get isReordering => throw _privateConstructorUsedError;

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineStateCopyWith<TimelineState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineStateCopyWith<$Res> {
  factory $TimelineStateCopyWith(
          TimelineState value, $Res Function(TimelineState) then) =
      _$TimelineStateCopyWithImpl<$Res, TimelineState>;
  @useResult
  $Res call(
      {List<Place> places,
      List<Route> routes,
      String? selectedItemId,
      String? selectedItemType,
      bool isReordering});
}

/// @nodoc
class _$TimelineStateCopyWithImpl<$Res, $Val extends TimelineState>
    implements $TimelineStateCopyWith<$Res> {
  _$TimelineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? routes = null,
    Object? selectedItemId = freezed,
    Object? selectedItemType = freezed,
    Object? isReordering = null,
  }) {
    return _then(_value.copyWith(
      places: null == places
          ? _value.places
          : places // ignore: cast_nullable_to_non_nullable
              as List<Place>,
      routes: null == routes
          ? _value.routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<Route>,
      selectedItemId: freezed == selectedItemId
          ? _value.selectedItemId
          : selectedItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedItemType: freezed == selectedItemType
          ? _value.selectedItemType
          : selectedItemType // ignore: cast_nullable_to_non_nullable
              as String?,
      isReordering: null == isReordering
          ? _value.isReordering
          : isReordering // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimelineStateImplCopyWith<$Res>
    implements $TimelineStateCopyWith<$Res> {
  factory _$$TimelineStateImplCopyWith(
          _$TimelineStateImpl value, $Res Function(_$TimelineStateImpl) then) =
      __$$TimelineStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Place> places,
      List<Route> routes,
      String? selectedItemId,
      String? selectedItemType,
      bool isReordering});
}

/// @nodoc
class __$$TimelineStateImplCopyWithImpl<$Res>
    extends _$TimelineStateCopyWithImpl<$Res, _$TimelineStateImpl>
    implements _$$TimelineStateImplCopyWith<$Res> {
  __$$TimelineStateImplCopyWithImpl(
      _$TimelineStateImpl _value, $Res Function(_$TimelineStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? routes = null,
    Object? selectedItemId = freezed,
    Object? selectedItemType = freezed,
    Object? isReordering = null,
  }) {
    return _then(_$TimelineStateImpl(
      places: null == places
          ? _value._places
          : places // ignore: cast_nullable_to_non_nullable
              as List<Place>,
      routes: null == routes
          ? _value._routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<Route>,
      selectedItemId: freezed == selectedItemId
          ? _value.selectedItemId
          : selectedItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedItemType: freezed == selectedItemType
          ? _value.selectedItemType
          : selectedItemType // ignore: cast_nullable_to_non_nullable
              as String?,
      isReordering: null == isReordering
          ? _value.isReordering
          : isReordering // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TimelineStateImpl implements _TimelineState {
  const _$TimelineStateImpl(
      {final List<Place> places = const [],
      final List<Route> routes = const [],
      this.selectedItemId,
      this.selectedItemType,
      this.isReordering = false})
      : _places = places,
        _routes = routes;

  final List<Place> _places;
  @override
  @JsonKey()
  List<Place> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  final List<Route> _routes;
  @override
  @JsonKey()
  List<Route> get routes {
    if (_routes is EqualUnmodifiableListView) return _routes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routes);
  }

  @override
  final String? selectedItemId;
  @override
  final String? selectedItemType;
  @override
  @JsonKey()
  final bool isReordering;

  @override
  String toString() {
    return 'TimelineState(places: $places, routes: $routes, selectedItemId: $selectedItemId, selectedItemType: $selectedItemType, isReordering: $isReordering)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineStateImpl &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            const DeepCollectionEquality().equals(other._routes, _routes) &&
            (identical(other.selectedItemId, selectedItemId) ||
                other.selectedItemId == selectedItemId) &&
            (identical(other.selectedItemType, selectedItemType) ||
                other.selectedItemType == selectedItemType) &&
            (identical(other.isReordering, isReordering) ||
                other.isReordering == isReordering));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_places),
      const DeepCollectionEquality().hash(_routes),
      selectedItemId,
      selectedItemType,
      isReordering);

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineStateImplCopyWith<_$TimelineStateImpl> get copyWith =>
      __$$TimelineStateImplCopyWithImpl<_$TimelineStateImpl>(this, _$identity);
}

abstract class _TimelineState implements TimelineState {
  const factory _TimelineState(
      {final List<Place> places,
      final List<Route> routes,
      final String? selectedItemId,
      final String? selectedItemType,
      final bool isReordering}) = _$TimelineStateImpl;

  @override
  List<Place> get places;
  @override
  List<Route> get routes;
  @override
  String? get selectedItemId;
  @override
  String? get selectedItemType;
  @override
  bool get isReordering;

  /// Create a copy of TimelineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineStateImplCopyWith<_$TimelineStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
