// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_path_point_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingPathPointResponse extends TrackingPathPointResponse {
  @override
  final DateTime recordedAt;
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final num? accuracyM;
  @override
  final num? speedMps;

  factory _$TrackingPathPointResponse(
          [void Function(TrackingPathPointResponseBuilder)? updates]) =>
      (TrackingPathPointResponseBuilder()..update(updates))._build();

  _$TrackingPathPointResponse._(
      {required this.recordedAt,
      required this.latitude,
      required this.longitude,
      this.accuracyM,
      this.speedMps})
      : super._();
  @override
  TrackingPathPointResponse rebuild(
          void Function(TrackingPathPointResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingPathPointResponseBuilder toBuilder() =>
      TrackingPathPointResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingPathPointResponse &&
        recordedAt == other.recordedAt &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        accuracyM == other.accuracyM &&
        speedMps == other.speedMps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, recordedAt.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, accuracyM.hashCode);
    _$hash = $jc(_$hash, speedMps.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingPathPointResponse')
          ..add('recordedAt', recordedAt)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('accuracyM', accuracyM)
          ..add('speedMps', speedMps))
        .toString();
  }
}

class TrackingPathPointResponseBuilder
    implements
        Builder<TrackingPathPointResponse, TrackingPathPointResponseBuilder> {
  _$TrackingPathPointResponse? _$v;

  DateTime? _recordedAt;
  DateTime? get recordedAt => _$this._recordedAt;
  set recordedAt(DateTime? recordedAt) => _$this._recordedAt = recordedAt;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  num? _accuracyM;
  num? get accuracyM => _$this._accuracyM;
  set accuracyM(num? accuracyM) => _$this._accuracyM = accuracyM;

  num? _speedMps;
  num? get speedMps => _$this._speedMps;
  set speedMps(num? speedMps) => _$this._speedMps = speedMps;

  TrackingPathPointResponseBuilder() {
    TrackingPathPointResponse._defaults(this);
  }

  TrackingPathPointResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _recordedAt = $v.recordedAt;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _accuracyM = $v.accuracyM;
      _speedMps = $v.speedMps;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingPathPointResponse other) {
    _$v = other as _$TrackingPathPointResponse;
  }

  @override
  void update(void Function(TrackingPathPointResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingPathPointResponse build() => _build();

  _$TrackingPathPointResponse _build() {
    final _$result = _$v ??
        _$TrackingPathPointResponse._(
          recordedAt: BuiltValueNullFieldError.checkNotNull(
              recordedAt, r'TrackingPathPointResponse', 'recordedAt'),
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'TrackingPathPointResponse', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'TrackingPathPointResponse', 'longitude'),
          accuracyM: accuracyM,
          speedMps: speedMps,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
