// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_event_rejected_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingEventRejectedResponse extends TrackingEventRejectedResponse {
  @override
  final String? clientEventId;
  @override
  final String reasonCode;
  @override
  final String message;

  factory _$TrackingEventRejectedResponse(
          [void Function(TrackingEventRejectedResponseBuilder)? updates]) =>
      (TrackingEventRejectedResponseBuilder()..update(updates))._build();

  _$TrackingEventRejectedResponse._(
      {this.clientEventId, required this.reasonCode, required this.message})
      : super._();
  @override
  TrackingEventRejectedResponse rebuild(
          void Function(TrackingEventRejectedResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingEventRejectedResponseBuilder toBuilder() =>
      TrackingEventRejectedResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingEventRejectedResponse &&
        clientEventId == other.clientEventId &&
        reasonCode == other.reasonCode &&
        message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingEventRejectedResponse')
          ..add('clientEventId', clientEventId)
          ..add('reasonCode', reasonCode)
          ..add('message', message))
        .toString();
  }
}

class TrackingEventRejectedResponseBuilder
    implements
        Builder<TrackingEventRejectedResponse,
            TrackingEventRejectedResponseBuilder> {
  _$TrackingEventRejectedResponse? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  TrackingEventRejectedResponseBuilder() {
    TrackingEventRejectedResponse._defaults(this);
  }

  TrackingEventRejectedResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _reasonCode = $v.reasonCode;
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingEventRejectedResponse other) {
    _$v = other as _$TrackingEventRejectedResponse;
  }

  @override
  void update(void Function(TrackingEventRejectedResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingEventRejectedResponse build() => _build();

  _$TrackingEventRejectedResponse _build() {
    final _$result = _$v ??
        _$TrackingEventRejectedResponse._(
          clientEventId: clientEventId,
          reasonCode: BuiltValueNullFieldError.checkNotNull(
              reasonCode, r'TrackingEventRejectedResponse', 'reasonCode'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'TrackingEventRejectedResponse', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
