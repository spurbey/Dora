// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_location.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentLocation extends MomentLocation {
  @override
  final num latitude;
  @override
  final num longitude;

  factory _$MomentLocation([void Function(MomentLocationBuilder)? updates]) =>
      (MomentLocationBuilder()..update(updates))._build();

  _$MomentLocation._({required this.latitude, required this.longitude})
      : super._();
  @override
  MomentLocation rebuild(void Function(MomentLocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MomentLocationBuilder toBuilder() => MomentLocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentLocation &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentLocation')
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class MomentLocationBuilder
    implements Builder<MomentLocation, MomentLocationBuilder> {
  _$MomentLocation? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  MomentLocationBuilder() {
    MomentLocation._defaults(this);
  }

  MomentLocationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentLocation other) {
    _$v = other as _$MomentLocation;
  }

  @override
  void update(void Function(MomentLocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentLocation build() => _build();

  _$MomentLocation _build() {
    final _$result = _$v ??
        _$MomentLocation._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'MomentLocation', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'MomentLocation', 'longitude'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
