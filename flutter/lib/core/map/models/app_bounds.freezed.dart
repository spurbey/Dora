// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_bounds.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppLatLngBounds _$AppLatLngBoundsFromJson(Map<String, dynamic> json) {
  return _AppLatLngBounds.fromJson(json);
}

/// @nodoc
mixin _$AppLatLngBounds {
  AppLatLng get southwest => throw _privateConstructorUsedError;
  AppLatLng get northeast => throw _privateConstructorUsedError;

  /// Serializes this AppLatLngBounds to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppLatLngBoundsCopyWith<AppLatLngBounds> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppLatLngBoundsCopyWith<$Res> {
  factory $AppLatLngBoundsCopyWith(
          AppLatLngBounds value, $Res Function(AppLatLngBounds) then) =
      _$AppLatLngBoundsCopyWithImpl<$Res, AppLatLngBounds>;
  @useResult
  $Res call({AppLatLng southwest, AppLatLng northeast});

  $AppLatLngCopyWith<$Res> get southwest;
  $AppLatLngCopyWith<$Res> get northeast;
}

/// @nodoc
class _$AppLatLngBoundsCopyWithImpl<$Res, $Val extends AppLatLngBounds>
    implements $AppLatLngBoundsCopyWith<$Res> {
  _$AppLatLngBoundsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? southwest = null,
    Object? northeast = null,
  }) {
    return _then(_value.copyWith(
      southwest: null == southwest
          ? _value.southwest
          : southwest // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
      northeast: null == northeast
          ? _value.northeast
          : northeast // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
    ) as $Val);
  }

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppLatLngCopyWith<$Res> get southwest {
    return $AppLatLngCopyWith<$Res>(_value.southwest, (value) {
      return _then(_value.copyWith(southwest: value) as $Val);
    });
  }

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppLatLngCopyWith<$Res> get northeast {
    return $AppLatLngCopyWith<$Res>(_value.northeast, (value) {
      return _then(_value.copyWith(northeast: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppLatLngBoundsImplCopyWith<$Res>
    implements $AppLatLngBoundsCopyWith<$Res> {
  factory _$$AppLatLngBoundsImplCopyWith(_$AppLatLngBoundsImpl value,
          $Res Function(_$AppLatLngBoundsImpl) then) =
      __$$AppLatLngBoundsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AppLatLng southwest, AppLatLng northeast});

  @override
  $AppLatLngCopyWith<$Res> get southwest;
  @override
  $AppLatLngCopyWith<$Res> get northeast;
}

/// @nodoc
class __$$AppLatLngBoundsImplCopyWithImpl<$Res>
    extends _$AppLatLngBoundsCopyWithImpl<$Res, _$AppLatLngBoundsImpl>
    implements _$$AppLatLngBoundsImplCopyWith<$Res> {
  __$$AppLatLngBoundsImplCopyWithImpl(
      _$AppLatLngBoundsImpl _value, $Res Function(_$AppLatLngBoundsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? southwest = null,
    Object? northeast = null,
  }) {
    return _then(_$AppLatLngBoundsImpl(
      southwest: null == southwest
          ? _value.southwest
          : southwest // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
      northeast: null == northeast
          ? _value.northeast
          : northeast // ignore: cast_nullable_to_non_nullable
              as AppLatLng,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppLatLngBoundsImpl implements _AppLatLngBounds {
  const _$AppLatLngBoundsImpl(
      {required this.southwest, required this.northeast});

  factory _$AppLatLngBoundsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppLatLngBoundsImplFromJson(json);

  @override
  final AppLatLng southwest;
  @override
  final AppLatLng northeast;

  @override
  String toString() {
    return 'AppLatLngBounds(southwest: $southwest, northeast: $northeast)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppLatLngBoundsImpl &&
            (identical(other.southwest, southwest) ||
                other.southwest == southwest) &&
            (identical(other.northeast, northeast) ||
                other.northeast == northeast));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, southwest, northeast);

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppLatLngBoundsImplCopyWith<_$AppLatLngBoundsImpl> get copyWith =>
      __$$AppLatLngBoundsImplCopyWithImpl<_$AppLatLngBoundsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppLatLngBoundsImplToJson(
      this,
    );
  }
}

abstract class _AppLatLngBounds implements AppLatLngBounds {
  const factory _AppLatLngBounds(
      {required final AppLatLng southwest,
      required final AppLatLng northeast}) = _$AppLatLngBoundsImpl;

  factory _AppLatLngBounds.fromJson(Map<String, dynamic> json) =
      _$AppLatLngBoundsImpl.fromJson;

  @override
  AppLatLng get southwest;
  @override
  AppLatLng get northeast;

  /// Create a copy of AppLatLngBounds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppLatLngBoundsImplCopyWith<_$AppLatLngBoundsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
