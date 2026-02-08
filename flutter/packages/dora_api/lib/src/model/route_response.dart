//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_response.g.dart';

/// Route response schema.
///
/// Properties:
/// * [name] 
/// * [description] 
/// * [transportMode] 
/// * [routeCategory] 
/// * [startPlaceId] 
/// * [endPlaceId] 
/// * [orderInTrip] 
/// * [id] 
/// * [tripId] 
/// * [userId] 
/// * [routeGeojson] 
/// * [polylineEncoded] 
/// * [distanceKm] 
/// * [durationMins] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class RouteResponse implements Built<RouteResponse, RouteResponseBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'transport_mode')
  RouteResponseTransportModeEnum get transportMode;
  // enum transportModeEnum {  car,  bike,  foot,  air,  bus,  train,  };

  @BuiltValueField(wireName: r'route_category')
  RouteResponseRouteCategoryEnum get routeCategory;
  // enum routeCategoryEnum {  ground,  air,  };

  @BuiltValueField(wireName: r'start_place_id')
  String? get startPlaceId;

  @BuiltValueField(wireName: r'end_place_id')
  String? get endPlaceId;

  @BuiltValueField(wireName: r'order_in_trip')
  int? get orderInTrip;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'route_geojson')
  JsonObject get routeGeojson;

  @BuiltValueField(wireName: r'polyline_encoded')
  String? get polylineEncoded;

  @BuiltValueField(wireName: r'distance_km')
  num? get distanceKm;

  @BuiltValueField(wireName: r'duration_mins')
  int? get durationMins;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  RouteResponse._();

  factory RouteResponse([void updates(RouteResponseBuilder b)]) = _$RouteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteResponseBuilder b) => b
      ..orderInTrip = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteResponse> get serializer => _$RouteResponseSerializer();
}

class _$RouteResponseSerializer implements PrimitiveSerializer<RouteResponse> {
  @override
  final Iterable<Type> types = const [RouteResponse, _$RouteResponse];

  @override
  final String wireName = r'RouteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteResponse object, {
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
      specifiedType: const FullType(RouteResponseTransportModeEnum),
    );
    yield r'route_category';
    yield serializers.serialize(
      object.routeCategory,
      specifiedType: const FullType(RouteResponseRouteCategoryEnum),
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
    yield r'route_geojson';
    yield serializers.serialize(
      object.routeGeojson,
      specifiedType: const FullType(JsonObject),
    );
    if (object.polylineEncoded != null) {
      yield r'polyline_encoded';
      yield serializers.serialize(
        object.polylineEncoded,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.distanceKm != null) {
      yield r'distance_km';
      yield serializers.serialize(
        object.distanceKm,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.durationMins != null) {
      yield r'duration_mins';
      yield serializers.serialize(
        object.durationMins,
        specifiedType: const FullType.nullable(int),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteResponseBuilder result,
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
            specifiedType: const FullType(RouteResponseTransportModeEnum),
          ) as RouteResponseTransportModeEnum;
          result.transportMode = valueDes;
          break;
        case r'route_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RouteResponseRouteCategoryEnum),
          ) as RouteResponseRouteCategoryEnum;
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
        case r'route_geojson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.routeGeojson = valueDes;
          break;
        case r'polyline_encoded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.polylineEncoded = valueDes;
          break;
        case r'distance_km':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.distanceKm = valueDes;
          break;
        case r'duration_mins':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.durationMins = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteResponseBuilder();
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

class RouteResponseTransportModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'car')
  static const RouteResponseTransportModeEnum car = _$routeResponseTransportModeEnum_car;
  @BuiltValueEnumConst(wireName: r'bike')
  static const RouteResponseTransportModeEnum bike = _$routeResponseTransportModeEnum_bike;
  @BuiltValueEnumConst(wireName: r'foot')
  static const RouteResponseTransportModeEnum foot = _$routeResponseTransportModeEnum_foot;
  @BuiltValueEnumConst(wireName: r'air')
  static const RouteResponseTransportModeEnum air = _$routeResponseTransportModeEnum_air;
  @BuiltValueEnumConst(wireName: r'bus')
  static const RouteResponseTransportModeEnum bus = _$routeResponseTransportModeEnum_bus;
  @BuiltValueEnumConst(wireName: r'train')
  static const RouteResponseTransportModeEnum train = _$routeResponseTransportModeEnum_train;

  static Serializer<RouteResponseTransportModeEnum> get serializer => _$routeResponseTransportModeEnumSerializer;

  const RouteResponseTransportModeEnum._(String name): super(name);

  static BuiltSet<RouteResponseTransportModeEnum> get values => _$routeResponseTransportModeEnumValues;
  static RouteResponseTransportModeEnum valueOf(String name) => _$routeResponseTransportModeEnumValueOf(name);
}

class RouteResponseRouteCategoryEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'ground')
  static const RouteResponseRouteCategoryEnum ground = _$routeResponseRouteCategoryEnum_ground;
  @BuiltValueEnumConst(wireName: r'air')
  static const RouteResponseRouteCategoryEnum air = _$routeResponseRouteCategoryEnum_air;

  static Serializer<RouteResponseRouteCategoryEnum> get serializer => _$routeResponseRouteCategoryEnumSerializer;

  const RouteResponseRouteCategoryEnum._(String name): super(name);

  static BuiltSet<RouteResponseRouteCategoryEnum> get values => _$routeResponseRouteCategoryEnumValues;
  static RouteResponseRouteCategoryEnum valueOf(String name) => _$routeResponseRouteCategoryEnumValueOf(name);
}

