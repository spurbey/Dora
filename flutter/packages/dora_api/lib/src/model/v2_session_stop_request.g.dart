// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_session_stop_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2SessionStopRequest extends V2SessionStopRequest {
  @override
  final int sealVersion;
  @override
  final String stopClientEventId;
  @override
  final DateTime stoppedAt;
  @override
  final String? reason;
  @override
  final String? clientSessionId;

  factory _$V2SessionStopRequest(
          [void Function(V2SessionStopRequestBuilder)? updates]) =>
      (V2SessionStopRequestBuilder()..update(updates))._build();

  _$V2SessionStopRequest._(
      {required this.sealVersion,
      required this.stopClientEventId,
      required this.stoppedAt,
      this.reason,
      this.clientSessionId})
      : super._();
  @override
  V2SessionStopRequest rebuild(
          void Function(V2SessionStopRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2SessionStopRequestBuilder toBuilder() =>
      V2SessionStopRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2SessionStopRequest &&
        sealVersion == other.sealVersion &&
        stopClientEventId == other.stopClientEventId &&
        stoppedAt == other.stoppedAt &&
        reason == other.reason &&
        clientSessionId == other.clientSessionId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sealVersion.hashCode);
    _$hash = $jc(_$hash, stopClientEventId.hashCode);
    _$hash = $jc(_$hash, stoppedAt.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, clientSessionId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2SessionStopRequest')
          ..add('sealVersion', sealVersion)
          ..add('stopClientEventId', stopClientEventId)
          ..add('stoppedAt', stoppedAt)
          ..add('reason', reason)
          ..add('clientSessionId', clientSessionId))
        .toString();
  }
}

class V2SessionStopRequestBuilder
    implements Builder<V2SessionStopRequest, V2SessionStopRequestBuilder> {
  _$V2SessionStopRequest? _$v;

  int? _sealVersion;
  int? get sealVersion => _$this._sealVersion;
  set sealVersion(int? sealVersion) => _$this._sealVersion = sealVersion;

  String? _stopClientEventId;
  String? get stopClientEventId => _$this._stopClientEventId;
  set stopClientEventId(String? stopClientEventId) =>
      _$this._stopClientEventId = stopClientEventId;

  DateTime? _stoppedAt;
  DateTime? get stoppedAt => _$this._stoppedAt;
  set stoppedAt(DateTime? stoppedAt) => _$this._stoppedAt = stoppedAt;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _clientSessionId;
  String? get clientSessionId => _$this._clientSessionId;
  set clientSessionId(String? clientSessionId) =>
      _$this._clientSessionId = clientSessionId;

  V2SessionStopRequestBuilder() {
    V2SessionStopRequest._defaults(this);
  }

  V2SessionStopRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sealVersion = $v.sealVersion;
      _stopClientEventId = $v.stopClientEventId;
      _stoppedAt = $v.stoppedAt;
      _reason = $v.reason;
      _clientSessionId = $v.clientSessionId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2SessionStopRequest other) {
    _$v = other as _$V2SessionStopRequest;
  }

  @override
  void update(void Function(V2SessionStopRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2SessionStopRequest build() => _build();

  _$V2SessionStopRequest _build() {
    final _$result = _$v ??
        _$V2SessionStopRequest._(
          sealVersion: BuiltValueNullFieldError.checkNotNull(
              sealVersion, r'V2SessionStopRequest', 'sealVersion'),
          stopClientEventId: BuiltValueNullFieldError.checkNotNull(
              stopClientEventId, r'V2SessionStopRequest', 'stopClientEventId'),
          stoppedAt: BuiltValueNullFieldError.checkNotNull(
              stoppedAt, r'V2SessionStopRequest', 'stoppedAt'),
          reason: reason,
          clientSessionId: clientSessionId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
