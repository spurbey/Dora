// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_geocoding_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GeocodingResult _$GeocodingResultFromJson(Map<String, dynamic> json) {
  return _GeocodingResult.fromJson(json);
}

/// @nodoc
mixin _$GeocodingResult {
  String get name => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  AppLatLng get coordinates => throw _privateConstructorUsedError;

  /// Serializes this GeocodingResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeocodingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeocodingResultCopyWith<GeocodingResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeocodingResultCopyWith<$Res> {
  factory $GeocodingResultCopyWith(
          GeocodingResult value, $Res Function(GeocodingResult) then) =
      _$GeocodingResultCopyWithImpl<$Res, GeocodingResult>;
  @useResult
  $Res call({String name, String? country, AppLatLng coordinates});

  $AppLatLngCopyWith<$Res> get coordinates;
}

/// @nodoc
class _$GeocodingResultCopyWithImpl<$Res, $Val extends GeocodingResult>
    implements $GeocodingResultCopyWith<$Res> {
  _$GeocodingResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeocodingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? country = freezed,
    Object? coordinates = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
    ) as $Val);
  }

  /// Create a copy of GeocodingResult
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
abstract class _$$GeocodingResultImplCopyWith<$Res>
    implements $GeocodingResultCopyWith<$Res> {
  factory _$$GeocodingResultImplCopyWith(_$GeocodingResultImpl value,
          $Res Function(_$GeocodingResultImpl) then) =
      __$$GeocodingResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? country, AppLatLng coordinates});

  @override
  $AppLatLngCopyWith<$Res> get coordinates;
}

/// @nodoc
class __$$GeocodingResultImplCopyWithImpl<$Res>
    extends _$GeocodingResultCopyWithImpl<$Res, _$GeocodingResultImpl>
    implements _$$GeocodingResultImplCopyWith<$Res> {
  __$$GeocodingResultImplCopyWithImpl(
      _$GeocodingResultImpl _value, $Res Function(_$GeocodingResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeocodingResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? country = freezed,
    Object? coordinates = null,
  }) {
    return _then(_$GeocodingResultImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeocodingResultImpl implements _GeocodingResult {
  const _$GeocodingResultImpl(
      {required this.name, this.country, required this.coordinates});

  factory _$GeocodingResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeocodingResultImplFromJson(json);

  @override
  final String name;
  @override
  final String? country;
  @override
  final AppLatLng coordinates;

  @override
  String toString() {
    return 'GeocodingResult(name: $name, country: $country, coordinates: $coordinates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeocodingResultImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.coordinates, coordinates) ||
                other.coordinates == coordinates));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, country, coordinates);

  /// Create a copy of GeocodingResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeocodingResultImplCopyWith<_$GeocodingResultImpl> get copyWith =>
      __$$GeocodingResultImplCopyWithImpl<_$GeocodingResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeocodingResultImplToJson(
      this,
    );
  }
}

abstract class _GeocodingResult implements GeocodingResult {
  const factory _GeocodingResult(
      {required final String name,
      final String? country,
      required final AppLatLng coordinates}) = _$GeocodingResultImpl;

  factory _GeocodingResult.fromJson(Map<String, dynamic> json) =
      _$GeocodingResultImpl.fromJson;

  @override
  String get name;
  @override
  String? get country;
  @override
  AppLatLng get coordinates;

  /// Create a copy of GeocodingResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeocodingResultImplCopyWith<_$GeocodingResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
