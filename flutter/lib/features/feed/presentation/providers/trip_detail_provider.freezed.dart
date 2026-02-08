// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_detail_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TripDetailState {
  TripDetailData get data => throw _privateConstructorUsedError;
  int get currentTab => throw _privateConstructorUsedError;

  /// Create a copy of TripDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripDetailStateCopyWith<TripDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripDetailStateCopyWith<$Res> {
  factory $TripDetailStateCopyWith(
          TripDetailState value, $Res Function(TripDetailState) then) =
      _$TripDetailStateCopyWithImpl<$Res, TripDetailState>;
  @useResult
  $Res call({TripDetailData data, int currentTab});

  $TripDetailDataCopyWith<$Res> get data;
}

/// @nodoc
class _$TripDetailStateCopyWithImpl<$Res, $Val extends TripDetailState>
    implements $TripDetailStateCopyWith<$Res> {
  _$TripDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? currentTab = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as TripDetailData,
      currentTab: null == currentTab
          ? _value.currentTab
          : currentTab // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of TripDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TripDetailDataCopyWith<$Res> get data {
    return $TripDetailDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TripDetailStateImplCopyWith<$Res>
    implements $TripDetailStateCopyWith<$Res> {
  factory _$$TripDetailStateImplCopyWith(_$TripDetailStateImpl value,
          $Res Function(_$TripDetailStateImpl) then) =
      __$$TripDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TripDetailData data, int currentTab});

  @override
  $TripDetailDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$TripDetailStateImplCopyWithImpl<$Res>
    extends _$TripDetailStateCopyWithImpl<$Res, _$TripDetailStateImpl>
    implements _$$TripDetailStateImplCopyWith<$Res> {
  __$$TripDetailStateImplCopyWithImpl(
      _$TripDetailStateImpl _value, $Res Function(_$TripDetailStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? currentTab = null,
  }) {
    return _then(_$TripDetailStateImpl(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as TripDetailData,
      currentTab: null == currentTab
          ? _value.currentTab
          : currentTab // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TripDetailStateImpl implements _TripDetailState {
  const _$TripDetailStateImpl({required this.data, this.currentTab = 0});

  @override
  final TripDetailData data;
  @override
  @JsonKey()
  final int currentTab;

  @override
  String toString() {
    return 'TripDetailState(data: $data, currentTab: $currentTab)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripDetailStateImpl &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.currentTab, currentTab) ||
                other.currentTab == currentTab));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data, currentTab);

  /// Create a copy of TripDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripDetailStateImplCopyWith<_$TripDetailStateImpl> get copyWith =>
      __$$TripDetailStateImplCopyWithImpl<_$TripDetailStateImpl>(
          this, _$identity);
}

abstract class _TripDetailState implements TripDetailState {
  const factory _TripDetailState(
      {required final TripDetailData data,
      final int currentTab}) = _$TripDetailStateImpl;

  @override
  TripDetailData get data;
  @override
  int get currentTab;

  /// Create a copy of TripDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripDetailStateImplCopyWith<_$TripDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
