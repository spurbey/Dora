//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_component_response.g.dart';

/// Lightweight timeline item for list views.  Use this for displaying the unified timeline without full entity details.
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [componentType] 
/// * [name] 
/// * [orderInTrip] 
/// * [createdAt] 
@BuiltValue()
abstract class TripComponentResponse implements Built<TripComponentResponse, TripComponentResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'component_type')
  TripComponentResponseComponentTypeEnum get componentType;
  // enum componentTypeEnum {  place,  route,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'order_in_trip')
  int get orderInTrip;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  TripComponentResponse._();

  factory TripComponentResponse([void updates(TripComponentResponseBuilder b)]) = _$TripComponentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripComponentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripComponentResponse> get serializer => _$TripComponentResponseSerializer();
}

class _$TripComponentResponseSerializer implements PrimitiveSerializer<TripComponentResponse> {
  @override
  final Iterable<Type> types = const [TripComponentResponse, _$TripComponentResponse];

  @override
  final String wireName = r'TripComponentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripComponentResponse object, {
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
    yield r'component_type';
    yield serializers.serialize(
      object.componentType,
      specifiedType: const FullType(TripComponentResponseComponentTypeEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'order_in_trip';
    yield serializers.serialize(
      object.orderInTrip,
      specifiedType: const FullType(int),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TripComponentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripComponentResponseBuilder result,
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
        case r'component_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TripComponentResponseComponentTypeEnum),
          ) as TripComponentResponseComponentTypeEnum;
          result.componentType = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'order_in_trip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.orderInTrip = valueDes;
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
  TripComponentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripComponentResponseBuilder();
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

class TripComponentResponseComponentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'place')
  static const TripComponentResponseComponentTypeEnum place = _$tripComponentResponseComponentTypeEnum_place;
  @BuiltValueEnumConst(wireName: r'route')
  static const TripComponentResponseComponentTypeEnum route = _$tripComponentResponseComponentTypeEnum_route;

  static Serializer<TripComponentResponseComponentTypeEnum> get serializer => _$tripComponentResponseComponentTypeEnumSerializer;

  const TripComponentResponseComponentTypeEnum._(String name): super(name);

  static BuiltSet<TripComponentResponseComponentTypeEnum> get values => _$tripComponentResponseComponentTypeEnumValues;
  static TripComponentResponseComponentTypeEnum valueOf(String name) => _$tripComponentResponseComponentTypeEnumValueOf(name);
}

