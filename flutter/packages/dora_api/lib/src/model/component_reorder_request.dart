//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/component_reorder_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'component_reorder_request.g.dart';

/// Bulk reorder request.  The service will normalize the order to sequential integers (0,1,2,3...) regardless of input values. You can send [5,2,8] and it will become [0,1,2].  Example:     {         \"items\": [             {\"id\": \"place-uuid\", \"component_type\": \"place\", \"new_order\": 2},             {\"id\": \"route-uuid\", \"component_type\": \"route\", \"new_order\": 0},             {\"id\": \"place-uuid-2\", \"component_type\": \"place\", \"new_order\": 1}         ]     }      After normalization, the order will be: route(0), place-2(1), place(2)
///
/// Properties:
/// * [items] 
@BuiltValue()
abstract class ComponentReorderRequest implements Built<ComponentReorderRequest, ComponentReorderRequestBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ComponentReorderItem> get items;

  ComponentReorderRequest._();

  factory ComponentReorderRequest([void updates(ComponentReorderRequestBuilder b)]) = _$ComponentReorderRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ComponentReorderRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ComponentReorderRequest> get serializer => _$ComponentReorderRequestSerializer();
}

class _$ComponentReorderRequestSerializer implements PrimitiveSerializer<ComponentReorderRequest> {
  @override
  final Iterable<Type> types = const [ComponentReorderRequest, _$ComponentReorderRequest];

  @override
  final String wireName = r'ComponentReorderRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ComponentReorderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ComponentReorderItem)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ComponentReorderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ComponentReorderRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ComponentReorderItem)]),
          ) as BuiltList<ComponentReorderItem>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ComponentReorderRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ComponentReorderRequestBuilder();
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

