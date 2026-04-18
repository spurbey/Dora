// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_session_start_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2SessionStartRequest extends V2SessionStartRequest {
  @override
  final String clientSessionId;
  @override
  final DateTime startedAt;
  @override
  final String? timezone;
  @override
  final JsonObject? deviceContext;

  factory _$V2SessionStartRequest(
          [void Function(V2SessionStartRequestBuilder)? updates]) =>
      (V2SessionStartRequestBuilder()..update(updates))._build();

  _$V2SessionStartRequest._(
      {required this.clientSessionId,
      required this.startedAt,
      this.timezone,
      this.deviceContext})
      : super._();
  @override
  V2SessionStartRequest rebuild(
          void Function(V2SessionStartRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2SessionStartRequestBuilder toBuilder() =>
      V2SessionStartRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2SessionStartRequest &&
        clientSessionId == other.clientSessionId &&
        startedAt == other.startedAt &&
        timezone == other.timezone &&
        deviceContext == other.deviceContext;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientSessionId.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, deviceContext.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2SessionStartRequest')
          ..add('clientSessionId', clientSessionId)
          ..add('startedAt', startedAt)
          ..add('timezone', timezone)
          ..add('deviceContext', deviceContext))
        .toString();
  }
}

class V2SessionStartRequestBuilder
    implements Builder<V2SessionStartRequest, V2SessionStartRequestBuilder> {
  _$V2SessionStartRequest? _$v;

  String? _clientSessionId;
  String? get clientSessionId => _$this._clientSessionId;
  set clientSessionId(String? clientSessionId) =>
      _$this._clientSessionId = clientSessionId;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  JsonObject? _deviceContext;
  JsonObject? get deviceContext => _$this._deviceContext;
  set deviceContext(JsonObject? deviceContext) =>
      _$this._deviceContext = deviceContext;

  V2SessionStartRequestBuilder() {
    V2SessionStartRequest._defaults(this);
  }

  V2SessionStartRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientSessionId = $v.clientSessionId;
      _startedAt = $v.startedAt;
      _timezone = $v.timezone;
      _deviceContext = $v.deviceContext;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2SessionStartRequest other) {
    _$v = other as _$V2SessionStartRequest;
  }

  @override
  void update(void Function(V2SessionStartRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2SessionStartRequest build() => _build();

  _$V2SessionStartRequest _build() {
    final _$result = _$v ??
        _$V2SessionStartRequest._(
          clientSessionId: BuiltValueNullFieldError.checkNotNull(
              clientSessionId, r'V2SessionStartRequest', 'clientSessionId'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'V2SessionStartRequest', 'startedAt'),
          timezone: timezone,
          deviceContext: deviceContext,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
