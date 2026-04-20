//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/conversation_message_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'answer_question_response.g.dart';

/// AnswerQuestionResponse
///
/// Properties:
/// * [message] 
/// * [resumedJobId] 
@BuiltValue()
abstract class AnswerQuestionResponse implements Built<AnswerQuestionResponse, AnswerQuestionResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  ConversationMessageResponse get message;

  @BuiltValueField(wireName: r'resumed_job_id')
  String get resumedJobId;

  AnswerQuestionResponse._();

  factory AnswerQuestionResponse([void updates(AnswerQuestionResponseBuilder b)]) = _$AnswerQuestionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AnswerQuestionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AnswerQuestionResponse> get serializer => _$AnswerQuestionResponseSerializer();
}

class _$AnswerQuestionResponseSerializer implements PrimitiveSerializer<AnswerQuestionResponse> {
  @override
  final Iterable<Type> types = const [AnswerQuestionResponse, _$AnswerQuestionResponse];

  @override
  final String wireName = r'AnswerQuestionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AnswerQuestionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(ConversationMessageResponse),
    );
    yield r'resumed_job_id';
    yield serializers.serialize(
      object.resumedJobId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AnswerQuestionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AnswerQuestionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConversationMessageResponse),
          ) as ConversationMessageResponse;
          result.message.replace(valueDes);
          break;
        case r'resumed_job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resumedJobId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AnswerQuestionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AnswerQuestionResponseBuilder();
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

