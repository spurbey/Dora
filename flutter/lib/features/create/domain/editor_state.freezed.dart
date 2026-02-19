// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EditorState {
  Trip get trip => throw _privateConstructorUsedError;
  List<Place> get places => throw _privateConstructorUsedError;
  List<Route> get routes => throw _privateConstructorUsedError; // Selection
  String? get selectedItemId => throw _privateConstructorUsedError;
  String? get selectedItemType =>
      throw _privateConstructorUsedError; // 'place', 'city', 'route'
// Editor mode
  EditorMode get mode => throw _privateConstructorUsedError; // UI state
  bool get saving => throw _privateConstructorUsedError;
  bool get bottomPanelExpanded =>
      throw _privateConstructorUsedError; // Map controller reference
  AppMapController? get mapController =>
      throw _privateConstructorUsedError; // Route drawing state
  String? get routeStartItemId => throw _privateConstructorUsedError;
  String? get routeStartItemType => throw _privateConstructorUsedError;

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EditorStateCopyWith<EditorState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EditorStateCopyWith<$Res> {
  factory $EditorStateCopyWith(
          EditorState value, $Res Function(EditorState) then) =
      _$EditorStateCopyWithImpl<$Res, EditorState>;
  @useResult
  $Res call(
      {Trip trip,
      List<Place> places,
      List<Route> routes,
      String? selectedItemId,
      String? selectedItemType,
      EditorMode mode,
      bool saving,
      bool bottomPanelExpanded,
      AppMapController? mapController,
      String? routeStartItemId,
      String? routeStartItemType});

  $TripCopyWith<$Res> get trip;
}

/// @nodoc
class _$EditorStateCopyWithImpl<$Res, $Val extends EditorState>
    implements $EditorStateCopyWith<$Res> {
  _$EditorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trip = null,
    Object? places = null,
    Object? routes = null,
    Object? selectedItemId = freezed,
    Object? selectedItemType = freezed,
    Object? mode = null,
    Object? saving = null,
    Object? bottomPanelExpanded = null,
    Object? mapController = freezed,
    Object? routeStartItemId = freezed,
    Object? routeStartItemType = freezed,
  }) {
    return _then(_value.copyWith(
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as Trip,
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
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as EditorMode,
      saving: null == saving
          ? _value.saving
          : saving // ignore: cast_nullable_to_non_nullable
              as bool,
      bottomPanelExpanded: null == bottomPanelExpanded
          ? _value.bottomPanelExpanded
          : bottomPanelExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      mapController: freezed == mapController
          ? _value.mapController
          : mapController // ignore: cast_nullable_to_non_nullable
              as AppMapController?,
      routeStartItemId: freezed == routeStartItemId
          ? _value.routeStartItemId
          : routeStartItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      routeStartItemType: freezed == routeStartItemType
          ? _value.routeStartItemType
          : routeStartItemType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripCopyWith<$Res> get trip {
    return $TripCopyWith<$Res>(_value.trip, (value) {
      return _then(_value.copyWith(trip: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EditorStateImplCopyWith<$Res>
    implements $EditorStateCopyWith<$Res> {
  factory _$$EditorStateImplCopyWith(
          _$EditorStateImpl value, $Res Function(_$EditorStateImpl) then) =
      __$$EditorStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Trip trip,
      List<Place> places,
      List<Route> routes,
      String? selectedItemId,
      String? selectedItemType,
      EditorMode mode,
      bool saving,
      bool bottomPanelExpanded,
      AppMapController? mapController,
      String? routeStartItemId,
      String? routeStartItemType});

  @override
  $TripCopyWith<$Res> get trip;
}

/// @nodoc
class __$$EditorStateImplCopyWithImpl<$Res>
    extends _$EditorStateCopyWithImpl<$Res, _$EditorStateImpl>
    implements _$$EditorStateImplCopyWith<$Res> {
  __$$EditorStateImplCopyWithImpl(
      _$EditorStateImpl _value, $Res Function(_$EditorStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trip = null,
    Object? places = null,
    Object? routes = null,
    Object? selectedItemId = freezed,
    Object? selectedItemType = freezed,
    Object? mode = null,
    Object? saving = null,
    Object? bottomPanelExpanded = null,
    Object? mapController = freezed,
    Object? routeStartItemId = freezed,
    Object? routeStartItemType = freezed,
  }) {
    return _then(_$EditorStateImpl(
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as Trip,
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
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as EditorMode,
      saving: null == saving
          ? _value.saving
          : saving // ignore: cast_nullable_to_non_nullable
              as bool,
      bottomPanelExpanded: null == bottomPanelExpanded
          ? _value.bottomPanelExpanded
          : bottomPanelExpanded // ignore: cast_nullable_to_non_nullable
              as bool,
      mapController: freezed == mapController
          ? _value.mapController
          : mapController // ignore: cast_nullable_to_non_nullable
              as AppMapController?,
      routeStartItemId: freezed == routeStartItemId
          ? _value.routeStartItemId
          : routeStartItemId // ignore: cast_nullable_to_non_nullable
              as String?,
      routeStartItemType: freezed == routeStartItemType
          ? _value.routeStartItemType
          : routeStartItemType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$EditorStateImpl implements _EditorState {
  const _$EditorStateImpl(
      {required this.trip,
      final List<Place> places = const [],
      final List<Route> routes = const [],
      this.selectedItemId,
      this.selectedItemType,
      this.mode = EditorMode.view,
      this.saving = false,
      this.bottomPanelExpanded = false,
      this.mapController,
      this.routeStartItemId,
      this.routeStartItemType})
      : _places = places,
        _routes = routes;

  @override
  final Trip trip;
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

// Selection
  @override
  final String? selectedItemId;
  @override
  final String? selectedItemType;
// 'place', 'city', 'route'
// Editor mode
  @override
  @JsonKey()
  final EditorMode mode;
// UI state
  @override
  @JsonKey()
  final bool saving;
  @override
  @JsonKey()
  final bool bottomPanelExpanded;
// Map controller reference
  @override
  final AppMapController? mapController;
// Route drawing state
  @override
  final String? routeStartItemId;
  @override
  final String? routeStartItemType;

  @override
  String toString() {
    return 'EditorState(trip: $trip, places: $places, routes: $routes, selectedItemId: $selectedItemId, selectedItemType: $selectedItemType, mode: $mode, saving: $saving, bottomPanelExpanded: $bottomPanelExpanded, mapController: $mapController, routeStartItemId: $routeStartItemId, routeStartItemType: $routeStartItemType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditorStateImpl &&
            (identical(other.trip, trip) || other.trip == trip) &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            const DeepCollectionEquality().equals(other._routes, _routes) &&
            (identical(other.selectedItemId, selectedItemId) ||
                other.selectedItemId == selectedItemId) &&
            (identical(other.selectedItemType, selectedItemType) ||
                other.selectedItemType == selectedItemType) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.saving, saving) || other.saving == saving) &&
            (identical(other.bottomPanelExpanded, bottomPanelExpanded) ||
                other.bottomPanelExpanded == bottomPanelExpanded) &&
            (identical(other.mapController, mapController) ||
                other.mapController == mapController) &&
            (identical(other.routeStartItemId, routeStartItemId) ||
                other.routeStartItemId == routeStartItemId) &&
            (identical(other.routeStartItemType, routeStartItemType) ||
                other.routeStartItemType == routeStartItemType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      trip,
      const DeepCollectionEquality().hash(_places),
      const DeepCollectionEquality().hash(_routes),
      selectedItemId,
      selectedItemType,
      mode,
      saving,
      bottomPanelExpanded,
      mapController,
      routeStartItemId,
      routeStartItemType);

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditorStateImplCopyWith<_$EditorStateImpl> get copyWith =>
      __$$EditorStateImplCopyWithImpl<_$EditorStateImpl>(this, _$identity);
}

abstract class _EditorState implements EditorState {
  const factory _EditorState(
      {required final Trip trip,
      final List<Place> places,
      final List<Route> routes,
      final String? selectedItemId,
      final String? selectedItemType,
      final EditorMode mode,
      final bool saving,
      final bool bottomPanelExpanded,
      final AppMapController? mapController,
      final String? routeStartItemId,
      final String? routeStartItemType}) = _$EditorStateImpl;

  @override
  Trip get trip;
  @override
  List<Place> get places;
  @override
  List<Route> get routes; // Selection
  @override
  String? get selectedItemId;
  @override
  String? get selectedItemType; // 'place', 'city', 'route'
// Editor mode
  @override
  EditorMode get mode; // UI state
  @override
  bool get saving;
  @override
  bool get bottomPanelExpanded; // Map controller reference
  @override
  AppMapController? get mapController; // Route drawing state
  @override
  String? get routeStartItemId;
  @override
  String? get routeStartItemType;

  /// Create a copy of EditorState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditorStateImplCopyWith<_$EditorStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
