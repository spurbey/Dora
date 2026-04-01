// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_media_rejected_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingMediaRejectedResponse extends TrackingMediaRejectedResponse {
  @override
  final String? clientMediaId;
  @override
  final String reasonCode;
  @override
  final String message;

  factory _$TrackingMediaRejectedResponse(
          [void Function(TrackingMediaRejectedResponseBuilder)? updates]) =>
      (TrackingMediaRejectedResponseBuilder()..update(updates))._build();

  _$TrackingMediaRejectedResponse._(
      {this.clientMediaId, required this.reasonCode, required this.message})
      : super._();
  @override
  TrackingMediaRejectedResponse rebuild(
          void Function(TrackingMediaRejectedResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingMediaRejectedResponseBuilder toBuilder() =>
      TrackingMediaRejectedResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingMediaRejectedResponse &&
        clientMediaId == other.clientMediaId &&
        reasonCode == other.reasonCode &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingMediaRejectedResponse')
          ..add('clientMediaId', clientMediaId)
          ..add('reasonCode', reasonCode)
          ..add('message', message))
        .toString();
  }
}

class TrackingMediaRejectedResponseBuilder
    implements
        Builder<TrackingMediaRejectedResponse,
            TrackingMediaRejectedResponseBuilder> {
  _$TrackingMediaRejectedResponse? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  TrackingMediaRejectedResponseBuilder() {
    TrackingMediaRejectedResponse._defaults(this);
  }

  TrackingMediaRejectedResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _reasonCode = $v.reasonCode;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingMediaRejectedResponse other) {
    _$v = other as _$TrackingMediaRejectedResponse;
  }

  @override
  void update(void Function(TrackingMediaRejectedResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingMediaRejectedResponse build() => _build();

  _$TrackingMediaRejectedResponse _build() {
    final _$result = _$v ??
        _$TrackingMediaRejectedResponse._(
          clientMediaId: clientMediaId,
          reasonCode: BuiltValueNullFieldError.checkNotNull(
              reasonCode, r'TrackingMediaRejectedResponse', 'reasonCode'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'TrackingMediaRejectedResponse', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
