// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WaypointListResponse extends WaypointListResponse {
  @override
  final BuiltList<WaypointResponse> waypoints;
  @override
  final int total;

  factory _$WaypointListResponse(
          [void Function(WaypointListResponseBuilder)? updates]) =>
      (WaypointListResponseBuilder()..update(updates))._build();

  _$WaypointListResponse._({required this.waypoints, required this.total})
      : super._();
  @override
  WaypointListResponse rebuild(
          void Function(WaypointListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaypointListResponseBuilder toBuilder() =>
      WaypointListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaypointListResponse &&
        waypoints == other.waypoints &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, waypoints.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WaypointListResponse')
          ..add('waypoints', waypoints)
          ..add('total', total))
        .toString();
  }
}

class WaypointListResponseBuilder
    implements Builder<WaypointListResponse, WaypointListResponseBuilder> {
  _$WaypointListResponse? _$v;

  ListBuilder<WaypointResponse>? _waypoints;
  ListBuilder<WaypointResponse> get waypoints =>
      _$this._waypoints ??= ListBuilder<WaypointResponse>();
  set waypoints(ListBuilder<WaypointResponse>? waypoints) =>
      _$this._waypoints = waypoints;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  WaypointListResponseBuilder() {
    WaypointListResponse._defaults(this);
  }

  WaypointListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _waypoints = $v.waypoints.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WaypointListResponse other) {
    _$v = other as _$WaypointListResponse;
  }

  @override
  void update(void Function(WaypointListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaypointListResponse build() => _build();

  _$WaypointListResponse _build() {
    _$WaypointListResponse _$result;
    try {
      _$result = _$v ??
          _$WaypointListResponse._(
            waypoints: waypoints.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'WaypointListResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'waypoints';
        waypoints.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WaypointListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
