//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'component_reorder_response.g.dart';

/// Response for reorder operation.
///
/// Properties:
/// * [message] 
/// * [updatedCount] 
@BuiltValue()
abstract class ComponentReorderResponse implements Built<ComponentReorderResponse, ComponentReorderResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'updated_count')
  int get updatedCount;

  ComponentReorderResponse._();

  factory ComponentReorderResponse([void updates(ComponentReorderResponseBuilder b)]) = _$ComponentReorderResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ComponentReorderResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ComponentReorderResponse> get serializer => _$ComponentReorderResponseSerializer();
}

class _$ComponentReorderResponseSerializer implements PrimitiveSerializer<ComponentReorderResponse> {
  @override
  final Iterable<Type> types = const [ComponentReorderResponse, _$ComponentReorderResponse];

  @override
  final String wireName = r'ComponentReorderResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ComponentReorderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'updated_count';
    yield serializers.serialize(
      object.updatedCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ComponentReorderResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ComponentReorderResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'updated_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.updatedCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ComponentReorderResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ComponentReorderResponseBuilder();
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

