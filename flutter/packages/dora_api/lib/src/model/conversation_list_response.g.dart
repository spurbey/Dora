// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationListResponse extends ConversationListResponse {
  @override
  final BuiltList<ConversationMessageResponse> messages;
  @override
  final bool? hasMore;

  factory _$ConversationListResponse(
          [void Function(ConversationListResponseBuilder)? updates]) =>
      (ConversationListResponseBuilder()..update(updates))._build();

  _$ConversationListResponse._({required this.messages, this.hasMore})
      : super._();
  @override
  ConversationListResponse rebuild(
          void Function(ConversationListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationListResponseBuilder toBuilder() =>
      ConversationListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationListResponse &&
        messages == other.messages &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, messages.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConversationListResponse')
          ..add('messages', messages)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class ConversationListResponseBuilder
    implements
        Builder<ConversationListResponse, ConversationListResponseBuilder> {
  _$ConversationListResponse? _$v;

  ListBuilder<ConversationMessageResponse>? _messages;
  ListBuilder<ConversationMessageResponse> get messages =>
      _$this._messages ??= ListBuilder<ConversationMessageResponse>();
  set messages(ListBuilder<ConversationMessageResponse>? messages) =>
      _$this._messages = messages;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ConversationListResponseBuilder() {
    ConversationListResponse._defaults(this);
  }

  ConversationListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _messages = $v.messages.toBuilder();
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationListResponse other) {
    _$v = other as _$ConversationListResponse;
  }

  @override
  void update(void Function(ConversationListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationListResponse build() => _build();

  _$ConversationListResponse _build() {
    _$ConversationListResponse _$result;
    try {
      _$result = _$v ??
          _$ConversationListResponse._(
            messages: messages.build(),
            hasMore: hasMore,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'messages';
        messages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConversationListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
