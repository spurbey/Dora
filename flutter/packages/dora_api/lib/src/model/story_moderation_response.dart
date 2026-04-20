//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'story_moderation_response.g.dart';

/// StoryModerationResponse
///
/// Properties:
/// * [storyId] 
/// * [status] 
@BuiltValue()
abstract class StoryModerationResponse implements Built<StoryModerationResponse, StoryModerationResponseBuilder> {
  @BuiltValueField(wireName: r'story_id')
  String get storyId;

  @BuiltValueField(wireName: r'status')
  String get status;

  StoryModerationResponse._();

  factory StoryModerationResponse([void updates(StoryModerationResponseBuilder b)]) = _$StoryModerationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StoryModerationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StoryModerationResponse> get serializer => _$StoryModerationResponseSerializer();
}

class _$StoryModerationResponseSerializer implements PrimitiveSerializer<StoryModerationResponse> {
  @override
  final Iterable<Type> types = const [StoryModerationResponse, _$StoryModerationResponse];

  @override
  final String wireName = r'StoryModerationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StoryModerationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'story_id';
    yield serializers.serialize(
      object.storyId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StoryModerationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StoryModerationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'story_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storyId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StoryModerationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StoryModerationResponseBuilder();
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

