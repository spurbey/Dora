//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/place_response.dart';
import 'package:dora_api/src/model/route_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'trip_component_detail_response.g.dart';

/// Full component details with polymorphic data.  Returns the component metadata plus the full entity data (either place_data OR route_data, never both).  Example:     For a place component:     {         \"id\": \"uuid\",         \"component_type\": \"place\",         \"order_in_trip\": 2,         \"place_data\": {...full PlaceResponse...},         \"route_data\": null     }      For a route component:     {         \"id\": \"uuid\",         \"component_type\": \"route\",         \"order_in_trip\": 3,         \"place_data\": null,         \"route_data\": {...full RouteResponse...}     }
///
/// Properties:
/// * [id] 
/// * [componentType] 
/// * [orderInTrip] 
/// * [placeData] 
/// * [routeData] 
@BuiltValue()
abstract class TripComponentDetailResponse implements Built<TripComponentDetailResponse, TripComponentDetailResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'component_type')
  TripComponentDetailResponseComponentTypeEnum get componentType;
  // enum componentTypeEnum {  place,  route,  };

  @BuiltValueField(wireName: r'order_in_trip')
  int get orderInTrip;

  @BuiltValueField(wireName: r'place_data')
  PlaceResponse? get placeData;

  @BuiltValueField(wireName: r'route_data')
  RouteResponse? get routeData;

  TripComponentDetailResponse._();

  factory TripComponentDetailResponse([void updates(TripComponentDetailResponseBuilder b)]) = _$TripComponentDetailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TripComponentDetailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TripComponentDetailResponse> get serializer => _$TripComponentDetailResponseSerializer();
}

class _$TripComponentDetailResponseSerializer implements PrimitiveSerializer<TripComponentDetailResponse> {
  @override
  final Iterable<Type> types = const [TripComponentDetailResponse, _$TripComponentDetailResponse];

  @override
  final String wireName = r'TripComponentDetailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TripComponentDetailResponse object, {
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
      specifiedType: const FullType(TripComponentDetailResponseComponentTypeEnum),
    );
    yield r'order_in_trip';
    yield serializers.serialize(
      object.orderInTrip,
      specifiedType: const FullType(int),
    );
    if (object.placeData != null) {
      yield r'place_data';
      yield serializers.serialize(
        object.placeData,
        specifiedType: const FullType.nullable(PlaceResponse),
      );
    }
    if (object.routeData != null) {
      yield r'route_data';
      yield serializers.serialize(
        object.routeData,
        specifiedType: const FullType.nullable(RouteResponse),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TripComponentDetailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TripComponentDetailResponseBuilder result,
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
            specifiedType: const FullType(TripComponentDetailResponseComponentTypeEnum),
          ) as TripComponentDetailResponseComponentTypeEnum;
          result.componentType = valueDes;
          break;
        case r'order_in_trip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.orderInTrip = valueDes;
          break;
        case r'place_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(PlaceResponse),
          ) as PlaceResponse?;
          if (valueDes == null) continue;
          result.placeData.replace(valueDes);
          break;
        case r'route_data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteResponse),
          ) as RouteResponse?;
          if (valueDes == null) continue;
          result.routeData.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TripComponentDetailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TripComponentDetailResponseBuilder();
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

class TripComponentDetailResponseComponentTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'place')
  static const TripComponentDetailResponseComponentTypeEnum place = _$tripComponentDetailResponseComponentTypeEnum_place;
  @BuiltValueEnumConst(wireName: r'route')
  static const TripComponentDetailResponseComponentTypeEnum route = _$tripComponentDetailResponseComponentTypeEnum_route;

  static Serializer<TripComponentDetailResponseComponentTypeEnum> get serializer => _$tripComponentDetailResponseComponentTypeEnumSerializer;

  const TripComponentDetailResponseComponentTypeEnum._(String name): super(name);

  static BuiltSet<TripComponentDetailResponseComponentTypeEnum> get values => _$tripComponentDetailResponseComponentTypeEnumValues;
  static TripComponentDetailResponseComponentTypeEnum valueOf(String name) => _$tripComponentDetailResponseComponentTypeEnumValueOf(name);
}

