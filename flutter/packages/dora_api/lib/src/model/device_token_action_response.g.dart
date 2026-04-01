// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_action_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceTokenActionResponse extends DeviceTokenActionResponse {
  @override
  final DeviceTokenResponse token;
  @override
  final bool idempotencyReplayed;

  factory _$DeviceTokenActionResponse(
          [void Function(DeviceTokenActionResponseBuilder)? updates]) =>
      (DeviceTokenActionResponseBuilder()..update(updates))._build();

  _$DeviceTokenActionResponse._(
      {required this.token, required this.idempotencyReplayed})
      : super._();
  @override
  DeviceTokenActionResponse rebuild(
          void Function(DeviceTokenActionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceTokenActionResponseBuilder toBuilder() =>
      DeviceTokenActionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceTokenActionResponse &&
        token == other.token &&
        idempotencyReplayed == other.idempotencyReplayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, idempotencyReplayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceTokenActionResponse')
          ..add('token', token)
          ..add('idempotencyReplayed', idempotencyReplayed))
        .toString();
  }
}

class DeviceTokenActionResponseBuilder
    implements
        Builder<DeviceTokenActionResponse, DeviceTokenActionResponseBuilder> {
  _$DeviceTokenActionResponse? _$v;

  DeviceTokenResponseBuilder? _token;
  DeviceTokenResponseBuilder get token =>
      _$this._token ??= DeviceTokenResponseBuilder();
  set token(DeviceTokenResponseBuilder? token) => _$this._token = token;

  bool? _idempotencyReplayed;
  bool? get idempotencyReplayed => _$this._idempotencyReplayed;
  set idempotencyReplayed(bool? idempotencyReplayed) =>
      _$this._idempotencyReplayed = idempotencyReplayed;

  DeviceTokenActionResponseBuilder() {
    DeviceTokenActionResponse._defaults(this);
  }

  DeviceTokenActionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token.toBuilder();
      _idempotencyReplayed = $v.idempotencyReplayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceTokenActionResponse other) {
    _$v = other as _$DeviceTokenActionResponse;
  }

  @override
  void update(void Function(DeviceTokenActionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceTokenActionResponse build() => _build();

  _$DeviceTokenActionResponse _build() {
    _$DeviceTokenActionResponse _$result;
    try {
      _$result = _$v ??
          _$DeviceTokenActionResponse._(
            token: token.build(),
            idempotencyReplayed: BuiltValueNullFieldError.checkNotNull(
                idempotencyReplayed,
                r'DeviceTokenActionResponse',
                'idempotencyReplayed'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'token';
        token.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DeviceTokenActionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
