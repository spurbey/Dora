// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SendMessageResponse extends SendMessageResponse {
  @override
  final ConversationMessageResponse message;
  @override
  final String jobId;

  factory _$SendMessageResponse(
          [void Function(SendMessageResponseBuilder)? updates]) =>
      (SendMessageResponseBuilder()..update(updates))._build();

  _$SendMessageResponse._({required this.message, required this.jobId})
      : super._();
  @override
  SendMessageResponse rebuild(
          void Function(SendMessageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SendMessageResponseBuilder toBuilder() =>
      SendMessageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SendMessageResponse &&
        message == other.message &&
        jobId == other.jobId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SendMessageResponse')
          ..add('message', message)
          ..add('jobId', jobId))
        .toString();
  }
}

class SendMessageResponseBuilder
    implements Builder<SendMessageResponse, SendMessageResponseBuilder> {
  _$SendMessageResponse? _$v;

  ConversationMessageResponseBuilder? _message;
  ConversationMessageResponseBuilder get message =>
      _$this._message ??= ConversationMessageResponseBuilder();
  set message(ConversationMessageResponseBuilder? message) =>
      _$this._message = message;

  String? _jobId;
  String? get jobId => _$this._jobId;
  set jobId(String? jobId) => _$this._jobId = jobId;

  SendMessageResponseBuilder() {
    SendMessageResponse._defaults(this);
  }

  SendMessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message.toBuilder();
      _jobId = $v.jobId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SendMessageResponse other) {
    _$v = other as _$SendMessageResponse;
  }

  @override
  void update(void Function(SendMessageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SendMessageResponse build() => _build();

  _$SendMessageResponse _build() {
    _$SendMessageResponse _$result;
    try {
      _$result = _$v ??
          _$SendMessageResponse._(
            message: message.build(),
            jobId: BuiltValueNullFieldError.checkNotNull(
                jobId, r'SendMessageResponse', 'jobId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SendMessageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
