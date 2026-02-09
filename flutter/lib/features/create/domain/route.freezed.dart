// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Route _$RouteFromJson(Map<String, dynamic> json) {
  return _Route.fromJson(json);
}

/// @nodoc
mixin _$Route {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  List<AppLatLng> get coordinates => throw _privateConstructorUsedError;
  String get transportMode => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  int? get dayNumber => throw _privateConstructorUsedError;
  DateTime get localUpdatedAt => throw _privateConstructorUsedError;
  DateTime get serverUpdatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this Route to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteCopyWith<Route> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteCopyWith<$Res> {
  factory $RouteCopyWith(Route value, $Res Function(Route) then) =
      _$RouteCopyWithImpl<$Res, Route>;
  @useResult
  $Res call(
      {String id,
      String tripId,
      List<AppLatLng> coordinates,
      String transportMode,
      double? distance,
      int? duration,
      int? dayNumber,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});
}

/// @nodoc
class _$RouteCopyWithImpl<$Res, $Val extends Route>
    implements $RouteCopyWith<$Res> {
  _$RouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? coordinates = null,
    Object? transportMode = null,
    Object? distance = freezed,
    Object? duration = freezed,
    Object? dayNumber = freezed,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<AppLatLng>,
      transportMode: null == transportMode
          ? _value.transportMode
          : transportMode // ignore: cast_nullable_to_non_nullable
              as String,
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
      localUpdatedAt: null == localUpdatedAt
          ? _value.localUpdatedAt
          : localUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serverUpdatedAt: null == serverUpdatedAt
          ? _value.serverUpdatedAt
          : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RouteImplCopyWith<$Res> implements $RouteCopyWith<$Res> {
  factory _$$RouteImplCopyWith(
          _$RouteImpl value, $Res Function(_$RouteImpl) then) =
      __$$RouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tripId,
      List<AppLatLng> coordinates,
      String transportMode,
      double? distance,
      int? duration,
      int? dayNumber,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});
}

/// @nodoc
class __$$RouteImplCopyWithImpl<$Res>
    extends _$RouteCopyWithImpl<$Res, _$RouteImpl>
    implements _$$RouteImplCopyWith<$Res> {
  __$$RouteImplCopyWithImpl(
      _$RouteImpl _value, $Res Function(_$RouteImpl) _then)
      : super(_value, _then);

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? coordinates = null,
    Object? transportMode = null,
    Object? distance = freezed,
    Object? duration = freezed,
    Object? dayNumber = freezed,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$RouteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<AppLatLng>,
      transportMode: null == transportMode
          ? _value.transportMode
          : transportMode // ignore: cast_nullable_to_non_nullable
              as String,
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
      localUpdatedAt: null == localUpdatedAt
          ? _value.localUpdatedAt
          : localUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      serverUpdatedAt: null == serverUpdatedAt
          ? _value.serverUpdatedAt
          : serverUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteImpl implements _Route {
  const _$RouteImpl(
      {required this.id,
      required this.tripId,
      required final List<AppLatLng> coordinates,
      this.transportMode = 'car',
      this.distance,
      this.duration,
      this.dayNumber,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      this.syncStatus = 'pending'})
      : _coordinates = coordinates;

  factory _$RouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteImplFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  final List<AppLatLng> _coordinates;
  @override
  List<AppLatLng> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  @JsonKey()
  final String transportMode;
  @override
  final double? distance;
  @override
  final int? duration;
  @override
  final int? dayNumber;
  @override
  final DateTime localUpdatedAt;
  @override
  final DateTime serverUpdatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'Route(id: $id, tripId: $tripId, coordinates: $coordinates, transportMode: $transportMode, distance: $distance, duration: $duration, dayNumber: $dayNumber, localUpdatedAt: $localUpdatedAt, serverUpdatedAt: $serverUpdatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
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
            (identical(other.localUpdatedAt, localUpdatedAt) ||
                other.localUpdatedAt == localUpdatedAt) &&
            (identical(other.serverUpdatedAt, serverUpdatedAt) ||
                other.serverUpdatedAt == serverUpdatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tripId,
      const DeepCollectionEquality().hash(_coordinates),
      transportMode,
      distance,
      duration,
      dayNumber,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus);

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteImplCopyWith<_$RouteImpl> get copyWith =>
      __$$RouteImplCopyWithImpl<_$RouteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteImplToJson(
      this,
    );
  }
}

abstract class _Route implements Route {
  const factory _Route(
      {required final String id,
      required final String tripId,
      required final List<AppLatLng> coordinates,
      final String transportMode,
      final double? distance,
      final int? duration,
      final int? dayNumber,
      required final DateTime localUpdatedAt,
      required final DateTime serverUpdatedAt,
      final String syncStatus}) = _$RouteImpl;

  factory _Route.fromJson(Map<String, dynamic> json) = _$RouteImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  List<AppLatLng> get coordinates;
  @override
  String get transportMode;
  @override
  double? get distance;
  @override
  int? get duration;
  @override
  int? get dayNumber;
  @override
  DateTime get localUpdatedAt;
  @override
  DateTime get serverUpdatedAt;
  @override
  String get syncStatus;

  /// Create a copy of Route
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteImplCopyWith<_$RouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
