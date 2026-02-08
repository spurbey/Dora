// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserTrip _$UserTripFromJson(Map<String, dynamic> json) {
  return _UserTrip.fromJson(json);
}

/// @nodoc
mixin _$UserTrip {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get coverPhotoUrl => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  int get placeCount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get lastEditedAt => throw _privateConstructorUsedError;
  DateTime get localUpdatedAt => throw _privateConstructorUsedError;
  DateTime get serverUpdatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserTrip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserTrip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserTripCopyWith<UserTrip> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserTripCopyWith<$Res> {
  factory $UserTripCopyWith(UserTrip value, $Res Function(UserTrip) then) =
      _$UserTripCopyWithImpl<$Res, UserTrip>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      String? coverPhotoUrl,
      DateTime? startDate,
      DateTime? endDate,
      String visibility,
      int placeCount,
      String status,
      DateTime? lastEditedAt,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus,
      DateTime createdAt});
}

/// @nodoc
class _$UserTripCopyWithImpl<$Res, $Val extends UserTrip>
    implements $UserTripCopyWith<$Res> {
  _$UserTripCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserTrip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? coverPhotoUrl = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? visibility = null,
    Object? placeCount = null,
    Object? status = null,
    Object? lastEditedAt = freezed,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
    Object? createdAt = null,
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
      coverPhotoUrl: freezed == coverPhotoUrl
          ? _value.coverPhotoUrl
          : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      placeCount: null == placeCount
          ? _value.placeCount
          : placeCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      lastEditedAt: freezed == lastEditedAt
          ? _value.lastEditedAt
          : lastEditedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserTripImplCopyWith<$Res>
    implements $UserTripCopyWith<$Res> {
  factory _$$UserTripImplCopyWith(
          _$UserTripImpl value, $Res Function(_$UserTripImpl) then) =
      __$$UserTripImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String? description,
      String? coverPhotoUrl,
      DateTime? startDate,
      DateTime? endDate,
      String visibility,
      int placeCount,
      String status,
      DateTime? lastEditedAt,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus,
      DateTime createdAt});
}

/// @nodoc
class __$$UserTripImplCopyWithImpl<$Res>
    extends _$UserTripCopyWithImpl<$Res, _$UserTripImpl>
    implements _$$UserTripImplCopyWith<$Res> {
  __$$UserTripImplCopyWithImpl(
      _$UserTripImpl _value, $Res Function(_$UserTripImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserTrip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? coverPhotoUrl = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? visibility = null,
    Object? placeCount = null,
    Object? status = null,
    Object? lastEditedAt = freezed,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
    Object? createdAt = null,
  }) {
    return _then(_$UserTripImpl(
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
      coverPhotoUrl: freezed == coverPhotoUrl
          ? _value.coverPhotoUrl
          : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      placeCount: null == placeCount
          ? _value.placeCount
          : placeCount // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      lastEditedAt: freezed == lastEditedAt
          ? _value.lastEditedAt
          : lastEditedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserTripImpl implements _UserTrip {
  const _$UserTripImpl(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      this.coverPhotoUrl,
      this.startDate,
      this.endDate,
      this.visibility = 'private',
      this.placeCount = 0,
      this.status = 'editing',
      this.lastEditedAt,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      this.syncStatus = 'synced',
      required this.createdAt});

  factory _$UserTripImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserTripImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? coverPhotoUrl;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final String visibility;
  @override
  @JsonKey()
  final int placeCount;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? lastEditedAt;
  @override
  final DateTime localUpdatedAt;
  @override
  final DateTime serverUpdatedAt;
  @override
  @JsonKey()
  final String syncStatus;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'UserTrip(id: $id, userId: $userId, name: $name, description: $description, coverPhotoUrl: $coverPhotoUrl, startDate: $startDate, endDate: $endDate, visibility: $visibility, placeCount: $placeCount, status: $status, lastEditedAt: $lastEditedAt, localUpdatedAt: $localUpdatedAt, serverUpdatedAt: $serverUpdatedAt, syncStatus: $syncStatus, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserTripImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverPhotoUrl, coverPhotoUrl) ||
                other.coverPhotoUrl == coverPhotoUrl) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.placeCount, placeCount) ||
                other.placeCount == placeCount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastEditedAt, lastEditedAt) ||
                other.lastEditedAt == lastEditedAt) &&
            (identical(other.localUpdatedAt, localUpdatedAt) ||
                other.localUpdatedAt == localUpdatedAt) &&
            (identical(other.serverUpdatedAt, serverUpdatedAt) ||
                other.serverUpdatedAt == serverUpdatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      coverPhotoUrl,
      startDate,
      endDate,
      visibility,
      placeCount,
      status,
      lastEditedAt,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus,
      createdAt);

  /// Create a copy of UserTrip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserTripImplCopyWith<_$UserTripImpl> get copyWith =>
      __$$UserTripImplCopyWithImpl<_$UserTripImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserTripImplToJson(
      this,
    );
  }
}

abstract class _UserTrip implements UserTrip {
  const factory _UserTrip(
      {required final String id,
      required final String userId,
      required final String name,
      final String? description,
      final String? coverPhotoUrl,
      final DateTime? startDate,
      final DateTime? endDate,
      final String visibility,
      final int placeCount,
      final String status,
      final DateTime? lastEditedAt,
      required final DateTime localUpdatedAt,
      required final DateTime serverUpdatedAt,
      final String syncStatus,
      required final DateTime createdAt}) = _$UserTripImpl;

  factory _UserTrip.fromJson(Map<String, dynamic> json) =
      _$UserTripImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get coverPhotoUrl;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String get visibility;
  @override
  int get placeCount;
  @override
  String get status;
  @override
  DateTime? get lastEditedAt;
  @override
  DateTime get localUpdatedAt;
  @override
  DateTime get serverUpdatedAt;
  @override
  String get syncStatus;
  @override
  DateTime get createdAt;

  /// Create a copy of UserTrip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserTripImplCopyWith<_$UserTripImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
