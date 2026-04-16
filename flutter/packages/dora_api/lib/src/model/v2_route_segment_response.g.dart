// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_route_segment_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2RouteSegmentResponse extends V2RouteSegmentResponse {
  @override
  final String segmentKey;
  @override
  final String sessionServerId;
  @override
  final DateTime startedAt;
  @override
  final DateTime endedAt;
  @override
  final int pointCount;
  @override
  final int rawPointCount;
  @override
  final bool isSimplified;
  @override
  final BuiltList<V2RoutePointResponse>? points;

  factory _$V2RouteSegmentResponse(
          [void Function(V2RouteSegmentResponseBuilder)? updates]) =>
      (V2RouteSegmentResponseBuilder()..update(updates))._build();

  _$V2RouteSegmentResponse._(
      {required this.segmentKey,
      required this.sessionServerId,
      required this.startedAt,
      required this.endedAt,
      required this.pointCount,
      required this.rawPointCount,
      required this.isSimplified,
      this.points})
      : super._();
  @override
  V2RouteSegmentResponse rebuild(
          void Function(V2RouteSegmentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2RouteSegmentResponseBuilder toBuilder() =>
      V2RouteSegmentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2RouteSegmentResponse &&
        segmentKey == other.segmentKey &&
        sessionServerId == other.sessionServerId &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        pointCount == other.pointCount &&
        rawPointCount == other.rawPointCount &&
        isSimplified == other.isSimplified &&
        points == other.points;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, segmentKey.hashCode);
    _$hash = $jc(_$hash, sessionServerId.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, pointCount.hashCode);
    _$hash = $jc(_$hash, rawPointCount.hashCode);
    _$hash = $jc(_$hash, isSimplified.hashCode);
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2RouteSegmentResponse')
          ..add('segmentKey', segmentKey)
          ..add('sessionServerId', sessionServerId)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('pointCount', pointCount)
          ..add('rawPointCount', rawPointCount)
          ..add('isSimplified', isSimplified)
          ..add('points', points))
        .toString();
  }
}

class V2RouteSegmentResponseBuilder
    implements Builder<V2RouteSegmentResponse, V2RouteSegmentResponseBuilder> {
  _$V2RouteSegmentResponse? _$v;

  String? _segmentKey;
  String? get segmentKey => _$this._segmentKey;
  set segmentKey(String? segmentKey) => _$this._segmentKey = segmentKey;

  String? _sessionServerId;
  String? get sessionServerId => _$this._sessionServerId;
  set sessionServerId(String? sessionServerId) =>
      _$this._sessionServerId = sessionServerId;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  int? _pointCount;
  int? get pointCount => _$this._pointCount;
  set pointCount(int? pointCount) => _$this._pointCount = pointCount;

  int? _rawPointCount;
  int? get rawPointCount => _$this._rawPointCount;
  set rawPointCount(int? rawPointCount) =>
      _$this._rawPointCount = rawPointCount;

  bool? _isSimplified;
  bool? get isSimplified => _$this._isSimplified;
  set isSimplified(bool? isSimplified) => _$this._isSimplified = isSimplified;

  ListBuilder<V2RoutePointResponse>? _points;
  ListBuilder<V2RoutePointResponse> get points =>
      _$this._points ??= ListBuilder<V2RoutePointResponse>();
  set points(ListBuilder<V2RoutePointResponse>? points) =>
      _$this._points = points;

  V2RouteSegmentResponseBuilder() {
    V2RouteSegmentResponse._defaults(this);
  }

  V2RouteSegmentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _segmentKey = $v.segmentKey;
      _sessionServerId = $v.sessionServerId;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _pointCount = $v.pointCount;
      _rawPointCount = $v.rawPointCount;
      _isSimplified = $v.isSimplified;
      _points = $v.points?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2RouteSegmentResponse other) {
    _$v = other as _$V2RouteSegmentResponse;
  }

  @override
  void update(void Function(V2RouteSegmentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2RouteSegmentResponse build() => _build();

  _$V2RouteSegmentResponse _build() {
    _$V2RouteSegmentResponse _$result;
    try {
      _$result = _$v ??
          _$V2RouteSegmentResponse._(
            segmentKey: BuiltValueNullFieldError.checkNotNull(
                segmentKey, r'V2RouteSegmentResponse', 'segmentKey'),
            sessionServerId: BuiltValueNullFieldError.checkNotNull(
                sessionServerId, r'V2RouteSegmentResponse', 'sessionServerId'),
            startedAt: BuiltValueNullFieldError.checkNotNull(
                startedAt, r'V2RouteSegmentResponse', 'startedAt'),
            endedAt: BuiltValueNullFieldError.checkNotNull(
                endedAt, r'V2RouteSegmentResponse', 'endedAt'),
            pointCount: BuiltValueNullFieldError.checkNotNull(
                pointCount, r'V2RouteSegmentResponse', 'pointCount'),
            rawPointCount: BuiltValueNullFieldError.checkNotNull(
                rawPointCount, r'V2RouteSegmentResponse', 'rawPointCount'),
            isSimplified: BuiltValueNullFieldError.checkNotNull(
                isSimplified, r'V2RouteSegmentResponse', 'isSimplified'),
            points: _points?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'points';
        _points?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'V2RouteSegmentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
