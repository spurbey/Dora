// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_start_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingStartRequest extends TrackingStartRequest {
  @override
  final String clientSessionId;
  @override
  final DateTime startedAt;
  @override
  final String? timezone;
  @override
  final BuiltMap<String, JsonObject?>? deviceContext;

  factory _$TrackingStartRequest(
          [void Function(TrackingStartRequestBuilder)? updates]) =>
      (TrackingStartRequestBuilder()..update(updates))._build();

  _$TrackingStartRequest._(
      {required this.clientSessionId,
      required this.startedAt,
      this.timezone,
      this.deviceContext})
      : super._();
  @override
  TrackingStartRequest rebuild(
          void Function(TrackingStartRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingStartRequestBuilder toBuilder() =>
      TrackingStartRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingStartRequest &&
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
    return (newBuiltValueToStringHelper(r'TrackingStartRequest')
          ..add('clientSessionId', clientSessionId)
          ..add('startedAt', startedAt)
          ..add('timezone', timezone)
          ..add('deviceContext', deviceContext))
        .toString();
  }
}

class TrackingStartRequestBuilder
    implements Builder<TrackingStartRequest, TrackingStartRequestBuilder> {
  _$TrackingStartRequest? _$v;

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

  MapBuilder<String, JsonObject?>? _deviceContext;
  MapBuilder<String, JsonObject?> get deviceContext =>
      _$this._deviceContext ??= MapBuilder<String, JsonObject?>();
  set deviceContext(MapBuilder<String, JsonObject?>? deviceContext) =>
      _$this._deviceContext = deviceContext;

  TrackingStartRequestBuilder() {
    TrackingStartRequest._defaults(this);
  }

  TrackingStartRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientSessionId = $v.clientSessionId;
      _startedAt = $v.startedAt;
      _timezone = $v.timezone;
      _deviceContext = $v.deviceContext?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingStartRequest other) {
    _$v = other as _$TrackingStartRequest;
  }

  @override
  void update(void Function(TrackingStartRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingStartRequest build() => _build();

  _$TrackingStartRequest _build() {
    _$TrackingStartRequest _$result;
    try {
      _$result = _$v ??
          _$TrackingStartRequest._(
            clientSessionId: BuiltValueNullFieldError.checkNotNull(
                clientSessionId, r'TrackingStartRequest', 'clientSessionId'),
            startedAt: BuiltValueNullFieldError.checkNotNull(
                startedAt, r'TrackingStartRequest', 'startedAt'),
            timezone: timezone,
            deviceContext: _deviceContext?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deviceContext';
        _deviceContext?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingStartRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
