//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/fuel_cost.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/toll_cost.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_metadata_update.g.dart';

/// Route metadata update schema (partial updates).  All fields are optional.
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
abstract class RouteMetadataUpdate implements Built<RouteMetadataUpdate, RouteMetadataUpdateBuilder> {
  @BuiltValueField(wireName: r'route_quality')
  RouteMetadataUpdateRouteQualityEnum? get routeQuality;
  // enum routeQualityEnum {  scenic,  fastest,  offbeat,  };

  @BuiltValueField(wireName: r'road_condition')
  RouteMetadataUpdateRoadConditionEnum? get roadCondition;
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

  RouteMetadataUpdate._();

  factory RouteMetadataUpdate([void updates(RouteMetadataUpdateBuilder b)]) = _$RouteMetadataUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteMetadataUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteMetadataUpdate> get serializer => _$RouteMetadataUpdateSerializer();
}

class _$RouteMetadataUpdateSerializer implements PrimitiveSerializer<RouteMetadataUpdate> {
  @override
  final Iterable<Type> types = const [RouteMetadataUpdate, _$RouteMetadataUpdate];

  @override
  final String wireName = r'RouteMetadataUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteMetadataUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.routeQuality != null) {
      yield r'route_quality';
      yield serializers.serialize(
        object.routeQuality,
        specifiedType: const FullType.nullable(RouteMetadataUpdateRouteQualityEnum),
      );
    }
    if (object.roadCondition != null) {
      yield r'road_condition';
      yield serializers.serialize(
        object.roadCondition,
        specifiedType: const FullType.nullable(RouteMetadataUpdateRoadConditionEnum),
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
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.soloSafe != null) {
      yield r'solo_safe';
      yield serializers.serialize(
        object.soloSafe,
        specifiedType: const FullType.nullable(bool),
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
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteMetadataUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteMetadataUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'route_quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteMetadataUpdateRouteQualityEnum),
          ) as RouteMetadataUpdateRouteQualityEnum?;
          if (valueDes == null) continue;
          result.routeQuality = valueDes;
          break;
        case r'road_condition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteMetadataUpdateRoadConditionEnum),
          ) as RouteMetadataUpdateRoadConditionEnum?;
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
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.safetyRating = valueDes;
          break;
        case r'solo_safe':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
  RouteMetadataUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteMetadataUpdateBuilder();
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

class RouteMetadataUpdateRouteQualityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scenic')
  static const RouteMetadataUpdateRouteQualityEnum scenic = _$routeMetadataUpdateRouteQualityEnum_scenic;
  @BuiltValueEnumConst(wireName: r'fastest')
  static const RouteMetadataUpdateRouteQualityEnum fastest = _$routeMetadataUpdateRouteQualityEnum_fastest;
  @BuiltValueEnumConst(wireName: r'offbeat')
  static const RouteMetadataUpdateRouteQualityEnum offbeat = _$routeMetadataUpdateRouteQualityEnum_offbeat;

  static Serializer<RouteMetadataUpdateRouteQualityEnum> get serializer => _$routeMetadataUpdateRouteQualityEnumSerializer;

  const RouteMetadataUpdateRouteQualityEnum._(String name): super(name);

  static BuiltSet<RouteMetadataUpdateRouteQualityEnum> get values => _$routeMetadataUpdateRouteQualityEnumValues;
  static RouteMetadataUpdateRouteQualityEnum valueOf(String name) => _$routeMetadataUpdateRouteQualityEnumValueOf(name);
}

class RouteMetadataUpdateRoadConditionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'excellent')
  static const RouteMetadataUpdateRoadConditionEnum excellent = _$routeMetadataUpdateRoadConditionEnum_excellent;
  @BuiltValueEnumConst(wireName: r'good')
  static const RouteMetadataUpdateRoadConditionEnum good = _$routeMetadataUpdateRoadConditionEnum_good;
  @BuiltValueEnumConst(wireName: r'poor')
  static const RouteMetadataUpdateRoadConditionEnum poor = _$routeMetadataUpdateRoadConditionEnum_poor;
  @BuiltValueEnumConst(wireName: r'offroad')
  static const RouteMetadataUpdateRoadConditionEnum offroad = _$routeMetadataUpdateRoadConditionEnum_offroad;

  static Serializer<RouteMetadataUpdateRoadConditionEnum> get serializer => _$routeMetadataUpdateRoadConditionEnumSerializer;

  const RouteMetadataUpdateRoadConditionEnum._(String name): super(name);

  static BuiltSet<RouteMetadataUpdateRoadConditionEnum> get values => _$routeMetadataUpdateRoadConditionEnumValues;
  static RouteMetadataUpdateRoadConditionEnum valueOf(String name) => _$routeMetadataUpdateRoadConditionEnumValueOf(name);
}

