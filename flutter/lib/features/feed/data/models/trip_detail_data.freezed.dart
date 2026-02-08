// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_detail_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TripDetailData {
  PublicTrip get trip => throw _privateConstructorUsedError;
  List<TripPlace> get places => throw _privateConstructorUsedError;
  List<TripRoute> get routes => throw _privateConstructorUsedError;

  /// Create a copy of TripDetailData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripDetailDataCopyWith<TripDetailData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripDetailDataCopyWith<$Res> {
  factory $TripDetailDataCopyWith(
          TripDetailData value, $Res Function(TripDetailData) then) =
      _$TripDetailDataCopyWithImpl<$Res, TripDetailData>;
  @useResult
  $Res call({PublicTrip trip, List<TripPlace> places, List<TripRoute> routes});

  $PublicTripCopyWith<$Res> get trip;
}

/// @nodoc
class _$TripDetailDataCopyWithImpl<$Res, $Val extends TripDetailData>
    implements $TripDetailDataCopyWith<$Res> {
  _$TripDetailDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripDetailData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trip = null,
    Object? places = null,
    Object? routes = null,
  }) {
    return _then(_value.copyWith(
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as PublicTrip,
      places: null == places
          ? _value.places
          : places // ignore: cast_nullable_to_non_nullable
              as List<TripPlace>,
      routes: null == routes
          ? _value.routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<TripRoute>,
    ) as $Val);
  }

  /// Create a copy of TripDetailData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PublicTripCopyWith<$Res> get trip {
    return $PublicTripCopyWith<$Res>(_value.trip, (value) {
      return _then(_value.copyWith(trip: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripDetailDataImplCopyWith<$Res>
    implements $TripDetailDataCopyWith<$Res> {
  factory _$$TripDetailDataImplCopyWith(_$TripDetailDataImpl value,
          $Res Function(_$TripDetailDataImpl) then) =
      __$$TripDetailDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PublicTrip trip, List<TripPlace> places, List<TripRoute> routes});

  @override
  $PublicTripCopyWith<$Res> get trip;
}

/// @nodoc
class __$$TripDetailDataImplCopyWithImpl<$Res>
    extends _$TripDetailDataCopyWithImpl<$Res, _$TripDetailDataImpl>
    implements _$$TripDetailDataImplCopyWith<$Res> {
  __$$TripDetailDataImplCopyWithImpl(
      _$TripDetailDataImpl _value, $Res Function(_$TripDetailDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripDetailData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trip = null,
    Object? places = null,
    Object? routes = null,
  }) {
    return _then(_$TripDetailDataImpl(
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as PublicTrip,
      places: null == places
          ? _value._places
          : places // ignore: cast_nullable_to_non_nullable
              as List<TripPlace>,
      routes: null == routes
          ? _value._routes
          : routes // ignore: cast_nullable_to_non_nullable
              as List<TripRoute>,
    ));
  }
}

/// @nodoc

class _$TripDetailDataImpl implements _TripDetailData {
  const _$TripDetailDataImpl(
      {required this.trip,
      required final List<TripPlace> places,
      required final List<TripRoute> routes})
      : _places = places,
        _routes = routes;

  @override
  final PublicTrip trip;
  final List<TripPlace> _places;
  @override
  List<TripPlace> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  final List<TripRoute> _routes;
  @override
  List<TripRoute> get routes {
    if (_routes is EqualUnmodifiableListView) return _routes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routes);
  }

  @override
  String toString() {
    return 'TripDetailData(trip: $trip, places: $places, routes: $routes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripDetailDataImpl &&
            (identical(other.trip, trip) || other.trip == trip) &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            const DeepCollectionEquality().equals(other._routes, _routes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      trip,
      const DeepCollectionEquality().hash(_places),
      const DeepCollectionEquality().hash(_routes));

  /// Create a copy of TripDetailData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripDetailDataImplCopyWith<_$TripDetailDataImpl> get copyWith =>
      __$$TripDetailDataImplCopyWithImpl<_$TripDetailDataImpl>(
          this, _$identity);
}

abstract class _TripDetailData implements TripDetailData {
  const factory _TripDetailData(
      {required final PublicTrip trip,
      required final List<TripPlace> places,
      required final List<TripRoute> routes}) = _$TripDetailDataImpl;

  @override
  PublicTrip get trip;
  @override
  List<TripPlace> get places;
  @override
  List<TripRoute> get routes;

  /// Create a copy of TripDetailData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripDetailDataImplCopyWith<_$TripDetailDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripPlace _$TripPlaceFromJson(Map<String, dynamic> json) {
  return _TripPlace.fromJson(json);
}

/// @nodoc
mixin _$TripPlace {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get visitTime => throw _privateConstructorUsedError;
  int? get dayNumber => throw _privateConstructorUsedError;
  int? get orderIndex => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;

  /// Serializes this TripPlace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripPlaceCopyWith<TripPlace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripPlaceCopyWith<$Res> {
  factory $TripPlaceCopyWith(TripPlace value, $Res Function(TripPlace) then) =
      _$TripPlaceCopyWithImpl<$Res, TripPlace>;
  @useResult
  $Res call(
      {String id,
      String name,
      double latitude,
      double longitude,
      String? notes,
      String? visitTime,
      int? dayNumber,
      int? orderIndex,
      List<String> photoUrls});
}

/// @nodoc
class _$TripPlaceCopyWithImpl<$Res, $Val extends TripPlace>
    implements $TripPlaceCopyWith<$Res> {
  _$TripPlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? notes = freezed,
    Object? visitTime = freezed,
    Object? dayNumber = freezed,
    Object? orderIndex = freezed,
    Object? photoUrls = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      visitTime: freezed == visitTime
          ? _value.visitTime
          : visitTime // ignore: cast_nullable_to_non_nullable
              as String?,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      orderIndex: freezed == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      photoUrls: null == photoUrls
          ? _value.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripPlaceImplCopyWith<$Res>
    implements $TripPlaceCopyWith<$Res> {
  factory _$$TripPlaceImplCopyWith(
          _$TripPlaceImpl value, $Res Function(_$TripPlaceImpl) then) =
      __$$TripPlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double latitude,
      double longitude,
      String? notes,
      String? visitTime,
      int? dayNumber,
      int? orderIndex,
      List<String> photoUrls});
}

/// @nodoc
class __$$TripPlaceImplCopyWithImpl<$Res>
    extends _$TripPlaceCopyWithImpl<$Res, _$TripPlaceImpl>
    implements _$$TripPlaceImplCopyWith<$Res> {
  __$$TripPlaceImplCopyWithImpl(
      _$TripPlaceImpl _value, $Res Function(_$TripPlaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? notes = freezed,
    Object? visitTime = freezed,
    Object? dayNumber = freezed,
    Object? orderIndex = freezed,
    Object? photoUrls = null,
  }) {
    return _then(_$TripPlaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      visitTime: freezed == visitTime
          ? _value.visitTime
          : visitTime // ignore: cast_nullable_to_non_nullable
              as String?,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      orderIndex: freezed == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      photoUrls: null == photoUrls
          ? _value._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripPlaceImpl implements _TripPlace {
  const _$TripPlaceImpl(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      this.notes,
      this.visitTime,
      this.dayNumber,
      this.orderIndex,
      final List<String> photoUrls = const []})
      : _photoUrls = photoUrls;

  factory _$TripPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripPlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? notes;
  @override
  final String? visitTime;
  @override
  final int? dayNumber;
  @override
  final int? orderIndex;
  final List<String> _photoUrls;
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  @override
  String toString() {
    return 'TripPlace(id: $id, name: $name, latitude: $latitude, longitude: $longitude, notes: $notes, visitTime: $visitTime, dayNumber: $dayNumber, orderIndex: $orderIndex, photoUrls: $photoUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripPlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.visitTime, visitTime) ||
                other.visitTime == visitTime) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      latitude,
      longitude,
      notes,
      visitTime,
      dayNumber,
      orderIndex,
      const DeepCollectionEquality().hash(_photoUrls));

  /// Create a copy of TripPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripPlaceImplCopyWith<_$TripPlaceImpl> get copyWith =>
      __$$TripPlaceImplCopyWithImpl<_$TripPlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripPlaceImplToJson(
      this,
    );
  }
}

abstract class _TripPlace implements TripPlace {
  const factory _TripPlace(
      {required final String id,
      required final String name,
      required final double latitude,
      required final double longitude,
      final String? notes,
      final String? visitTime,
      final int? dayNumber,
      final int? orderIndex,
      final List<String> photoUrls}) = _$TripPlaceImpl;

  factory _TripPlace.fromJson(Map<String, dynamic> json) =
      _$TripPlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get notes;
  @override
  String? get visitTime;
  @override
  int? get dayNumber;
  @override
  int? get orderIndex;
  @override
  List<String> get photoUrls;

  /// Create a copy of TripPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripPlaceImplCopyWith<_$TripPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripRoute _$TripRouteFromJson(Map<String, dynamic> json) {
  return _TripRoute.fromJson(json);
}

/// @nodoc
mixin _$TripRoute {
  String get id => throw _privateConstructorUsedError;
  List<TripLatLng> get coordinates => throw _privateConstructorUsedError;
  String? get transportMode => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  int? get dayNumber => throw _privateConstructorUsedError;
  String? get polyline => throw _privateConstructorUsedError;

  /// Serializes this TripRoute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripRouteCopyWith<TripRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripRouteCopyWith<$Res> {
  factory $TripRouteCopyWith(TripRoute value, $Res Function(TripRoute) then) =
      _$TripRouteCopyWithImpl<$Res, TripRoute>;
  @useResult
  $Res call(
      {String id,
      List<TripLatLng> coordinates,
      String? transportMode,
      double? distance,
      int? duration,
      int? dayNumber,
      String? polyline});
}

/// @nodoc
class _$TripRouteCopyWithImpl<$Res, $Val extends TripRoute>
    implements $TripRouteCopyWith<$Res> {
  _$TripRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coordinates = null,
    Object? transportMode = freezed,
    Object? distance = freezed,
    Object? duration = freezed,
    Object? dayNumber = freezed,
    Object? polyline = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<TripLatLng>,
      transportMode: freezed == transportMode
          ? _value.transportMode
          : transportMode // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      polyline: freezed == polyline
          ? _value.polyline
          : polyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripRouteImplCopyWith<$Res>
    implements $TripRouteCopyWith<$Res> {
  factory _$$TripRouteImplCopyWith(
          _$TripRouteImpl value, $Res Function(_$TripRouteImpl) then) =
      __$$TripRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<TripLatLng> coordinates,
      String? transportMode,
      double? distance,
      int? duration,
      int? dayNumber,
      String? polyline});
}

/// @nodoc
class __$$TripRouteImplCopyWithImpl<$Res>
    extends _$TripRouteCopyWithImpl<$Res, _$TripRouteImpl>
    implements _$$TripRouteImplCopyWith<$Res> {
  __$$TripRouteImplCopyWithImpl(
      _$TripRouteImpl _value, $Res Function(_$TripRouteImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coordinates = null,
    Object? transportMode = freezed,
    Object? distance = freezed,
    Object? duration = freezed,
    Object? dayNumber = freezed,
    Object? polyline = freezed,
  }) {
    return _then(_$TripRouteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<TripLatLng>,
      transportMode: freezed == transportMode
          ? _value.transportMode
          : transportMode // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      dayNumber: freezed == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      polyline: freezed == polyline
          ? _value.polyline
          : polyline // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripRouteImpl implements _TripRoute {
  const _$TripRouteImpl(
      {required this.id,
      final List<TripLatLng> coordinates = const [],
      this.transportMode,
      this.distance,
      this.duration,
      this.dayNumber,
      this.polyline})
      : _coordinates = coordinates;

  factory _$TripRouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripRouteImplFromJson(json);

  @override
  final String id;
  final List<TripLatLng> _coordinates;
  @override
  @JsonKey()
  List<TripLatLng> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  final String? transportMode;
  @override
  final double? distance;
  @override
  final int? duration;
  @override
  final int? dayNumber;
  @override
  final String? polyline;

  @override
  String toString() {
    return 'TripRoute(id: $id, coordinates: $coordinates, transportMode: $transportMode, distance: $distance, duration: $duration, dayNumber: $dayNumber, polyline: $polyline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates) &&
            (identical(other.transportMode, transportMode) ||
                other.transportMode == transportMode) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.polyline, polyline) ||
                other.polyline == polyline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_coordinates),
      transportMode,
      distance,
      duration,
      dayNumber,
      polyline);

  /// Create a copy of TripRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripRouteImplCopyWith<_$TripRouteImpl> get copyWith =>
      __$$TripRouteImplCopyWithImpl<_$TripRouteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripRouteImplToJson(
      this,
    );
  }
}

abstract class _TripRoute implements TripRoute {
  const factory _TripRoute(
      {required final String id,
      final List<TripLatLng> coordinates,
      final String? transportMode,
      final double? distance,
      final int? duration,
      final int? dayNumber,
      final String? polyline}) = _$TripRouteImpl;

  factory _TripRoute.fromJson(Map<String, dynamic> json) =
      _$TripRouteImpl.fromJson;

  @override
  String get id;
  @override
  List<TripLatLng> get coordinates;
  @override
  String? get transportMode;
  @override
  double? get distance;
  @override
  int? get duration;
  @override
  int? get dayNumber;
  @override
  String? get polyline;

  /// Create a copy of TripRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripRouteImplCopyWith<_$TripRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripLatLng _$TripLatLngFromJson(Map<String, dynamic> json) {
  return _TripLatLng.fromJson(json);
}

/// @nodoc
mixin _$TripLatLng {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this TripLatLng to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripLatLng
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripLatLngCopyWith<TripLatLng> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripLatLngCopyWith<$Res> {
  factory $TripLatLngCopyWith(
          TripLatLng value, $Res Function(TripLatLng) then) =
      _$TripLatLngCopyWithImpl<$Res, TripLatLng>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$TripLatLngCopyWithImpl<$Res, $Val extends TripLatLng>
    implements $TripLatLngCopyWith<$Res> {
  _$TripLatLngCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripLatLng
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripLatLngImplCopyWith<$Res>
    implements $TripLatLngCopyWith<$Res> {
  factory _$$TripLatLngImplCopyWith(
          _$TripLatLngImpl value, $Res Function(_$TripLatLngImpl) then) =
      __$$TripLatLngImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$TripLatLngImplCopyWithImpl<$Res>
    extends _$TripLatLngCopyWithImpl<$Res, _$TripLatLngImpl>
    implements _$$TripLatLngImplCopyWith<$Res> {
  __$$TripLatLngImplCopyWithImpl(
      _$TripLatLngImpl _value, $Res Function(_$TripLatLngImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripLatLng
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(_$TripLatLngImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripLatLngImpl implements _TripLatLng {
  const _$TripLatLngImpl({required this.latitude, required this.longitude});

  factory _$TripLatLngImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripLatLngImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'TripLatLng(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripLatLngImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of TripLatLng
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripLatLngImplCopyWith<_$TripLatLngImpl> get copyWith =>
      __$$TripLatLngImplCopyWithImpl<_$TripLatLngImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripLatLngImplToJson(
      this,
    );
  }
}

abstract class _TripLatLng implements TripLatLng {
  const factory _TripLatLng(
      {required final double latitude,
      required final double longitude}) = _$TripLatLngImpl;

  factory _TripLatLng.fromJson(Map<String, dynamic> json) =
      _$TripLatLngImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of TripLatLng
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripLatLngImplCopyWith<_$TripLatLngImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
