//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_create.g.dart';

/// Route creation schema.  Must include valid GeoJSON LineString.
///
/// Properties:
/// * [name] 
/// * [description] 
/// * [transportMode] 
/// * [routeCategory] 
/// * [startPlaceId] 
/// * [endPlaceId] 
/// * [orderInTrip] 
/// * [routeGeojson] - Must be valid GeoJSON LineString
@BuiltValue()
abstract class RouteCreate implements Built<RouteCreate, RouteCreateBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'transport_mode')
  RouteCreateTransportModeEnum get transportMode;
  // enum transportModeEnum {  car,  bike,  foot,  air,  bus,  train,  };

  @BuiltValueField(wireName: r'route_category')
  RouteCreateRouteCategoryEnum get routeCategory;
  // enum routeCategoryEnum {  ground,  air,  };

  @BuiltValueField(wireName: r'start_place_id')
  String? get startPlaceId;

  @BuiltValueField(wireName: r'end_place_id')
  String? get endPlaceId;

  @BuiltValueField(wireName: r'order_in_trip')
  int? get orderInTrip;

  /// Must be valid GeoJSON LineString
  @BuiltValueField(wireName: r'route_geojson')
  JsonObject get routeGeojson;

  RouteCreate._();

  factory RouteCreate([void updates(RouteCreateBuilder b)]) = _$RouteCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteCreateBuilder b) => b
      ..orderInTrip = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteCreate> get serializer => _$RouteCreateSerializer();
}

class _$RouteCreateSerializer implements PrimitiveSerializer<RouteCreate> {
  @override
  final Iterable<Type> types = const [RouteCreate, _$RouteCreate];

  @override
  final String wireName = r'RouteCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'transport_mode';
    yield serializers.serialize(
      object.transportMode,
      specifiedType: const FullType(RouteCreateTransportModeEnum),
    );
    yield r'route_category';
    yield serializers.serialize(
      object.routeCategory,
      specifiedType: const FullType(RouteCreateRouteCategoryEnum),
    );
    if (object.startPlaceId != null) {
      yield r'start_place_id';
      yield serializers.serialize(
        object.startPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.endPlaceId != null) {
      yield r'end_place_id';
      yield serializers.serialize(
        object.endPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.orderInTrip != null) {
      yield r'order_in_trip';
      yield serializers.serialize(
        object.orderInTrip,
        specifiedType: const FullType(int),
      );
    }
    yield r'route_geojson';
    yield serializers.serialize(
      object.routeGeojson,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'transport_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RouteCreateTransportModeEnum),
          ) as RouteCreateTransportModeEnum;
          result.transportMode = valueDes;
          break;
        case r'route_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RouteCreateRouteCategoryEnum),
          ) as RouteCreateRouteCategoryEnum;
          result.routeCategory = valueDes;
          break;
        case r'start_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.startPlaceId = valueDes;
          break;
        case r'end_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.endPlaceId = valueDes;
          break;
        case r'order_in_trip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.orderInTrip = valueDes;
          break;
        case r'route_geojson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.routeGeojson = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteCreateBuilder();
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

class RouteCreateTransportModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'car')
  static const RouteCreateTransportModeEnum car = _$routeCreateTransportModeEnum_car;
  @BuiltValueEnumConst(wireName: r'bike')
  static const RouteCreateTransportModeEnum bike = _$routeCreateTransportModeEnum_bike;
  @BuiltValueEnumConst(wireName: r'foot')
  static const RouteCreateTransportModeEnum foot = _$routeCreateTransportModeEnum_foot;
  @BuiltValueEnumConst(wireName: r'air')
  static const RouteCreateTransportModeEnum air = _$routeCreateTransportModeEnum_air;
  @BuiltValueEnumConst(wireName: r'bus')
  static const RouteCreateTransportModeEnum bus = _$routeCreateTransportModeEnum_bus;
  @BuiltValueEnumConst(wireName: r'train')
  static const RouteCreateTransportModeEnum train = _$routeCreateTransportModeEnum_train;

  static Serializer<RouteCreateTransportModeEnum> get serializer => _$routeCreateTransportModeEnumSerializer;

  const RouteCreateTransportModeEnum._(String name): super(name);

  static BuiltSet<RouteCreateTransportModeEnum> get values => _$routeCreateTransportModeEnumValues;
  static RouteCreateTransportModeEnum valueOf(String name) => _$routeCreateTransportModeEnumValueOf(name);
}

class RouteCreateRouteCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ground')
  static const RouteCreateRouteCategoryEnum ground = _$routeCreateRouteCategoryEnum_ground;
  @BuiltValueEnumConst(wireName: r'air')
  static const RouteCreateRouteCategoryEnum air = _$routeCreateRouteCategoryEnum_air;

  static Serializer<RouteCreateRouteCategoryEnum> get serializer => _$routeCreateRouteCategoryEnumSerializer;

  const RouteCreateRouteCategoryEnum._(String name): super(name);

  static BuiltSet<RouteCreateRouteCategoryEnum> get values => _$routeCreateRouteCategoryEnumValues;
  static RouteCreateRouteCategoryEnum valueOf(String name) => _$routeCreateRouteCategoryEnumValueOf(name);
}

