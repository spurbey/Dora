// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SendMessageRequest extends SendMessageRequest {
  @override
  final String content;
  @override
  final String? replyToMessageId;

  factory _$SendMessageRequest(
          [void Function(SendMessageRequestBuilder)? updates]) =>
      (SendMessageRequestBuilder()..update(updates))._build();

  _$SendMessageRequest._({required this.content, this.replyToMessageId})
      : super._();
  @override
  SendMessageRequest rebuild(
          void Function(SendMessageRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SendMessageRequestBuilder toBuilder() =>
      SendMessageRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SendMessageRequest &&
        content == other.content &&
        replyToMessageId == other.replyToMessageId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, replyToMessageId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SendMessageRequest')
          ..add('content', content)
          ..add('replyToMessageId', replyToMessageId))
        .toString();
  }
}

class SendMessageRequestBuilder
    implements Builder<SendMessageRequest, SendMessageRequestBuilder> {
  _$SendMessageRequest? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _replyToMessageId;
  String? get replyToMessageId => _$this._replyToMessageId;
  set replyToMessageId(String? replyToMessageId) =>
      _$this._replyToMessageId = replyToMessageId;

  SendMessageRequestBuilder() {
    SendMessageRequest._defaults(this);
  }

  SendMessageRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _replyToMessageId = $v.replyToMessageId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SendMessageRequest other) {
    _$v = other as _$SendMessageRequest;
  }

  @override
  void update(void Function(SendMessageRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SendMessageRequest build() => _build();

  _$SendMessageRequest _build() {
    final _$result = _$v ??
        _$SendMessageRequest._(
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'SendMessageRequest', 'content'),
          replyToMessageId: replyToMessageId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
