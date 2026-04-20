//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_message_response.g.dart';

/// ConversationMessageResponse
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [userId] 
/// * [role] 
/// * [messageType] 
/// * [content] 
/// * [messageMetadata] 
/// * [advisoryJobId] 
/// * [advisoryId] 
/// * [createdAt] 
@BuiltValue()
abstract class ConversationMessageResponse implements Built<ConversationMessageResponse, ConversationMessageResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'role')
  String get role;

  @BuiltValueField(wireName: r'message_type')
  String get messageType;

  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'message_metadata')
  JsonObject? get messageMetadata;

  @BuiltValueField(wireName: r'advisory_job_id')
  String? get advisoryJobId;

  @BuiltValueField(wireName: r'advisory_id')
  String? get advisoryId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  ConversationMessageResponse._();

  factory ConversationMessageResponse([void updates(ConversationMessageResponseBuilder b)]) = _$ConversationMessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConversationMessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConversationMessageResponse> get serializer => _$ConversationMessageResponseSerializer();
}

class _$ConversationMessageResponseSerializer implements PrimitiveSerializer<ConversationMessageResponse> {
  @override
  final Iterable<Type> types = const [ConversationMessageResponse, _$ConversationMessageResponse];

  @override
  final String wireName = r'ConversationMessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConversationMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(String),
    );
    yield r'message_type';
    yield serializers.serialize(
      object.messageType,
      specifiedType: const FullType(String),
    );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.messageMetadata != null) {
      yield r'message_metadata';
      yield serializers.serialize(
        object.messageMetadata,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.advisoryJobId != null) {
      yield r'advisory_job_id';
      yield serializers.serialize(
        object.advisoryJobId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.advisoryId != null) {
      yield r'advisory_id';
      yield serializers.serialize(
        object.advisoryId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConversationMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConversationMessageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.role = valueDes;
          break;
        case r'message_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.messageType = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.content = valueDes;
          break;
        case r'message_metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.messageMetadata = valueDes;
          break;
        case r'advisory_job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.advisoryJobId = valueDes;
          break;
        case r'advisory_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.advisoryId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConversationMessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConversationMessageResponseBuilder();
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

