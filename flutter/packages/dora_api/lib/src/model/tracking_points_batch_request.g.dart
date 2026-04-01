// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_points_batch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingPointsBatchRequest extends TrackingPointsBatchRequest {
  @override
  final String sessionId;
  @override
  final String clientBatchId;
  @override
  final DateTime sentAt;
  @override
  final BuiltList<TrackingPointInput>? points;

  factory _$TrackingPointsBatchRequest(
          [void Function(TrackingPointsBatchRequestBuilder)? updates]) =>
      (TrackingPointsBatchRequestBuilder()..update(updates))._build();

  _$TrackingPointsBatchRequest._(
      {required this.sessionId,
      required this.clientBatchId,
      required this.sentAt,
      this.points})
      : super._();
  @override
  TrackingPointsBatchRequest rebuild(
          void Function(TrackingPointsBatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingPointsBatchRequestBuilder toBuilder() =>
      TrackingPointsBatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingPointsBatchRequest &&
        sessionId == other.sessionId &&
        clientBatchId == other.clientBatchId &&
        sentAt == other.sentAt &&
        points == other.points;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, clientBatchId.hashCode);
    _$hash = $jc(_$hash, sentAt.hashCode);
    _$hash = $jc(_$hash, points.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingPointsBatchRequest')
          ..add('sessionId', sessionId)
          ..add('clientBatchId', clientBatchId)
          ..add('sentAt', sentAt)
          ..add('points', points))
        .toString();
  }
}

class TrackingPointsBatchRequestBuilder
    implements
        Builder<TrackingPointsBatchRequest, TrackingPointsBatchRequestBuilder> {
  _$TrackingPointsBatchRequest? _$v;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _clientBatchId;
  String? get clientBatchId => _$this._clientBatchId;
  set clientBatchId(String? clientBatchId) =>
      _$this._clientBatchId = clientBatchId;

  DateTime? _sentAt;
  DateTime? get sentAt => _$this._sentAt;
  set sentAt(DateTime? sentAt) => _$this._sentAt = sentAt;

  ListBuilder<TrackingPointInput>? _points;
  ListBuilder<TrackingPointInput> get points =>
      _$this._points ??= ListBuilder<TrackingPointInput>();
  set points(ListBuilder<TrackingPointInput>? points) =>
      _$this._points = points;

  TrackingPointsBatchRequestBuilder() {
    TrackingPointsBatchRequest._defaults(this);
  }

  TrackingPointsBatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionId = $v.sessionId;
      _clientBatchId = $v.clientBatchId;
      _sentAt = $v.sentAt;
      _points = $v.points?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingPointsBatchRequest other) {
    _$v = other as _$TrackingPointsBatchRequest;
  }

  @override
  void update(void Function(TrackingPointsBatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingPointsBatchRequest build() => _build();

  _$TrackingPointsBatchRequest _build() {
    _$TrackingPointsBatchRequest _$result;
    try {
      _$result = _$v ??
          _$TrackingPointsBatchRequest._(
            sessionId: BuiltValueNullFieldError.checkNotNull(
                sessionId, r'TrackingPointsBatchRequest', 'sessionId'),
            clientBatchId: BuiltValueNullFieldError.checkNotNull(
                clientBatchId, r'TrackingPointsBatchRequest', 'clientBatchId'),
            sentAt: BuiltValueNullFieldError.checkNotNull(
                sentAt, r'TrackingPointsBatchRequest', 'sentAt'),
            points: _points?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'points';
        _points?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingPointsBatchRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
