//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'story_mute_response.g.dart';

/// StoryMuteResponse
///
/// Properties:
/// * [mutedAuthorId] 
/// * [muted] 
@BuiltValue()
abstract class StoryMuteResponse implements Built<StoryMuteResponse, StoryMuteResponseBuilder> {
  @BuiltValueField(wireName: r'muted_author_id')
  String get mutedAuthorId;

  @BuiltValueField(wireName: r'muted')
  bool get muted;

  StoryMuteResponse._();

  factory StoryMuteResponse([void updates(StoryMuteResponseBuilder b)]) = _$StoryMuteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StoryMuteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StoryMuteResponse> get serializer => _$StoryMuteResponseSerializer();
}

class _$StoryMuteResponseSerializer implements PrimitiveSerializer<StoryMuteResponse> {
  @override
  final Iterable<Type> types = const [StoryMuteResponse, _$StoryMuteResponse];

  @override
  final String wireName = r'StoryMuteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StoryMuteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'muted_author_id';
    yield serializers.serialize(
      object.mutedAuthorId,
      specifiedType: const FullType(String),
    );
    yield r'muted';
    yield serializers.serialize(
      object.muted,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StoryMuteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StoryMuteResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'muted_author_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mutedAuthorId = valueDes;
          break;
        case r'muted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.muted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StoryMuteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StoryMuteResponseBuilder();
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

