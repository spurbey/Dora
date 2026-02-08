// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripStats _$TripStatsFromJson(Map<String, dynamic> json) {
  return _TripStats.fromJson(json);
}

/// @nodoc
mixin _$TripStats {
  int get totalTrips => throw _privateConstructorUsedError;
  int get totalPlaces => throw _privateConstructorUsedError;
  int get totalVideos => throw _privateConstructorUsedError;
  int get totalViews => throw _privateConstructorUsedError;

  /// Serializes this TripStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TripStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TripStatsCopyWith<TripStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripStatsCopyWith<$Res> {
  factory $TripStatsCopyWith(TripStats value, $Res Function(TripStats) then) =
      _$TripStatsCopyWithImpl<$Res, TripStats>;
  @useResult
  $Res call({int totalTrips, int totalPlaces, int totalVideos, int totalViews});
}

/// @nodoc
class _$TripStatsCopyWithImpl<$Res, $Val extends TripStats>
    implements $TripStatsCopyWith<$Res> {
  _$TripStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TripStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTrips = null,
    Object? totalPlaces = null,
    Object? totalVideos = null,
    Object? totalViews = null,
  }) {
    return _then(_value.copyWith(
      totalTrips: null == totalTrips
          ? _value.totalTrips
          : totalTrips // ignore: cast_nullable_to_non_nullable
              as int,
      totalPlaces: null == totalPlaces
          ? _value.totalPlaces
          : totalPlaces // ignore: cast_nullable_to_non_nullable
              as int,
      totalVideos: null == totalVideos
          ? _value.totalVideos
          : totalVideos // ignore: cast_nullable_to_non_nullable
              as int,
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripStatsImplCopyWith<$Res>
    implements $TripStatsCopyWith<$Res> {
  factory _$$TripStatsImplCopyWith(
          _$TripStatsImpl value, $Res Function(_$TripStatsImpl) then) =
      __$$TripStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalTrips, int totalPlaces, int totalVideos, int totalViews});
}

/// @nodoc
class __$$TripStatsImplCopyWithImpl<$Res>
    extends _$TripStatsCopyWithImpl<$Res, _$TripStatsImpl>
    implements _$$TripStatsImplCopyWith<$Res> {
  __$$TripStatsImplCopyWithImpl(
      _$TripStatsImpl _value, $Res Function(_$TripStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TripStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalTrips = null,
    Object? totalPlaces = null,
    Object? totalVideos = null,
    Object? totalViews = null,
  }) {
    return _then(_$TripStatsImpl(
      totalTrips: null == totalTrips
          ? _value.totalTrips
          : totalTrips // ignore: cast_nullable_to_non_nullable
              as int,
      totalPlaces: null == totalPlaces
          ? _value.totalPlaces
          : totalPlaces // ignore: cast_nullable_to_non_nullable
              as int,
      totalVideos: null == totalVideos
          ? _value.totalVideos
          : totalVideos // ignore: cast_nullable_to_non_nullable
              as int,
      totalViews: null == totalViews
          ? _value.totalViews
          : totalViews // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripStatsImpl implements _TripStats {
  const _$TripStatsImpl(
      {this.totalTrips = 0,
      this.totalPlaces = 0,
      this.totalVideos = 0,
      this.totalViews = 0});

  factory _$TripStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalTrips;
  @override
  @JsonKey()
  final int totalPlaces;
  @override
  @JsonKey()
  final int totalVideos;
  @override
  @JsonKey()
  final int totalViews;

  @override
  String toString() {
    return 'TripStats(totalTrips: $totalTrips, totalPlaces: $totalPlaces, totalVideos: $totalVideos, totalViews: $totalViews)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripStatsImpl &&
            (identical(other.totalTrips, totalTrips) ||
                other.totalTrips == totalTrips) &&
            (identical(other.totalPlaces, totalPlaces) ||
                other.totalPlaces == totalPlaces) &&
            (identical(other.totalVideos, totalVideos) ||
                other.totalVideos == totalVideos) &&
            (identical(other.totalViews, totalViews) ||
                other.totalViews == totalViews));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, totalTrips, totalPlaces, totalVideos, totalViews);

  /// Create a copy of TripStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TripStatsImplCopyWith<_$TripStatsImpl> get copyWith =>
      __$$TripStatsImplCopyWithImpl<_$TripStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripStatsImplToJson(
      this,
    );
  }
}

abstract class _TripStats implements TripStats {
  const factory _TripStats(
      {final int totalTrips,
      final int totalPlaces,
      final int totalVideos,
      final int totalViews}) = _$TripStatsImpl;

  factory _TripStats.fromJson(Map<String, dynamic> json) =
      _$TripStatsImpl.fromJson;

  @override
  int get totalTrips;
  @override
  int get totalPlaces;
  @override
  int get totalVideos;
  @override
  int get totalViews;

  /// Create a copy of TripStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TripStatsImplCopyWith<_$TripStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
