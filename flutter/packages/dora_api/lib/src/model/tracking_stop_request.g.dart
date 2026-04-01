// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_stop_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingStopRequest extends TrackingStopRequest {
  @override
  final String clientEventId;
  @override
  final String? sessionId;
  @override
  final DateTime stoppedAt;
  @override
  final String? reason;

  factory _$TrackingStopRequest(
          [void Function(TrackingStopRequestBuilder)? updates]) =>
      (TrackingStopRequestBuilder()..update(updates))._build();

  _$TrackingStopRequest._(
      {required this.clientEventId,
      this.sessionId,
      required this.stoppedAt,
      this.reason})
      : super._();
  @override
  TrackingStopRequest rebuild(
          void Function(TrackingStopRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingStopRequestBuilder toBuilder() =>
      TrackingStopRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingStopRequest &&
        clientEventId == other.clientEventId &&
        sessionId == other.sessionId &&
        stoppedAt == other.stoppedAt &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, stoppedAt.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingStopRequest')
          ..add('clientEventId', clientEventId)
          ..add('sessionId', sessionId)
          ..add('stoppedAt', stoppedAt)
          ..add('reason', reason))
        .toString();
  }
}

class TrackingStopRequestBuilder
    implements Builder<TrackingStopRequest, TrackingStopRequestBuilder> {
  _$TrackingStopRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  DateTime? _stoppedAt;
  DateTime? get stoppedAt => _$this._stoppedAt;
  set stoppedAt(DateTime? stoppedAt) => _$this._stoppedAt = stoppedAt;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  TrackingStopRequestBuilder() {
    TrackingStopRequest._defaults(this);
  }

  TrackingStopRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _sessionId = $v.sessionId;
      _stoppedAt = $v.stoppedAt;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingStopRequest other) {
    _$v = other as _$TrackingStopRequest;
  }

  @override
  void update(void Function(TrackingStopRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingStopRequest build() => _build();

  _$TrackingStopRequest _build() {
    final _$result = _$v ??
        _$TrackingStopRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'TrackingStopRequest', 'clientEventId'),
          sessionId: sessionId,
          stoppedAt: BuiltValueNullFieldError.checkNotNull(
              stoppedAt, r'TrackingStopRequest', 'stoppedAt'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
