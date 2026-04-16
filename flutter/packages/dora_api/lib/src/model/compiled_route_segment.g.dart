// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_route_segment.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompiledRouteSegment extends CompiledRouteSegment {
  @override
  final String segmentId;
  @override
  final String? sessionId;
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;
  @override
  final num distanceM;
  @override
  final int rawPointCount;
  @override
  final int simplifiedPointCount;
  @override
  final BuiltMap<String, JsonObject?>? geometry;

  factory _$CompiledRouteSegment(
          [void Function(CompiledRouteSegmentBuilder)? updates]) =>
      (CompiledRouteSegmentBuilder()..update(updates))._build();

  _$CompiledRouteSegment._(
      {required this.segmentId,
      this.sessionId,
      required this.startedAt,
      required this.endedAt,
      required this.distanceM,
      required this.rawPointCount,
      required this.simplifiedPointCount,
      this.geometry})
      : super._();
  @override
  CompiledRouteSegment rebuild(
          void Function(CompiledRouteSegmentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompiledRouteSegmentBuilder toBuilder() =>
      CompiledRouteSegmentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompiledRouteSegment &&
        segmentId == other.segmentId &&
        sessionId == other.sessionId &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        distanceM == other.distanceM &&
        rawPointCount == other.rawPointCount &&
        simplifiedPointCount == other.simplifiedPointCount &&
        geometry == other.geometry;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, segmentId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, rawPointCount.hashCode);
    _$hash = $jc(_$hash, simplifiedPointCount.hashCode);
    _$hash = $jc(_$hash, geometry.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompiledRouteSegment')
          ..add('segmentId', segmentId)
          ..add('sessionId', sessionId)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('distanceM', distanceM)
          ..add('rawPointCount', rawPointCount)
          ..add('simplifiedPointCount', simplifiedPointCount)
          ..add('geometry', geometry))
        .toString();
  }
}

class CompiledRouteSegmentBuilder
    implements Builder<CompiledRouteSegment, CompiledRouteSegmentBuilder> {
  _$CompiledRouteSegment? _$v;

  String? _segmentId;
  String? get segmentId => _$this._segmentId;
  set segmentId(String? segmentId) => _$this._segmentId = segmentId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  num? _distanceM;
  num? get distanceM => _$this._distanceM;
  set distanceM(num? distanceM) => _$this._distanceM = distanceM;

  int? _rawPointCount;
  int? get rawPointCount => _$this._rawPointCount;
  set rawPointCount(int? rawPointCount) =>
      _$this._rawPointCount = rawPointCount;

  int? _simplifiedPointCount;
  int? get simplifiedPointCount => _$this._simplifiedPointCount;
  set simplifiedPointCount(int? simplifiedPointCount) =>
      _$this._simplifiedPointCount = simplifiedPointCount;

  MapBuilder<String, JsonObject?>? _geometry;
  MapBuilder<String, JsonObject?> get geometry =>
      _$this._geometry ??= MapBuilder<String, JsonObject?>();
  set geometry(MapBuilder<String, JsonObject?>? geometry) =>
      _$this._geometry = geometry;

  CompiledRouteSegmentBuilder() {
    CompiledRouteSegment._defaults(this);
  }

  CompiledRouteSegmentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _segmentId = $v.segmentId;
      _sessionId = $v.sessionId;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _distanceM = $v.distanceM;
      _rawPointCount = $v.rawPointCount;
      _simplifiedPointCount = $v.simplifiedPointCount;
      _geometry = $v.geometry?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompiledRouteSegment other) {
    _$v = other as _$CompiledRouteSegment;
  }

  @override
  void update(void Function(CompiledRouteSegmentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompiledRouteSegment build() => _build();

  _$CompiledRouteSegment _build() {
    _$CompiledRouteSegment _$result;
    try {
      _$result = _$v ??
          _$CompiledRouteSegment._(
            segmentId: BuiltValueNullFieldError.checkNotNull(
                segmentId, r'CompiledRouteSegment', 'segmentId'),
            sessionId: sessionId,
            startedAt: BuiltValueNullFieldError.checkNotNull(
                startedAt, r'CompiledRouteSegment', 'startedAt'),
            endedAt: BuiltValueNullFieldError.checkNotNull(
                endedAt, r'CompiledRouteSegment', 'endedAt'),
            distanceM: BuiltValueNullFieldError.checkNotNull(
                distanceM, r'CompiledRouteSegment', 'distanceM'),
            rawPointCount: BuiltValueNullFieldError.checkNotNull(
                rawPointCount, r'CompiledRouteSegment', 'rawPointCount'),
            simplifiedPointCount: BuiltValueNullFieldError.checkNotNull(
                simplifiedPointCount,
                r'CompiledRouteSegment',
                'simplifiedPointCount'),
            geometry: _geometry?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'geometry';
        _geometry?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompiledRouteSegment', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
