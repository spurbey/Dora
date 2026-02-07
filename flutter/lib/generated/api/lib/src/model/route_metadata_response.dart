//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_metadata_response.g.dart';

/// Route metadata response schema.
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
/// * [routeId] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class RouteMetadataResponse implements Built<RouteMetadataResponse, RouteMetadataResponseBuilder> {
  @BuiltValueField(wireName: r'route_quality')
  RouteMetadataResponseRouteQualityEnum? get routeQuality;
  // enum routeQualityEnum {  scenic,  fastest,  offbeat,  };

  @BuiltValueField(wireName: r'road_condition')
  RouteMetadataResponseRoadConditionEnum? get roadCondition;
  // enum roadConditionEnum {  excellent,  good,  poor,  offroad,  };

  @BuiltValueField(wireName: r'scenic_rating')
  int? get scenicRating;

  @BuiltValueField(wireName: r'safety_rating')
  int? get safetyRating;

  @BuiltValueField(wireName: r'solo_safe')
  bool? get soloSafe;

  @BuiltValueField(wireName: r'fuel_cost')
  String? get fuelCost;

  @BuiltValueField(wireName: r'toll_cost')
  String? get tollCost;

  @BuiltValueField(wireName: r'highlights')
  BuiltList<String>? get highlights;

  @BuiltValueField(wireName: r'is_public')
  bool? get isPublic;

  @BuiltValueField(wireName: r'route_id')
  String get routeId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  RouteMetadataResponse._();

  factory RouteMetadataResponse([void updates(RouteMetadataResponseBuilder b)]) = _$RouteMetadataResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteMetadataResponseBuilder b) => b
      ..safetyRating = 3
      ..soloSafe = true
      ..isPublic = false;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteMetadataResponse> get serializer => _$RouteMetadataResponseSerializer();
}

class _$RouteMetadataResponseSerializer implements PrimitiveSerializer<RouteMetadataResponse> {
  @override
  final Iterable<Type> types = const [RouteMetadataResponse, _$RouteMetadataResponse];

  @override
  final String wireName = r'RouteMetadataResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.routeQuality != null) {
      yield r'route_quality';
      yield serializers.serialize(
        object.routeQuality,
        specifiedType: const FullType.nullable(RouteMetadataResponseRouteQualityEnum),
      );
    }
    if (object.roadCondition != null) {
      yield r'road_condition';
      yield serializers.serialize(
        object.roadCondition,
        specifiedType: const FullType.nullable(RouteMetadataResponseRoadConditionEnum),
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
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.tollCost != null) {
      yield r'toll_cost';
      yield serializers.serialize(
        object.tollCost,
        specifiedType: const FullType.nullable(String),
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
    yield r'route_id';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
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
    RouteMetadataResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteMetadataResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'route_quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteMetadataResponseRouteQualityEnum),
          ) as RouteMetadataResponseRouteQualityEnum?;
          if (valueDes == null) continue;
          result.routeQuality = valueDes;
          break;
        case r'road_condition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(RouteMetadataResponseRoadConditionEnum),
          ) as RouteMetadataResponseRoadConditionEnum?;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fuelCost = valueDes;
          break;
        case r'toll_cost':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tollCost = valueDes;
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
        case r'route_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
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
  RouteMetadataResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteMetadataResponseBuilder();
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

class RouteMetadataResponseRouteQualityEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'scenic')
  static const RouteMetadataResponseRouteQualityEnum scenic = _$routeMetadataResponseRouteQualityEnum_scenic;
  @BuiltValueEnumConst(wireName: r'fastest')
  static const RouteMetadataResponseRouteQualityEnum fastest = _$routeMetadataResponseRouteQualityEnum_fastest;
  @BuiltValueEnumConst(wireName: r'offbeat')
  static const RouteMetadataResponseRouteQualityEnum offbeat = _$routeMetadataResponseRouteQualityEnum_offbeat;

  static Serializer<RouteMetadataResponseRouteQualityEnum> get serializer => _$routeMetadataResponseRouteQualityEnumSerializer;

  const RouteMetadataResponseRouteQualityEnum._(String name): super(name);

  static BuiltSet<RouteMetadataResponseRouteQualityEnum> get values => _$routeMetadataResponseRouteQualityEnumValues;
  static RouteMetadataResponseRouteQualityEnum valueOf(String name) => _$routeMetadataResponseRouteQualityEnumValueOf(name);
}

class RouteMetadataResponseRoadConditionEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'excellent')
  static const RouteMetadataResponseRoadConditionEnum excellent = _$routeMetadataResponseRoadConditionEnum_excellent;
  @BuiltValueEnumConst(wireName: r'good')
  static const RouteMetadataResponseRoadConditionEnum good = _$routeMetadataResponseRoadConditionEnum_good;
  @BuiltValueEnumConst(wireName: r'poor')
  static const RouteMetadataResponseRoadConditionEnum poor = _$routeMetadataResponseRoadConditionEnum_poor;
  @BuiltValueEnumConst(wireName: r'offroad')
  static const RouteMetadataResponseRoadConditionEnum offroad = _$routeMetadataResponseRoadConditionEnum_offroad;

  static Serializer<RouteMetadataResponseRoadConditionEnum> get serializer => _$routeMetadataResponseRoadConditionEnumSerializer;

  const RouteMetadataResponseRoadConditionEnum._(String name): super(name);

  static BuiltSet<RouteMetadataResponseRoadConditionEnum> get values => _$routeMetadataResponseRoadConditionEnumValues;
  static RouteMetadataResponseRoadConditionEnum valueOf(String name) => _$routeMetadataResponseRoadConditionEnumValueOf(name);
}

