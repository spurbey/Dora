// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_pause_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingPauseRequest extends TrackingPauseRequest {
  @override
  final String clientEventId;
  @override
  final String? sessionId;
  @override
  final DateTime pausedAt;
  @override
  final String? reason;

  factory _$TrackingPauseRequest(
          [void Function(TrackingPauseRequestBuilder)? updates]) =>
      (TrackingPauseRequestBuilder()..update(updates))._build();

  _$TrackingPauseRequest._(
      {required this.clientEventId,
      this.sessionId,
      required this.pausedAt,
      this.reason})
      : super._();
  @override
  TrackingPauseRequest rebuild(
          void Function(TrackingPauseRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingPauseRequestBuilder toBuilder() =>
      TrackingPauseRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingPauseRequest &&
        clientEventId == other.clientEventId &&
        sessionId == other.sessionId &&
        pausedAt == other.pausedAt &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, pausedAt.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingPauseRequest')
          ..add('clientEventId', clientEventId)
          ..add('sessionId', sessionId)
          ..add('pausedAt', pausedAt)
          ..add('reason', reason))
        .toString();
  }
}

class TrackingPauseRequestBuilder
    implements Builder<TrackingPauseRequest, TrackingPauseRequestBuilder> {
  _$TrackingPauseRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  DateTime? _pausedAt;
  DateTime? get pausedAt => _$this._pausedAt;
  set pausedAt(DateTime? pausedAt) => _$this._pausedAt = pausedAt;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  TrackingPauseRequestBuilder() {
    TrackingPauseRequest._defaults(this);
  }

  TrackingPauseRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _sessionId = $v.sessionId;
      _pausedAt = $v.pausedAt;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingPauseRequest other) {
    _$v = other as _$TrackingPauseRequest;
  }

  @override
  void update(void Function(TrackingPauseRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingPauseRequest build() => _build();

  _$TrackingPauseRequest _build() {
    final _$result = _$v ??
        _$TrackingPauseRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'TrackingPauseRequest', 'clientEventId'),
          sessionId: sessionId,
          pausedAt: BuiltValueNullFieldError.checkNotNull(
              pausedAt, r'TrackingPauseRequest', 'pausedAt'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
