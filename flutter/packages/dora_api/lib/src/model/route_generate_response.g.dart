// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_generate_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RouteGenerateResponse extends RouteGenerateResponse {
  @override
  final JsonObject routeGeojson;
  @override
  final num distanceKm;
  @override
  final int durationMins;
  @override
  final String? polylineEncoded;

  factory _$RouteGenerateResponse(
          [void Function(RouteGenerateResponseBuilder)? updates]) =>
      (RouteGenerateResponseBuilder()..update(updates))._build();

  _$RouteGenerateResponse._(
      {required this.routeGeojson,
      required this.distanceKm,
      required this.durationMins,
      this.polylineEncoded})
      : super._();
  @override
  RouteGenerateResponse rebuild(
          void Function(RouteGenerateResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteGenerateResponseBuilder toBuilder() =>
      RouteGenerateResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteGenerateResponse &&
        routeGeojson == other.routeGeojson &&
        distanceKm == other.distanceKm &&
        durationMins == other.durationMins &&
        polylineEncoded == other.polylineEncoded;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeGeojson.hashCode);
    _$hash = $jc(_$hash, distanceKm.hashCode);
    _$hash = $jc(_$hash, durationMins.hashCode);
    _$hash = $jc(_$hash, polylineEncoded.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteGenerateResponse')
          ..add('routeGeojson', routeGeojson)
          ..add('distanceKm', distanceKm)
          ..add('durationMins', durationMins)
          ..add('polylineEncoded', polylineEncoded))
        .toString();
  }
}

class RouteGenerateResponseBuilder
    implements Builder<RouteGenerateResponse, RouteGenerateResponseBuilder> {
  _$RouteGenerateResponse? _$v;

  JsonObject? _routeGeojson;
  JsonObject? get routeGeojson => _$this._routeGeojson;
  set routeGeojson(JsonObject? routeGeojson) =>
      _$this._routeGeojson = routeGeojson;

  num? _distanceKm;
  num? get distanceKm => _$this._distanceKm;
  set distanceKm(num? distanceKm) => _$this._distanceKm = distanceKm;

  int? _durationMins;
  int? get durationMins => _$this._durationMins;
  set durationMins(int? durationMins) => _$this._durationMins = durationMins;

  String? _polylineEncoded;
  String? get polylineEncoded => _$this._polylineEncoded;
  set polylineEncoded(String? polylineEncoded) =>
      _$this._polylineEncoded = polylineEncoded;

  RouteGenerateResponseBuilder() {
    RouteGenerateResponse._defaults(this);
  }

  RouteGenerateResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeGeojson = $v.routeGeojson;
      _distanceKm = $v.distanceKm;
      _durationMins = $v.durationMins;
      _polylineEncoded = $v.polylineEncoded;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteGenerateResponse other) {
    _$v = other as _$RouteGenerateResponse;
  }

  @override
  void update(void Function(RouteGenerateResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteGenerateResponse build() => _build();

  _$RouteGenerateResponse _build() {
    final _$result = _$v ??
        _$RouteGenerateResponse._(
          routeGeojson: BuiltValueNullFieldError.checkNotNull(
              routeGeojson, r'RouteGenerateResponse', 'routeGeojson'),
          distanceKm: BuiltValueNullFieldError.checkNotNull(
              distanceKm, r'RouteGenerateResponse', 'distanceKm'),
          durationMins: BuiltValueNullFieldError.checkNotNull(
              durationMins, r'RouteGenerateResponse', 'durationMins'),
          polylineEncoded: polylineEncoded,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
