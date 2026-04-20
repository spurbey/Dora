//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/conversation_message_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'send_message_response.g.dart';

/// SendMessageResponse
///
/// Properties:
/// * [message] 
/// * [jobId] 
@BuiltValue()
abstract class SendMessageResponse implements Built<SendMessageResponse, SendMessageResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  ConversationMessageResponse get message;

  @BuiltValueField(wireName: r'job_id')
  String get jobId;

  SendMessageResponse._();

  factory SendMessageResponse([void updates(SendMessageResponseBuilder b)]) = _$SendMessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SendMessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SendMessageResponse> get serializer => _$SendMessageResponseSerializer();
}

class _$SendMessageResponseSerializer implements PrimitiveSerializer<SendMessageResponse> {
  @override
  final Iterable<Type> types = const [SendMessageResponse, _$SendMessageResponse];

  @override
  final String wireName = r'SendMessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SendMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(ConversationMessageResponse),
    );
    yield r'job_id';
    yield serializers.serialize(
      object.jobId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SendMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SendMessageResponseBuilder result,
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
        case r'job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.jobId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SendMessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SendMessageResponseBuilder();
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

