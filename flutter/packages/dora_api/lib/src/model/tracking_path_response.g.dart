// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_path_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingPathResponse extends TrackingPathResponse {
  @override
  final String tripId;
  @override
  final String sessionId;
  @override
  final int pointsCount;
  @override
  final BuiltList<TrackingPathPointResponse> points;

  factory _$TrackingPathResponse(
          [void Function(TrackingPathResponseBuilder)? updates]) =>
      (TrackingPathResponseBuilder()..update(updates))._build();

  _$TrackingPathResponse._(
      {required this.tripId,
      required this.sessionId,
      required this.pointsCount,
      required this.points})
      : super._();
  @override
  TrackingPathResponse rebuild(
          void Function(TrackingPathResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingPathResponseBuilder toBuilder() =>
      TrackingPathResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingPathResponse &&
        tripId == other.tripId &&
        sessionId == other.sessionId &&
        pointsCount == other.pointsCount &&
        points == other.points;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, pointsCount.hashCode);
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingPathResponse')
          ..add('tripId', tripId)
          ..add('sessionId', sessionId)
          ..add('pointsCount', pointsCount)
          ..add('points', points))
        .toString();
  }
}

class TrackingPathResponseBuilder
    implements Builder<TrackingPathResponse, TrackingPathResponseBuilder> {
  _$TrackingPathResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  int? _pointsCount;
  int? get pointsCount => _$this._pointsCount;
  set pointsCount(int? pointsCount) => _$this._pointsCount = pointsCount;

  ListBuilder<TrackingPathPointResponse>? _points;
  ListBuilder<TrackingPathPointResponse> get points =>
      _$this._points ??= ListBuilder<TrackingPathPointResponse>();
  set points(ListBuilder<TrackingPathPointResponse>? points) =>
      _$this._points = points;

  TrackingPathResponseBuilder() {
    TrackingPathResponse._defaults(this);
  }

  TrackingPathResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _sessionId = $v.sessionId;
      _pointsCount = $v.pointsCount;
      _points = $v.points.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingPathResponse other) {
    _$v = other as _$TrackingPathResponse;
  }

  @override
  void update(void Function(TrackingPathResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingPathResponse build() => _build();

  _$TrackingPathResponse _build() {
    _$TrackingPathResponse _$result;
    try {
      _$result = _$v ??
          _$TrackingPathResponse._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TrackingPathResponse', 'tripId'),
            sessionId: BuiltValueNullFieldError.checkNotNull(
                sessionId, r'TrackingPathResponse', 'sessionId'),
            pointsCount: BuiltValueNullFieldError.checkNotNull(
                pointsCount, r'TrackingPathResponse', 'pointsCount'),
            points: points.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'points';
        points.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingPathResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
