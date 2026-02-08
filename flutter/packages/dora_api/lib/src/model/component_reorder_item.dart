//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'component_reorder_item.g.dart';

/// Single item in bulk reorder request.
///
/// Properties:
/// * [id] 
/// * [componentType] 
/// * [newOrder] - New order position (will be normalized)
@BuiltValue()
abstract class ComponentReorderItem implements Built<ComponentReorderItem, ComponentReorderItemBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'component_type')
  ComponentReorderItemComponentTypeEnum get componentType;
  // enum componentTypeEnum {  place,  route,  };

  /// New order position (will be normalized)
  @BuiltValueField(wireName: r'new_order')
  int get newOrder;

  ComponentReorderItem._();

  factory ComponentReorderItem([void updates(ComponentReorderItemBuilder b)]) = _$ComponentReorderItem;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ComponentReorderItemBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ComponentReorderItem> get serializer => _$ComponentReorderItemSerializer();
}

class _$ComponentReorderItemSerializer implements PrimitiveSerializer<ComponentReorderItem> {
  @override
  final Iterable<Type> types = const [ComponentReorderItem, _$ComponentReorderItem];

  @override
  final String wireName = r'ComponentReorderItem';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ComponentReorderItem object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'component_type';
    yield serializers.serialize(
      object.componentType,
      specifiedType: const FullType(ComponentReorderItemComponentTypeEnum),
    );
    yield r'new_order';
    yield serializers.serialize(
      object.newOrder,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ComponentReorderItem object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ComponentReorderItemBuilder result,
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
        case r'component_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ComponentReorderItemComponentTypeEnum),
          ) as ComponentReorderItemComponentTypeEnum;
          result.componentType = valueDes;
          break;
        case r'new_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.newOrder = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ComponentReorderItem deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ComponentReorderItemBuilder();
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

class ComponentReorderItemComponentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'place')
  static const ComponentReorderItemComponentTypeEnum place = _$componentReorderItemComponentTypeEnum_place;
  @BuiltValueEnumConst(wireName: r'route')
  static const ComponentReorderItemComponentTypeEnum route = _$componentReorderItemComponentTypeEnum_route;

  static Serializer<ComponentReorderItemComponentTypeEnum> get serializer => _$componentReorderItemComponentTypeEnumSerializer;

  const ComponentReorderItemComponentTypeEnum._(String name): super(name);

  static BuiltSet<ComponentReorderItemComponentTypeEnum> get values => _$componentReorderItemComponentTypeEnumValues;
  static ComponentReorderItemComponentTypeEnum valueOf(String name) => _$componentReorderItemComponentTypeEnumValueOf(name);
}

