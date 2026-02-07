//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_generate_request.g.dart';

/// Request schema for /routes/generate endpoint.
///
/// Properties:
/// * [coordinates] - [(lng, lat), ...]
/// * [mode] 
@BuiltValue()
abstract class RouteGenerateRequest implements Built<RouteGenerateRequest, RouteGenerateRequestBuilder> {
  /// [(lng, lat), ...]
  @BuiltValueField(wireName: r'coordinates')
  BuiltList<BuiltList<JsonObject?>> get coordinates;

  @BuiltValueField(wireName: r'mode')
  RouteGenerateRequestModeEnum? get mode;
  // enum modeEnum {  driving,  walking,  cycling,  };

  RouteGenerateRequest._();

  factory RouteGenerateRequest([void updates(RouteGenerateRequestBuilder b)]) = _$RouteGenerateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteGenerateRequestBuilder b) => b
      ..mode = RouteGenerateRequestModeEnum.valueOf('driving');

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteGenerateRequest> get serializer => _$RouteGenerateRequestSerializer();
}

class _$RouteGenerateRequestSerializer implements PrimitiveSerializer<RouteGenerateRequest> {
  @override
  final Iterable<Type> types = const [RouteGenerateRequest, _$RouteGenerateRequest];

  @override
  final String wireName = r'RouteGenerateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteGenerateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'coordinates';
    yield serializers.serialize(
      object.coordinates,
      specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType.nullable(JsonObject)])]),
    );
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(RouteGenerateRequestModeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteGenerateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteGenerateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'coordinates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltList, [FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltList<JsonObject?>>;
          result.coordinates.replace(valueDes);
          break;
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(RouteGenerateRequestModeEnum),
          ) as RouteGenerateRequestModeEnum;
          result.mode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteGenerateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteGenerateRequestBuilder();
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

class RouteGenerateRequestModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'driving')
  static const RouteGenerateRequestModeEnum driving = _$routeGenerateRequestModeEnum_driving;
  @BuiltValueEnumConst(wireName: r'walking')
  static const RouteGenerateRequestModeEnum walking = _$routeGenerateRequestModeEnum_walking;
  @BuiltValueEnumConst(wireName: r'cycling')
  static const RouteGenerateRequestModeEnum cycling = _$routeGenerateRequestModeEnum_cycling;

  static Serializer<RouteGenerateRequestModeEnum> get serializer => _$routeGenerateRequestModeEnumSerializer;

  const RouteGenerateRequestModeEnum._(String name): super(name);

  static BuiltSet<RouteGenerateRequestModeEnum> get values => _$routeGenerateRequestModeEnumValues;
  static RouteGenerateRequestModeEnum valueOf(String name) => _$routeGenerateRequestModeEnumValueOf(name);
}

