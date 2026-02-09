// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MapState {
  AppMapController? get controller => throw _privateConstructorUsedError;
  List<AppMarker> get markers => throw _privateConstructorUsedError;
  List<AppRoute> get routes => throw _privateConstructorUsedError;
  AppLatLng? get center => throw _privateConstructorUsedError;
  double? get zoom => throw _privateConstructorUsedError;
  bool get showUserLocation => throw _privateConstructorUsedError;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapStateCopyWith<MapState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapStateCopyWith<$Res> {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) then) =
      _$MapStateCopyWithImpl<$Res, MapState>;
  @useResult
  $Res call(
      {AppMapController? controller,
      List<AppMarker> markers,
      List<AppRoute> routes,
      AppLatLng? center,
      double? zoom,
      bool showUserLocation});

  $AppLatLngCopyWith<$Res>? get center;
}

/// @nodoc
class _$MapStateCopyWithImpl<$Res, $Val extends MapState>
    implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = freezed,
    Object? markers = null,
    Object? routes = null,
    Object? center = freezed,
    Object? zoom = freezed,
    Object? showUserLocation = null,
  }) {
    return _then(_value.copyWith(
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as AppMapController?,
      markers: null == markers
          ? _value.markers
          : markers // ignore: cast_nullable_to_non_nullable
              as List<AppMarker>,
      routes: null == routes
          ? _value.routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<AppRoute>,
      center: freezed == center
          ? _value.center
          : center // ignore: cast_nullable_to_non_nullable
              as AppLatLng?,
      zoom: freezed == zoom
          ? _value.zoom
          : zoom // ignore: cast_nullable_to_non_nullable
              as double?,
      showUserLocation: null == showUserLocation
          ? _value.showUserLocation
          : showUserLocation // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppLatLngCopyWith<$Res>? get center {
    if (_value.center == null) {
      return null;
    }

    return $AppLatLngCopyWith<$Res>(_value.center!, (value) {
      return _then(_value.copyWith(center: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MapStateImplCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory _$$MapStateImplCopyWith(
          _$MapStateImpl value, $Res Function(_$MapStateImpl) then) =
      __$$MapStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AppMapController? controller,
      List<AppMarker> markers,
      List<AppRoute> routes,
      AppLatLng? center,
      double? zoom,
      bool showUserLocation});

  @override
  $AppLatLngCopyWith<$Res>? get center;
}

/// @nodoc
class __$$MapStateImplCopyWithImpl<$Res>
    extends _$MapStateCopyWithImpl<$Res, _$MapStateImpl>
    implements _$$MapStateImplCopyWith<$Res> {
  __$$MapStateImplCopyWithImpl(
      _$MapStateImpl _value, $Res Function(_$MapStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? controller = freezed,
    Object? markers = null,
    Object? routes = null,
    Object? center = freezed,
    Object? zoom = freezed,
    Object? showUserLocation = null,
  }) {
    return _then(_$MapStateImpl(
      controller: freezed == controller
          ? _value.controller
          : controller // ignore: cast_nullable_to_non_nullable
              as AppMapController?,
      markers: null == markers
          ? _value._markers
          : markers // ignore: cast_nullable_to_non_nullable
              as List<AppMarker>,
      routes: null == routes
          ? _value._routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<AppRoute>,
      center: freezed == center
          ? _value.center
          : center // ignore: cast_nullable_to_non_nullable
              as AppLatLng?,
      zoom: freezed == zoom
          ? _value.zoom
          : zoom // ignore: cast_nullable_to_non_nullable
              as double?,
      showUserLocation: null == showUserLocation
          ? _value.showUserLocation
          : showUserLocation // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MapStateImpl implements _MapState {
  const _$MapStateImpl(
      {this.controller,
      final List<AppMarker> markers = const [],
      final List<AppRoute> routes = const [],
      this.center,
      this.zoom,
      this.showUserLocation = false})
      : _markers = markers,
        _routes = routes;

  @override
  final AppMapController? controller;
  final List<AppMarker> _markers;
  @override
  @JsonKey()
  List<AppMarker> get markers {
    if (_markers is EqualUnmodifiableListView) return _markers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_markers);
  }

  final List<AppRoute> _routes;
  @override
  @JsonKey()
  List<AppRoute> get routes {
    if (_routes is EqualUnmodifiableListView) return _routes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routes);
  }

  @override
  final AppLatLng? center;
  @override
  final double? zoom;
  @override
  @JsonKey()
  final bool showUserLocation;

  @override
  String toString() {
    return 'MapState(controller: $controller, markers: $markers, routes: $routes, center: $center, zoom: $zoom, showUserLocation: $showUserLocation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapStateImpl &&
            (identical(other.controller, controller) ||
                other.controller == controller) &&
            const DeepCollectionEquality().equals(other._markers, _markers) &&
            const DeepCollectionEquality().equals(other._routes, _routes) &&
            (identical(other.center, center) || other.center == center) &&
            (identical(other.zoom, zoom) || other.zoom == zoom) &&
            (identical(other.showUserLocation, showUserLocation) ||
                other.showUserLocation == showUserLocation));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      controller,
      const DeepCollectionEquality().hash(_markers),
      const DeepCollectionEquality().hash(_routes),
      center,
      zoom,
      showUserLocation);

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      __$$MapStateImplCopyWithImpl<_$MapStateImpl>(this, _$identity);
}

abstract class _MapState implements MapState {
  const factory _MapState(
      {final AppMapController? controller,
      final List<AppMarker> markers,
      final List<AppRoute> routes,
      final AppLatLng? center,
      final double? zoom,
      final bool showUserLocation}) = _$MapStateImpl;

  @override
  AppMapController? get controller;
  @override
  List<AppMarker> get markers;
  @override
  List<AppRoute> get routes;
  @override
  AppLatLng? get center;
  @override
  double? get zoom;
  @override
  bool get showUserLocation;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
