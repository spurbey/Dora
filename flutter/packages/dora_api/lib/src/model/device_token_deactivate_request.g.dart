// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_deactivate_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceTokenDeactivateRequest extends DeviceTokenDeactivateRequest {
  @override
  final String clientEventId;
  @override
  final String pushToken;
  @override
  final DateTime deactivatedAt;

  factory _$DeviceTokenDeactivateRequest(
          [void Function(DeviceTokenDeactivateRequestBuilder)? updates]) =>
      (DeviceTokenDeactivateRequestBuilder()..update(updates))._build();

  _$DeviceTokenDeactivateRequest._(
      {required this.clientEventId,
      required this.pushToken,
      required this.deactivatedAt})
      : super._();
  @override
  DeviceTokenDeactivateRequest rebuild(
          void Function(DeviceTokenDeactivateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceTokenDeactivateRequestBuilder toBuilder() =>
      DeviceTokenDeactivateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceTokenDeactivateRequest &&
        clientEventId == other.clientEventId &&
        pushToken == other.pushToken &&
        deactivatedAt == other.deactivatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, pushToken.hashCode);
    _$hash = $jc(_$hash, deactivatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceTokenDeactivateRequest')
          ..add('clientEventId', clientEventId)
          ..add('pushToken', pushToken)
          ..add('deactivatedAt', deactivatedAt))
        .toString();
  }
}

class DeviceTokenDeactivateRequestBuilder
    implements
        Builder<DeviceTokenDeactivateRequest,
            DeviceTokenDeactivateRequestBuilder> {
  _$DeviceTokenDeactivateRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _pushToken;
  String? get pushToken => _$this._pushToken;
  set pushToken(String? pushToken) => _$this._pushToken = pushToken;

  DateTime? _deactivatedAt;
  DateTime? get deactivatedAt => _$this._deactivatedAt;
  set deactivatedAt(DateTime? deactivatedAt) =>
      _$this._deactivatedAt = deactivatedAt;

  DeviceTokenDeactivateRequestBuilder() {
    DeviceTokenDeactivateRequest._defaults(this);
  }

  DeviceTokenDeactivateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _pushToken = $v.pushToken;
      _deactivatedAt = $v.deactivatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceTokenDeactivateRequest other) {
    _$v = other as _$DeviceTokenDeactivateRequest;
  }

  @override
  void update(void Function(DeviceTokenDeactivateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceTokenDeactivateRequest build() => _build();

  _$DeviceTokenDeactivateRequest _build() {
    final _$result = _$v ??
        _$DeviceTokenDeactivateRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'DeviceTokenDeactivateRequest', 'clientEventId'),
          pushToken: BuiltValueNullFieldError.checkNotNull(
              pushToken, r'DeviceTokenDeactivateRequest', 'pushToken'),
          deactivatedAt: BuiltValueNullFieldError.checkNotNull(
              deactivatedAt, r'DeviceTokenDeactivateRequest', 'deactivatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
