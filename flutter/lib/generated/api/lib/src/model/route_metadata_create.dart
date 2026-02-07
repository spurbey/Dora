//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/fuel_cost.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/toll_cost.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_metadata_create.g.dart';

/// Route metadata creation schema.  Used for POST /routes/{route_id}/metadata endpoint. route_id is taken from URL path parameter.
///
/// Properties:
/// * [routeQuality] 
/// * [roadCondition] 
/// * [scenicRating] 
/// * [safetyRating] 
/// * [soloSafe] 
/// * [fuelCost] 
/// * [tollCost] 
/// * [highlights] 
/// * [isPublic] 
@BuiltValue()
abstract class RouteMetadataCreate implements Built<RouteMetadataCreate, RouteMetadataCreateBuilder> {
  @BuiltValueField(wireName: r'route_quality')
  RouteMetadataCreateRouteQualityEnum? get routeQuality;
  // enum routeQualityEnum {  scenic,  fastest,  offbeat,  };

  @BuiltValueField(wireName: r'road_condition')
  RouteMetadataCreateRoadConditionEnum? get roadCondition;
  // enum roadConditionEnum {  excellent,  good,  poor,  offroad,  };

  @BuiltValueField(wireName: r'scenic_rating')
  int? get scenicRating;

  @BuiltValueField(wireName: r'safety_rating')
  int? get safetyRating;

  @BuiltValueField(wireName: r'solo_safe')
  bool? get soloSafe;

  @BuiltValueField(wireName: r'fuel_cost')
  FuelCost? get fuelCost;

  @BuiltValueField(wireName: r'toll_cost')
  TollCost? get tollCost;

  @BuiltValueField(wireName: r'highlights')
  BuiltList<String>? get highlights;

  @BuiltValueField(wireName: r'is_public')
  bool? get isPublic;

  RouteMetadataCreate._();

  factory RouteMetadataCreate([void updates(RouteMetadataCreateBuilder b)]) = _$RouteMetadataCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteMetadataCreateBuilder b) => b
      ..safetyRating = 3
      ..soloSafe = true
      ..isPublic = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteMetadataCreate> get serializer => _$RouteMetadataCreateSerializer();
}

class _$RouteMetadataCreateSerializer implements PrimitiveSerializer<RouteMetadataCreate> {
  @override
  final Iterable<Type> types = const [RouteMetadataCreate, _$RouteMetadataCreate];

  @override
  final String wireName = r'RouteMetadataCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteMetadataCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.routeQuality != null) {
      yield r'route_quality';
      yield serializers.serialize(
        object.routeQuality,
        specifiedType: const FullType.nullable(RouteMetadataCreateRouteQualityEnum),
      );
    }
    if (object.roadCondition != null) {
      yield r'road_condition';
      yield serializers.serialize(
        object.roadCondition,
        specifiedType: const FullType.nullable(RouteMetadataCreateRoadConditionEnum),
      );
    }
    if (object.scenicRating != null) {
      yield r'scenic_rating';
      yield serializers.serialize(
        object.scenicRating,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.safetyRating != null) {
      yield r'safety_rating';
      yield serializers.serialize(
        object.safetyRating,
        specifiedType: const FullType(int),
      );
    }
    if (object.soloSafe != null) {
      yield r'solo_safe';
      yield serializers.serialize(
        object.soloSafe,
        specifiedType: const FullType(bool),
      );
    }
    if (object.fuelCost != null) {
      yield r'fuel_cost';
      yield serializers.serialize(
        object.fuelCost,
        specifiedType: const FullType.nullable(FuelCost),
      );
    }
    if (object.tollCost != null) {
      yield r'toll_cost';
      yield serializers.serialize(
        object.tollCost,
        specifiedType: const FullType.nullable(TollCost),
      );
    }
    if (object.highlights != null) {
      yield r'highlights';
      yield serializers.serialize(
        object.highlights,
        specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
      );
    }
    if (object.isPublic != null) {
      yield r'is_public';
      yield serializers.serialize(
        object.isPublic,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteMetadataCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteMetadataCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'route_quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteMetadataCreateRouteQualityEnum),
          ) as RouteMetadataCreateRouteQualityEnum?;
          if (valueDes == null) continue;
          result.routeQuality = valueDes;
          break;
        case r'road_condition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteMetadataCreateRoadConditionEnum),
          ) as RouteMetadataCreateRoadConditionEnum?;
          if (valueDes == null) continue;
          result.roadCondition = valueDes;
          break;
        case r'scenic_rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.scenicRating = valueDes;
          break;
        case r'safety_rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.safetyRating = valueDes;
          break;
        case r'solo_safe':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soloSafe = valueDes;
          break;
        case r'fuel_cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(FuelCost),
          ) as FuelCost?;
          if (valueDes == null) continue;
          result.fuelCost.replace(valueDes);
          break;
        case r'toll_cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TollCost),
          ) as TollCost?;
          if (valueDes == null) continue;
          result.tollCost.replace(valueDes);
          break;
        case r'highlights':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(String)]),
          ) as BuiltList<String>?;
          if (valueDes == null) continue;
          result.highlights.replace(valueDes);
          break;
        case r'is_public':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPublic = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteMetadataCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteMetadataCreateBuilder();
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

class RouteMetadataCreateRouteQualityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scenic')
  static const RouteMetadataCreateRouteQualityEnum scenic = _$routeMetadataCreateRouteQualityEnum_scenic;
  @BuiltValueEnumConst(wireName: r'fastest')
  static const RouteMetadataCreateRouteQualityEnum fastest = _$routeMetadataCreateRouteQualityEnum_fastest;
  @BuiltValueEnumConst(wireName: r'offbeat')
  static const RouteMetadataCreateRouteQualityEnum offbeat = _$routeMetadataCreateRouteQualityEnum_offbeat;

  static Serializer<RouteMetadataCreateRouteQualityEnum> get serializer => _$routeMetadataCreateRouteQualityEnumSerializer;

  const RouteMetadataCreateRouteQualityEnum._(String name): super(name);

  static BuiltSet<RouteMetadataCreateRouteQualityEnum> get values => _$routeMetadataCreateRouteQualityEnumValues;
  static RouteMetadataCreateRouteQualityEnum valueOf(String name) => _$routeMetadataCreateRouteQualityEnumValueOf(name);
}

class RouteMetadataCreateRoadConditionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'excellent')
  static const RouteMetadataCreateRoadConditionEnum excellent = _$routeMetadataCreateRoadConditionEnum_excellent;
  @BuiltValueEnumConst(wireName: r'good')
  static const RouteMetadataCreateRoadConditionEnum good = _$routeMetadataCreateRoadConditionEnum_good;
  @BuiltValueEnumConst(wireName: r'poor')
  static const RouteMetadataCreateRoadConditionEnum poor = _$routeMetadataCreateRoadConditionEnum_poor;
  @BuiltValueEnumConst(wireName: r'offroad')
  static const RouteMetadataCreateRoadConditionEnum offroad = _$routeMetadataCreateRoadConditionEnum_offroad;

  static Serializer<RouteMetadataCreateRoadConditionEnum> get serializer => _$routeMetadataCreateRoadConditionEnumSerializer;

  const RouteMetadataCreateRoadConditionEnum._(String name): super(name);

  static BuiltSet<RouteMetadataCreateRoadConditionEnum> get values => _$routeMetadataCreateRoadConditionEnumValues;
  static RouteMetadataCreateRoadConditionEnum valueOf(String name) => _$routeMetadataCreateRoadConditionEnumValueOf(name);
}

