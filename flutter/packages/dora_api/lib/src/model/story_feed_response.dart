//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/story_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'story_feed_response.g.dart';

/// StoryFeedResponse
///
/// Properties:
/// * [stories] 
/// * [nextCursor] 
@BuiltValue()
abstract class StoryFeedResponse implements Built<StoryFeedResponse, StoryFeedResponseBuilder> {
  @BuiltValueField(wireName: r'stories')
  BuiltList<StoryResponse> get stories;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  StoryFeedResponse._();

  factory StoryFeedResponse([void updates(StoryFeedResponseBuilder b)]) = _$StoryFeedResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StoryFeedResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StoryFeedResponse> get serializer => _$StoryFeedResponseSerializer();
}

class _$StoryFeedResponseSerializer implements PrimitiveSerializer<StoryFeedResponse> {
  @override
  final Iterable<Type> types = const [StoryFeedResponse, _$StoryFeedResponse];

  @override
  final String wireName = r'StoryFeedResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StoryFeedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'stories';
    yield serializers.serialize(
      object.stories,
      specifiedType: const FullType(BuiltList, [FullType(StoryResponse)]),
    );
    if (object.nextCursor != null) {
      yield r'next_cursor';
      yield serializers.serialize(
        object.nextCursor,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StoryFeedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StoryFeedResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(StoryResponse)]),
          ) as BuiltList<StoryResponse>;
          result.stories.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StoryFeedResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StoryFeedResponseBuilder();
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

