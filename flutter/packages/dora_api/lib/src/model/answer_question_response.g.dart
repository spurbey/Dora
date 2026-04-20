// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_question_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AnswerQuestionResponse extends AnswerQuestionResponse {
  @override
  final ConversationMessageResponse message;
  @override
  final String resumedJobId;

  factory _$AnswerQuestionResponse(
          [void Function(AnswerQuestionResponseBuilder)? updates]) =>
      (AnswerQuestionResponseBuilder()..update(updates))._build();

  _$AnswerQuestionResponse._(
      {required this.message, required this.resumedJobId})
      : super._();
  @override
  AnswerQuestionResponse rebuild(
          void Function(AnswerQuestionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AnswerQuestionResponseBuilder toBuilder() =>
      AnswerQuestionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AnswerQuestionResponse &&
        message == other.message &&
        resumedJobId == other.resumedJobId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, resumedJobId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AnswerQuestionResponse')
          ..add('message', message)
          ..add('resumedJobId', resumedJobId))
        .toString();
  }
}

class AnswerQuestionResponseBuilder
    implements Builder<AnswerQuestionResponse, AnswerQuestionResponseBuilder> {
  _$AnswerQuestionResponse? _$v;

  ConversationMessageResponseBuilder? _message;
  ConversationMessageResponseBuilder get message =>
      _$this._message ??= ConversationMessageResponseBuilder();
  set message(ConversationMessageResponseBuilder? message) =>
      _$this._message = message;

  String? _resumedJobId;
  String? get resumedJobId => _$this._resumedJobId;
  set resumedJobId(String? resumedJobId) => _$this._resumedJobId = resumedJobId;

  AnswerQuestionResponseBuilder() {
    AnswerQuestionResponse._defaults(this);
  }

  AnswerQuestionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message.toBuilder();
      _resumedJobId = $v.resumedJobId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AnswerQuestionResponse other) {
    _$v = other as _$AnswerQuestionResponse;
  }

  @override
  void update(void Function(AnswerQuestionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AnswerQuestionResponse build() => _build();

  _$AnswerQuestionResponse _build() {
    _$AnswerQuestionResponse _$result;
    try {
      _$result = _$v ??
          _$AnswerQuestionResponse._(
            message: message.build(),
            resumedJobId: BuiltValueNullFieldError.checkNotNull(
                resumedJobId, r'AnswerQuestionResponse', 'resumedJobId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'message';
        message.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AnswerQuestionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
