//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'answer_question_request.g.dart';

/// AnswerQuestionRequest
///
/// Properties:
/// * [questionMessageId] 
/// * [answer] 
/// * [metadata] 
@BuiltValue()
abstract class AnswerQuestionRequest implements Built<AnswerQuestionRequest, AnswerQuestionRequestBuilder> {
  @BuiltValueField(wireName: r'question_message_id')
  String get questionMessageId;

  @BuiltValueField(wireName: r'answer')
  String get answer;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  AnswerQuestionRequest._();

  factory AnswerQuestionRequest([void updates(AnswerQuestionRequestBuilder b)]) = _$AnswerQuestionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnswerQuestionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnswerQuestionRequest> get serializer => _$AnswerQuestionRequestSerializer();
}

class _$AnswerQuestionRequestSerializer implements PrimitiveSerializer<AnswerQuestionRequest> {
  @override
  final Iterable<Type> types = const [AnswerQuestionRequest, _$AnswerQuestionRequest];

  @override
  final String wireName = r'AnswerQuestionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnswerQuestionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'question_message_id';
    yield serializers.serialize(
      object.questionMessageId,
      specifiedType: const FullType(String),
    );
    yield r'answer';
    yield serializers.serialize(
      object.answer,
      specifiedType: const FullType(String),
    );
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AnswerQuestionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnswerQuestionRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'question_message_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.questionMessageId = valueDes;
          break;
        case r'answer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.answer = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.metadata = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnswerQuestionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnswerQuestionRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

