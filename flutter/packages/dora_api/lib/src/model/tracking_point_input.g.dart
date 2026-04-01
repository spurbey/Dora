// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_point_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingPointInput extends TrackingPointInput {
  @override
  final String pointId;
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
  @override
  final num? headingDeg;
  @override
  final num? altitudeM;
  @override
  final String? provider;

  factory _$TrackingPointInput(
          [void Function(TrackingPointInputBuilder)? updates]) =>
      (TrackingPointInputBuilder()..update(updates))._build();

  _$TrackingPointInput._(
      {required this.pointId,
      required this.recordedAt,
      required this.latitude,
      required this.longitude,
      this.accuracyM,
      this.speedMps,
      this.headingDeg,
      this.altitudeM,
      this.provider})
      : super._();
  @override
  TrackingPointInput rebuild(
          void Function(TrackingPointInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingPointInputBuilder toBuilder() =>
      TrackingPointInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingPointInput &&
        pointId == other.pointId &&
        recordedAt == other.recordedAt &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        accuracyM == other.accuracyM &&
        speedMps == other.speedMps &&
        headingDeg == other.headingDeg &&
        altitudeM == other.altitudeM &&
        provider == other.provider;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pointId.hashCode);
    _$hash = $jc(_$hash, recordedAt.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, accuracyM.hashCode);
    _$hash = $jc(_$hash, speedMps.hashCode);
    _$hash = $jc(_$hash, headingDeg.hashCode);
    _$hash = $jc(_$hash, altitudeM.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingPointInput')
          ..add('pointId', pointId)
          ..add('recordedAt', recordedAt)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('accuracyM', accuracyM)
          ..add('speedMps', speedMps)
          ..add('headingDeg', headingDeg)
          ..add('altitudeM', altitudeM)
          ..add('provider', provider))
        .toString();
  }
}

class TrackingPointInputBuilder
    implements Builder<TrackingPointInput, TrackingPointInputBuilder> {
  _$TrackingPointInput? _$v;

  String? _pointId;
  String? get pointId => _$this._pointId;
  set pointId(String? pointId) => _$this._pointId = pointId;

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

  num? _headingDeg;
  num? get headingDeg => _$this._headingDeg;
  set headingDeg(num? headingDeg) => _$this._headingDeg = headingDeg;

  num? _altitudeM;
  num? get altitudeM => _$this._altitudeM;
  set altitudeM(num? altitudeM) => _$this._altitudeM = altitudeM;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  TrackingPointInputBuilder() {
    TrackingPointInput._defaults(this);
  }

  TrackingPointInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pointId = $v.pointId;
      _recordedAt = $v.recordedAt;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _accuracyM = $v.accuracyM;
      _speedMps = $v.speedMps;
      _headingDeg = $v.headingDeg;
      _altitudeM = $v.altitudeM;
      _provider = $v.provider;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingPointInput other) {
    _$v = other as _$TrackingPointInput;
  }

  @override
  void update(void Function(TrackingPointInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingPointInput build() => _build();

  _$TrackingPointInput _build() {
    final _$result = _$v ??
        _$TrackingPointInput._(
          pointId: BuiltValueNullFieldError.checkNotNull(
              pointId, r'TrackingPointInput', 'pointId'),
          recordedAt: BuiltValueNullFieldError.checkNotNull(
              recordedAt, r'TrackingPointInput', 'recordedAt'),
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'TrackingPointInput', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'TrackingPointInput', 'longitude'),
          accuracyM: accuracyM,
          speedMps: speedMps,
          headingDeg: headingDeg,
          altitudeM: altitudeM,
          provider: provider,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
