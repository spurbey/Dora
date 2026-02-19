// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return _Place.fromJson(json);
}

/// @nodoc
mixin _$Place {
  String get id => throw _privateConstructorUsedError;
  String get tripId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  AppLatLng get coordinates => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get visitTime => throw _privateConstructorUsedError;
  int? get dayNumber => throw _privateConstructorUsedError;
  int get orderIndex => throw _privateConstructorUsedError;
  List<String> get photoUrls =>
      throw _privateConstructorUsedError; // Place classification
  String? get placeType =>
      throw _privateConstructorUsedError; // 'city', 'restaurant', 'hotel', 'attraction', 'museum', 'park', 'shopping', 'nightlife', 'cafe'
  int? get rating => throw _privateConstructorUsedError; // 0-5
// Sync metadata
  DateTime get localUpdatedAt => throw _privateConstructorUsedError;
  DateTime get serverUpdatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCopyWith<Place> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCopyWith<$Res> {
  factory $PlaceCopyWith(Place value, $Res Function(Place) then) =
      _$PlaceCopyWithImpl<$Res, Place>;
  @useResult
  $Res call(
      {String id,
      String tripId,
      String name,
      String? address,
      AppLatLng coordinates,
      String? notes,
      String? visitTime,
      int? dayNumber,
      int orderIndex,
      List<String> photoUrls,
      String? placeType,
      int? rating,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});

  $AppLatLngCopyWith<$Res> get coordinates;
}

/// @nodoc
class _$PlaceCopyWithImpl<$Res, $Val extends Place>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? name = null,
    Object? address = freezed,
    Object? coordinates = null,
    Object? notes = freezed,
    Object? visitTime = freezed,
    Object? dayNumber = freezed,
    Object? orderIndex = null,
    Object? photoUrls = null,
    Object? placeType = freezed,
    Object? rating = freezed,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
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
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      photoUrls: null == photoUrls
          ? _value.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      placeType: freezed == placeType
          ? _value.placeType
          : placeType // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppLatLngCopyWith<$Res> get coordinates {
    return $AppLatLngCopyWith<$Res>(_value.coordinates, (value) {
      return _then(_value.copyWith(coordinates: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaceImplCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$$PlaceImplCopyWith(
          _$PlaceImpl value, $Res Function(_$PlaceImpl) then) =
      __$$PlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tripId,
      String name,
      String? address,
      AppLatLng coordinates,
      String? notes,
      String? visitTime,
      int? dayNumber,
      int orderIndex,
      List<String> photoUrls,
      String? placeType,
      int? rating,
      DateTime localUpdatedAt,
      DateTime serverUpdatedAt,
      String syncStatus});

  @override
  $AppLatLngCopyWith<$Res> get coordinates;
}

/// @nodoc
class __$$PlaceImplCopyWithImpl<$Res>
    extends _$PlaceCopyWithImpl<$Res, _$PlaceImpl>
    implements _$$PlaceImplCopyWith<$Res> {
  __$$PlaceImplCopyWithImpl(
      _$PlaceImpl _value, $Res Function(_$PlaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tripId = null,
    Object? name = null,
    Object? address = freezed,
    Object? coordinates = null,
    Object? notes = freezed,
    Object? visitTime = freezed,
    Object? dayNumber = freezed,
    Object? orderIndex = null,
    Object? photoUrls = null,
    Object? placeType = freezed,
    Object? rating = freezed,
    Object? localUpdatedAt = null,
    Object? serverUpdatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$PlaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tripId: null == tripId
          ? _value.tripId
          : tripId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
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
      orderIndex: null == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int,
      photoUrls: null == photoUrls
          ? _value._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      placeType: freezed == placeType
          ? _value.placeType
          : placeType // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
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
class _$PlaceImpl implements _Place {
  const _$PlaceImpl(
      {required this.id,
      required this.tripId,
      required this.name,
      this.address,
      required this.coordinates,
      this.notes,
      this.visitTime,
      this.dayNumber,
      required this.orderIndex,
      final List<String> photoUrls = const [],
      this.placeType,
      this.rating,
      required this.localUpdatedAt,
      required this.serverUpdatedAt,
      this.syncStatus = 'pending'})
      : _photoUrls = photoUrls;

  factory _$PlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String tripId;
  @override
  final String name;
  @override
  final String? address;
  @override
  final AppLatLng coordinates;
  @override
  final String? notes;
  @override
  final String? visitTime;
  @override
  final int? dayNumber;
  @override
  final int orderIndex;
  final List<String> _photoUrls;
  @override
  @JsonKey()
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

// Place classification
  @override
  final String? placeType;
// 'city', 'restaurant', 'hotel', 'attraction', 'museum', 'park', 'shopping', 'nightlife', 'cafe'
  @override
  final int? rating;
// 0-5
// Sync metadata
  @override
  final DateTime localUpdatedAt;
  @override
  final DateTime serverUpdatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'Place(id: $id, tripId: $tripId, name: $name, address: $address, coordinates: $coordinates, notes: $notes, visitTime: $visitTime, dayNumber: $dayNumber, orderIndex: $orderIndex, photoUrls: $photoUrls, placeType: $placeType, rating: $rating, localUpdatedAt: $localUpdatedAt, serverUpdatedAt: $serverUpdatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tripId, tripId) || other.tripId == tripId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.coordinates, coordinates) ||
                other.coordinates == coordinates) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.visitTime, visitTime) ||
                other.visitTime == visitTime) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls) &&
            (identical(other.placeType, placeType) ||
                other.placeType == placeType) &&
            (identical(other.rating, rating) || other.rating == rating) &&
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
      name,
      address,
      coordinates,
      notes,
      visitTime,
      dayNumber,
      orderIndex,
      const DeepCollectionEquality().hash(_photoUrls),
      placeType,
      rating,
      localUpdatedAt,
      serverUpdatedAt,
      syncStatus);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      __$$PlaceImplCopyWithImpl<_$PlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceImplToJson(
      this,
    );
  }
}

abstract class _Place implements Place {
  const factory _Place(
      {required final String id,
      required final String tripId,
      required final String name,
      final String? address,
      required final AppLatLng coordinates,
      final String? notes,
      final String? visitTime,
      final int? dayNumber,
      required final int orderIndex,
      final List<String> photoUrls,
      final String? placeType,
      final int? rating,
      required final DateTime localUpdatedAt,
      required final DateTime serverUpdatedAt,
      final String syncStatus}) = _$PlaceImpl;

  factory _Place.fromJson(Map<String, dynamic> json) = _$PlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get tripId;
  @override
  String get name;
  @override
  String? get address;
  @override
  AppLatLng get coordinates;
  @override
  String? get notes;
  @override
  String? get visitTime;
  @override
  int? get dayNumber;
  @override
  int get orderIndex;
  @override
  List<String> get photoUrls; // Place classification
  @override
  String?
      get placeType; // 'city', 'restaurant', 'hotel', 'attraction', 'museum', 'park', 'shopping', 'nightlife', 'cafe'
  @override
  int? get rating; // 0-5
// Sync metadata
  @override
  DateTime get localUpdatedAt;
  @override
  DateTime get serverUpdatedAt;
  @override
  String get syncStatus;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
