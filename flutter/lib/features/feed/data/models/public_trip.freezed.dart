// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PublicTrip _$PublicTripFromJson(Map<String, dynamic> json) {
  return _PublicTrip.fromJson(json);
}

/// @nodoc
mixin _$PublicTrip {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get coverPhotoUrl => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  int get placeCount => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get visibility => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get localUpdatedAt => throw _privateConstructorUsedError;
  DateTime get serverUpdatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this PublicTrip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublicTrip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicTripCopyWith<PublicTrip> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicTripCopyWith<$Res> {
  factory $PublicTripCopyWith(
          PublicTrip value, $Res Function(PublicTrip) then) =
      _$PublicTripCopyWithImpl<$Res, PublicTrip>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? coverPhotoUrl,
      String userId,
      String username,
      int placeCount,
      int? duration,
      List<String> tags,
      String visibility,
      int viewCount,
      DateTime createdAt,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});
}

/// @nodoc
class _$PublicTripCopyWithImpl<$Res, $Val extends PublicTrip>
    implements $PublicTripCopyWith<$Res> {
  _$PublicTripCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicTrip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? coverPhotoUrl = freezed,
    Object? userId = null,
    Object? username = null,
    Object? placeCount = null,
    Object? duration = freezed,
    Object? tags = null,
    Object? visibility = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      coverPhotoUrl: freezed == coverPhotoUrl
          ? _value.coverPhotoUrl
          : coverPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      placeCount: null == placeCount
          ? _value.placeCount
          : placeCount // ignore: cast_nullable_to_non_nullable
              as int,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
abstract class _$$PublicTripImplCopyWith<$Res>
    implements $PublicTripCopyWith<$Res> {
  factory _$$PublicTripImplCopyWith(
          _$PublicTripImpl value, $Res Function(_$PublicTripImpl) then) =
      __$$PublicTripImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? coverPhotoUrl,
      String userId,
      String username,
      int placeCount,
      int? duration,
      List<String> tags,
      String visibility,
      int viewCount,
      DateTime createdAt,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});
}

/// @nodoc
class __$$PublicTripImplCopyWithImpl<$Res>
    extends _$PublicTripCopyWithImpl<$Res, _$PublicTripImpl>
    implements _$$PublicTripImplCopyWith<$Res> {
  __$$PublicTripImplCopyWithImpl(
      _$PublicTripImpl _value, $Res Function(_$PublicTripImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicTrip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? coverPhotoUrl = freezed,
    Object? userId = null,
    Object? username = null,
    Object? placeCount = null,
    Object? duration = freezed,
    Object? tags = null,
    Object? visibility = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$PublicTripImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      placeCount: null == placeCount
          ? _value.placeCount
          : placeCount // ignore: cast_nullable_to_non_nullable
              as int,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      visibility: null == visibility
          ? _value.visibility
          : visibility // ignore: cast_nullable_to_non_nullable
              as String,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
class _$PublicTripImpl implements _PublicTrip {
  const _$PublicTripImpl(
      {required this.id,
      required this.name,
      this.description,
      this.coverPhotoUrl,
      required this.userId,
      required this.username,
      required this.placeCount,
      this.duration,
      final List<String> tags = const [],
      this.visibility = 'public',
      this.viewCount = 0,
      required this.createdAt,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      this.syncStatus = 'synced'})
      : _tags = tags;

  factory _$PublicTripImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublicTripImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? coverPhotoUrl;
  @override
  final String userId;
  @override
  final String username;
  @override
  final int placeCount;
  @override
  final int? duration;
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
  @JsonKey()
  final int viewCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime localUpdatedAt;
  @override
  final DateTime serverUpdatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'PublicTrip(id: $id, name: $name, description: $description, coverPhotoUrl: $coverPhotoUrl, userId: $userId, username: $username, placeCount: $placeCount, duration: $duration, tags: $tags, visibility: $visibility, viewCount: $viewCount, createdAt: $createdAt, localUpdatedAt: $localUpdatedAt, serverUpdatedAt: $serverUpdatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicTripImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverPhotoUrl, coverPhotoUrl) ||
                other.coverPhotoUrl == coverPhotoUrl) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.placeCount, placeCount) ||
                other.placeCount == placeCount) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
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
      name,
      description,
      coverPhotoUrl,
      userId,
      username,
      placeCount,
      duration,
      const DeepCollectionEquality().hash(_tags),
      visibility,
      viewCount,
      createdAt,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus);

  /// Create a copy of PublicTrip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicTripImplCopyWith<_$PublicTripImpl> get copyWith =>
      __$$PublicTripImplCopyWithImpl<_$PublicTripImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublicTripImplToJson(
      this,
    );
  }
}

abstract class _PublicTrip implements PublicTrip {
  const factory _PublicTrip(
      {required final String id,
      required final String name,
      final String? description,
      final String? coverPhotoUrl,
      required final String userId,
      required final String username,
      required final int placeCount,
      final int? duration,
      final List<String> tags,
      final String visibility,
      final int viewCount,
      required final DateTime createdAt,
      required final DateTime localUpdatedAt,
      required final DateTime serverUpdatedAt,
      final String syncStatus}) = _$PublicTripImpl;

  factory _PublicTrip.fromJson(Map<String, dynamic> json) =
      _$PublicTripImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get coverPhotoUrl;
  @override
  String get userId;
  @override
  String get username;
  @override
  int get placeCount;
  @override
  int? get duration;
  @override
  List<String> get tags;
  @override
  String get visibility;
  @override
  int get viewCount;
  @override
  DateTime get createdAt;
  @override
  DateTime get localUpdatedAt;
  @override
  DateTime get serverUpdatedAt;
  @override
  String get syncStatus;

  /// Create a copy of PublicTrip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicTripImplCopyWith<_$PublicTripImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
