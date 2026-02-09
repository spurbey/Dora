// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Trip _$TripFromJson(Map<String, dynamic> json) {
  return _Trip.fromJson(json);
}

/// @nodoc
mixin _$Trip {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  AppLatLng? get centerPoint => throw _privateConstructorUsedError;
  double get zoom => throw _privateConstructorUsedError;
  DateTime get localUpdatedAt => throw _privateConstructorUsedError;
  DateTime get serverUpdatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripCopyWith<Trip> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripCopyWith<$Res> {
  factory $TripCopyWith(Trip value, $Res Function(Trip) then) =
      _$TripCopyWithImpl<$Res, Trip>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      DateTime? startDate,
      DateTime? endDate,
      List<String> tags,
      String visibility,
      AppLatLng? centerPoint,
      double zoom,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});

  $AppLatLngCopyWith<$Res>? get centerPoint;
}

/// @nodoc
class _$TripCopyWithImpl<$Res, $Val extends Trip>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? tags = null,
    Object? visibility = null,
    Object? centerPoint = freezed,
    Object? zoom = null,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      centerPoint: freezed == centerPoint
          ? _value.centerPoint
          : centerPoint // ignore: cast_nullable_to_non_nullable
              as AppLatLng?,
      zoom: null == zoom
          ? _value.zoom
          : zoom // ignore: cast_nullable_to_non_nullable
              as double,
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

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppLatLngCopyWith<$Res>? get centerPoint {
    if (_value.centerPoint == null) {
      return null;
    }

    return $AppLatLngCopyWith<$Res>(_value.centerPoint!, (value) {
      return _then(_value.copyWith(centerPoint: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripImplCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$$TripImplCopyWith(
          _$TripImpl value, $Res Function(_$TripImpl) then) =
      __$$TripImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      DateTime? startDate,
      DateTime? endDate,
      List<String> tags,
      String visibility,
      AppLatLng? centerPoint,
      double zoom,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});

  @override
  $AppLatLngCopyWith<$Res>? get centerPoint;
}

/// @nodoc
class __$$TripImplCopyWithImpl<$Res>
    extends _$TripCopyWithImpl<$Res, _$TripImpl>
    implements _$$TripImplCopyWith<$Res> {
  __$$TripImplCopyWithImpl(_$TripImpl _value, $Res Function(_$TripImpl) _then)
      : super(_value, _then);

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? tags = null,
    Object? visibility = null,
    Object? centerPoint = freezed,
    Object? zoom = null,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$TripImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      centerPoint: freezed == centerPoint
          ? _value.centerPoint
          : centerPoint // ignore: cast_nullable_to_non_nullable
              as AppLatLng?,
      zoom: null == zoom
          ? _value.zoom
          : zoom // ignore: cast_nullable_to_non_nullable
              as double,
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
class _$TripImpl implements _Trip {
  const _$TripImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      this.startDate,
      this.endDate,
      final List<String> tags = const [],
      this.visibility = 'private',
      this.centerPoint,
      this.zoom = 12.0,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      this.syncStatus = 'pending'})
      : _tags = tags;

  factory _$TripImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String visibility;
  @override
  final AppLatLng? centerPoint;
  @override
  @JsonKey()
  final double zoom;
  @override
  final DateTime localUpdatedAt;
  @override
  final DateTime serverUpdatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'Trip(id: $id, userId: $userId, name: $name, description: $description, startDate: $startDate, endDate: $endDate, tags: $tags, visibility: $visibility, centerPoint: $centerPoint, zoom: $zoom, localUpdatedAt: $localUpdatedAt, serverUpdatedAt: $serverUpdatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.centerPoint, centerPoint) ||
                other.centerPoint == centerPoint) &&
            (identical(other.zoom, zoom) || other.zoom == zoom) &&
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
      userId,
      name,
      description,
      startDate,
      endDate,
      const DeepCollectionEquality().hash(_tags),
      visibility,
      centerPoint,
      zoom,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus);

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripImplCopyWith<_$TripImpl> get copyWith =>
      __$$TripImplCopyWithImpl<_$TripImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripImplToJson(
      this,
    );
  }
}

abstract class _Trip implements Trip {
  const factory _Trip(
      {required final String id,
      required final String userId,
      required final String name,
      final String? description,
      final DateTime? startDate,
      final DateTime? endDate,
      final List<String> tags,
      final String visibility,
      final AppLatLng? centerPoint,
      final double zoom,
      required final DateTime localUpdatedAt,
      required final DateTime serverUpdatedAt,
      final String syncStatus}) = _$TripImpl;

  factory _Trip.fromJson(Map<String, dynamic> json) = _$TripImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  List<String> get tags;
  @override
  String get visibility;
  @override
  AppLatLng? get centerPoint;
  @override
  double get zoom;
  @override
  DateTime get localUpdatedAt;
  @override
  DateTime get serverUpdatedAt;
  @override
  String get syncStatus;

  /// Create a copy of Trip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripImplCopyWith<_$TripImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
