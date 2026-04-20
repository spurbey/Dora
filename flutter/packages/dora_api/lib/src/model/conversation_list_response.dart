//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/conversation_message_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_list_response.g.dart';

/// ConversationListResponse
///
/// Properties:
/// * [messages] 
/// * [hasMore] 
@BuiltValue()
abstract class ConversationListResponse implements Built<ConversationListResponse, ConversationListResponseBuilder> {
  @BuiltValueField(wireName: r'messages')
  BuiltList<ConversationMessageResponse> get messages;

  @BuiltValueField(wireName: r'has_more')
  bool? get hasMore;

  ConversationListResponse._();

  factory ConversationListResponse([void updates(ConversationListResponseBuilder b)]) = _$ConversationListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConversationListResponseBuilder b) => b
      ..hasMore = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConversationListResponse> get serializer => _$ConversationListResponseSerializer();
}

class _$ConversationListResponseSerializer implements PrimitiveSerializer<ConversationListResponse> {
  @override
  final Iterable<Type> types = const [ConversationListResponse, _$ConversationListResponse];

  @override
  final String wireName = r'ConversationListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConversationListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'messages';
    yield serializers.serialize(
      object.messages,
      specifiedType: const FullType(BuiltList, [FullType(ConversationMessageResponse)]),
    );
    if (object.hasMore != null) {
      yield r'has_more';
      yield serializers.serialize(
        object.hasMore,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ConversationListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConversationListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'messages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ConversationMessageResponse)]),
          ) as BuiltList<ConversationMessageResponse>;
          result.messages.replace(valueDes);
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConversationListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConversationListResponseBuilder();
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

