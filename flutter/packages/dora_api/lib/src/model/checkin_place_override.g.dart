// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_place_override.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckinPlaceOverride extends CheckinPlaceOverride {
  @override
  final String? tripPlaceId;
  @override
  final String? name;
  @override
  final num? latitude;
  @override
  final num? longitude;

  factory _$CheckinPlaceOverride(
          [void Function(CheckinPlaceOverrideBuilder)? updates]) =>
      (CheckinPlaceOverrideBuilder()..update(updates))._build();

  _$CheckinPlaceOverride._(
      {this.tripPlaceId, this.name, this.latitude, this.longitude})
      : super._();
  @override
  CheckinPlaceOverride rebuild(
          void Function(CheckinPlaceOverrideBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckinPlaceOverrideBuilder toBuilder() =>
      CheckinPlaceOverrideBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckinPlaceOverride &&
        tripPlaceId == other.tripPlaceId &&
        name == other.name &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripPlaceId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckinPlaceOverride')
          ..add('tripPlaceId', tripPlaceId)
          ..add('name', name)
          ..add('latitude', latitude)
          ..add('longitude', longitude))
        .toString();
  }
}

class CheckinPlaceOverrideBuilder
    implements Builder<CheckinPlaceOverride, CheckinPlaceOverrideBuilder> {
  _$CheckinPlaceOverride? _$v;

  String? _tripPlaceId;
  String? get tripPlaceId => _$this._tripPlaceId;
  set tripPlaceId(String? tripPlaceId) => _$this._tripPlaceId = tripPlaceId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  CheckinPlaceOverrideBuilder() {
    CheckinPlaceOverride._defaults(this);
  }

  CheckinPlaceOverrideBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripPlaceId = $v.tripPlaceId;
      _name = $v.name;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckinPlaceOverride other) {
    _$v = other as _$CheckinPlaceOverride;
  }

  @override
  void update(void Function(CheckinPlaceOverrideBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckinPlaceOverride build() => _build();

  _$CheckinPlaceOverride _build() {
    final _$result = _$v ??
        _$CheckinPlaceOverride._(
          tripPlaceId: tripPlaceId,
          name: name,
          latitude: latitude,
          longitude: longitude,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
