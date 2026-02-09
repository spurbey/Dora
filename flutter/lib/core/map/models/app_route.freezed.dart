// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_route.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppRoute {
  String get id => throw _privateConstructorUsedError;
  List<AppLatLng> get coordinates => throw _privateConstructorUsedError;
  Color? get color => throw _privateConstructorUsedError;
  double? get width => throw _privateConstructorUsedError;
  bool? get dashed => throw _privateConstructorUsedError;

  /// Create a copy of AppRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppRouteCopyWith<AppRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppRouteCopyWith<$Res> {
  factory $AppRouteCopyWith(AppRoute value, $Res Function(AppRoute) then) =
      _$AppRouteCopyWithImpl<$Res, AppRoute>;
  @useResult
  $Res call(
      {String id,
      List<AppLatLng> coordinates,
      Color? color,
      double? width,
      bool? dashed});
}

/// @nodoc
class _$AppRouteCopyWithImpl<$Res, $Val extends AppRoute>
    implements $AppRouteCopyWith<$Res> {
  _$AppRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coordinates = null,
    Object? color = freezed,
    Object? width = freezed,
    Object? dashed = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value.coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<AppLatLng>,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
      dashed: freezed == dashed
          ? _value.dashed
          : dashed // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppRouteImplCopyWith<$Res>
    implements $AppRouteCopyWith<$Res> {
  factory _$$AppRouteImplCopyWith(
          _$AppRouteImpl value, $Res Function(_$AppRouteImpl) then) =
      __$$AppRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<AppLatLng> coordinates,
      Color? color,
      double? width,
      bool? dashed});
}

/// @nodoc
class __$$AppRouteImplCopyWithImpl<$Res>
    extends _$AppRouteCopyWithImpl<$Res, _$AppRouteImpl>
    implements _$$AppRouteImplCopyWith<$Res> {
  __$$AppRouteImplCopyWithImpl(
      _$AppRouteImpl _value, $Res Function(_$AppRouteImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? coordinates = null,
    Object? color = freezed,
    Object? width = freezed,
    Object? dashed = freezed,
  }) {
    return _then(_$AppRouteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      coordinates: null == coordinates
          ? _value._coordinates
          : coordinates // ignore: cast_nullable_to_non_nullable
              as List<AppLatLng>,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
      width: freezed == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as double?,
      dashed: freezed == dashed
          ? _value.dashed
          : dashed // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$AppRouteImpl implements _AppRoute {
  const _$AppRouteImpl(
      {required this.id,
      required final List<AppLatLng> coordinates,
      this.color,
      this.width,
      this.dashed})
      : _coordinates = coordinates;

  @override
  final String id;
  final List<AppLatLng> _coordinates;
  @override
  List<AppLatLng> get coordinates {
    if (_coordinates is EqualUnmodifiableListView) return _coordinates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coordinates);
  }

  @override
  final Color? color;
  @override
  final double? width;
  @override
  final bool? dashed;

  @override
  String toString() {
    return 'AppRoute(id: $id, coordinates: $coordinates, color: $color, width: $width, dashed: $dashed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._coordinates, _coordinates) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.dashed, dashed) || other.dashed == dashed));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id,
      const DeepCollectionEquality().hash(_coordinates), color, width, dashed);

  /// Create a copy of AppRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppRouteImplCopyWith<_$AppRouteImpl> get copyWith =>
      __$$AppRouteImplCopyWithImpl<_$AppRouteImpl>(this, _$identity);
}

abstract class _AppRoute implements AppRoute {
  const factory _AppRoute(
      {required final String id,
      required final List<AppLatLng> coordinates,
      final Color? color,
      final double? width,
      final bool? dashed}) = _$AppRouteImpl;

  @override
  String get id;
  @override
  List<AppLatLng> get coordinates;
  @override
  Color? get color;
  @override
  double? get width;
  @override
  bool? get dashed;

  /// Create a copy of AppRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppRouteImplCopyWith<_$AppRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
