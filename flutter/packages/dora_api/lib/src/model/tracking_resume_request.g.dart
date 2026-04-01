// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_resume_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingResumeRequest extends TrackingResumeRequest {
  @override
  final String clientEventId;
  @override
  final String? sessionId;
  @override
  final DateTime resumedAt;

  factory _$TrackingResumeRequest(
          [void Function(TrackingResumeRequestBuilder)? updates]) =>
      (TrackingResumeRequestBuilder()..update(updates))._build();

  _$TrackingResumeRequest._(
      {required this.clientEventId, this.sessionId, required this.resumedAt})
      : super._();
  @override
  TrackingResumeRequest rebuild(
          void Function(TrackingResumeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingResumeRequestBuilder toBuilder() =>
      TrackingResumeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingResumeRequest &&
        clientEventId == other.clientEventId &&
        sessionId == other.sessionId &&
        resumedAt == other.resumedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, resumedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingResumeRequest')
          ..add('clientEventId', clientEventId)
          ..add('sessionId', sessionId)
          ..add('resumedAt', resumedAt))
        .toString();
  }
}

class TrackingResumeRequestBuilder
    implements Builder<TrackingResumeRequest, TrackingResumeRequestBuilder> {
  _$TrackingResumeRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  DateTime? _resumedAt;
  DateTime? get resumedAt => _$this._resumedAt;
  set resumedAt(DateTime? resumedAt) => _$this._resumedAt = resumedAt;

  TrackingResumeRequestBuilder() {
    TrackingResumeRequest._defaults(this);
  }

  TrackingResumeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _sessionId = $v.sessionId;
      _resumedAt = $v.resumedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingResumeRequest other) {
    _$v = other as _$TrackingResumeRequest;
  }

  @override
  void update(void Function(TrackingResumeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingResumeRequest build() => _build();

  _$TrackingResumeRequest _build() {
    final _$result = _$v ??
        _$TrackingResumeRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'TrackingResumeRequest', 'clientEventId'),
          sessionId: sessionId,
          resumedAt: BuiltValueNullFieldError.checkNotNull(
              resumedAt, r'TrackingResumeRequest', 'resumedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
