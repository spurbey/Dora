// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_question_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AnswerQuestionRequest extends AnswerQuestionRequest {
  @override
  final String questionMessageId;
  @override
  final String answer;
  @override
  final JsonObject? metadata;

  factory _$AnswerQuestionRequest(
          [void Function(AnswerQuestionRequestBuilder)? updates]) =>
      (AnswerQuestionRequestBuilder()..update(updates))._build();

  _$AnswerQuestionRequest._(
      {required this.questionMessageId, required this.answer, this.metadata})
      : super._();
  @override
  AnswerQuestionRequest rebuild(
          void Function(AnswerQuestionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AnswerQuestionRequestBuilder toBuilder() =>
      AnswerQuestionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AnswerQuestionRequest &&
        questionMessageId == other.questionMessageId &&
        answer == other.answer &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, questionMessageId.hashCode);
    _$hash = $jc(_$hash, answer.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AnswerQuestionRequest')
          ..add('questionMessageId', questionMessageId)
          ..add('answer', answer)
          ..add('metadata', metadata))
        .toString();
  }
}

class AnswerQuestionRequestBuilder
    implements Builder<AnswerQuestionRequest, AnswerQuestionRequestBuilder> {
  _$AnswerQuestionRequest? _$v;

  String? _questionMessageId;
  String? get questionMessageId => _$this._questionMessageId;
  set questionMessageId(String? questionMessageId) =>
      _$this._questionMessageId = questionMessageId;

  String? _answer;
  String? get answer => _$this._answer;
  set answer(String? answer) => _$this._answer = answer;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  AnswerQuestionRequestBuilder() {
    AnswerQuestionRequest._defaults(this);
  }

  AnswerQuestionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _questionMessageId = $v.questionMessageId;
      _answer = $v.answer;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AnswerQuestionRequest other) {
    _$v = other as _$AnswerQuestionRequest;
  }

  @override
  void update(void Function(AnswerQuestionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AnswerQuestionRequest build() => _build();

  _$AnswerQuestionRequest _build() {
    final _$result = _$v ??
        _$AnswerQuestionRequest._(
          questionMessageId: BuiltValueNullFieldError.checkNotNull(
              questionMessageId, r'AnswerQuestionRequest', 'questionMessageId'),
          answer: BuiltValueNullFieldError.checkNotNull(
              answer, r'AnswerQuestionRequest', 'answer'),
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
