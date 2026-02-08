// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TripFilter {
  String? get duration => throw _privateConstructorUsedError;
  String? get budget => throw _privateConstructorUsedError;
  String? get travelStyle => throw _privateConstructorUsedError;

  /// Create a copy of TripFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripFilterCopyWith<TripFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripFilterCopyWith<$Res> {
  factory $TripFilterCopyWith(
          TripFilter value, $Res Function(TripFilter) then) =
      _$TripFilterCopyWithImpl<$Res, TripFilter>;
  @useResult
  $Res call({String? duration, String? budget, String? travelStyle});
}

/// @nodoc
class _$TripFilterCopyWithImpl<$Res, $Val extends TripFilter>
    implements $TripFilterCopyWith<$Res> {
  _$TripFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = freezed,
    Object? budget = freezed,
    Object? travelStyle = freezed,
  }) {
    return _then(_value.copyWith(
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as String?,
      travelStyle: freezed == travelStyle
          ? _value.travelStyle
          : travelStyle // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripFilterImplCopyWith<$Res>
    implements $TripFilterCopyWith<$Res> {
  factory _$$TripFilterImplCopyWith(
          _$TripFilterImpl value, $Res Function(_$TripFilterImpl) then) =
      __$$TripFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? duration, String? budget, String? travelStyle});
}

/// @nodoc
class __$$TripFilterImplCopyWithImpl<$Res>
    extends _$TripFilterCopyWithImpl<$Res, _$TripFilterImpl>
    implements _$$TripFilterImplCopyWith<$Res> {
  __$$TripFilterImplCopyWithImpl(
      _$TripFilterImpl _value, $Res Function(_$TripFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duration = freezed,
    Object? budget = freezed,
    Object? travelStyle = freezed,
  }) {
    return _then(_$TripFilterImpl(
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      budget: freezed == budget
          ? _value.budget
          : budget // ignore: cast_nullable_to_non_nullable
              as String?,
      travelStyle: freezed == travelStyle
          ? _value.travelStyle
          : travelStyle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TripFilterImpl implements _TripFilter {
  const _$TripFilterImpl({this.duration, this.budget, this.travelStyle});

  @override
  final String? duration;
  @override
  final String? budget;
  @override
  final String? travelStyle;

  @override
  String toString() {
    return 'TripFilter(duration: $duration, budget: $budget, travelStyle: $travelStyle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripFilterImpl &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.travelStyle, travelStyle) ||
                other.travelStyle == travelStyle));
  }

  @override
  int get hashCode => Object.hash(runtimeType, duration, budget, travelStyle);

  /// Create a copy of TripFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripFilterImplCopyWith<_$TripFilterImpl> get copyWith =>
      __$$TripFilterImplCopyWithImpl<_$TripFilterImpl>(this, _$identity);
}

abstract class _TripFilter implements TripFilter {
  const factory _TripFilter(
      {final String? duration,
      final String? budget,
      final String? travelStyle}) = _$TripFilterImpl;

  @override
  String? get duration;
  @override
  String? get budget;
  @override
  String? get travelStyle;

  /// Create a copy of TripFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripFilterImplCopyWith<_$TripFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
