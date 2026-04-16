// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_route_point_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2RoutePointResponse extends V2RoutePointResponse {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final DateTime? capturedAt;

  factory _$V2RoutePointResponse(
          [void Function(V2RoutePointResponseBuilder)? updates]) =>
      (V2RoutePointResponseBuilder()..update(updates))._build();

  _$V2RoutePointResponse._(
      {required this.latitude, required this.longitude, this.capturedAt})
      : super._();
  @override
  V2RoutePointResponse rebuild(
          void Function(V2RoutePointResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2RoutePointResponseBuilder toBuilder() =>
      V2RoutePointResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2RoutePointResponse &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        capturedAt == other.capturedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2RoutePointResponse')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('capturedAt', capturedAt))
        .toString();
  }
}

class V2RoutePointResponseBuilder
    implements Builder<V2RoutePointResponse, V2RoutePointResponseBuilder> {
  _$V2RoutePointResponse? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  V2RoutePointResponseBuilder() {
    V2RoutePointResponse._defaults(this);
  }

  V2RoutePointResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _capturedAt = $v.capturedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2RoutePointResponse other) {
    _$v = other as _$V2RoutePointResponse;
  }

  @override
  void update(void Function(V2RoutePointResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2RoutePointResponse build() => _build();

  _$V2RoutePointResponse _build() {
    final _$result = _$v ??
        _$V2RoutePointResponse._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'V2RoutePointResponse', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'V2RoutePointResponse', 'longitude'),
          capturedAt: capturedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
