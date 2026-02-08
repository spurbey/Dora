//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_generate_response.g.dart';

/// Response schema for /routes/generate endpoint.
///
/// Properties:
/// * [routeGeojson] 
/// * [distanceKm] 
/// * [durationMins] 
/// * [polylineEncoded] 
@BuiltValue()
abstract class RouteGenerateResponse implements Built<RouteGenerateResponse, RouteGenerateResponseBuilder> {
  @BuiltValueField(wireName: r'route_geojson')
  JsonObject get routeGeojson;

  @BuiltValueField(wireName: r'distance_km')
  num get distanceKm;

  @BuiltValueField(wireName: r'duration_mins')
  int get durationMins;

  @BuiltValueField(wireName: r'polyline_encoded')
  String? get polylineEncoded;

  RouteGenerateResponse._();

  factory RouteGenerateResponse([void updates(RouteGenerateResponseBuilder b)]) = _$RouteGenerateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteGenerateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteGenerateResponse> get serializer => _$RouteGenerateResponseSerializer();
}

class _$RouteGenerateResponseSerializer implements PrimitiveSerializer<RouteGenerateResponse> {
  @override
  final Iterable<Type> types = const [RouteGenerateResponse, _$RouteGenerateResponse];

  @override
  final String wireName = r'RouteGenerateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteGenerateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'route_geojson';
    yield serializers.serialize(
      object.routeGeojson,
      specifiedType: const FullType(JsonObject),
    );
    yield r'distance_km';
    yield serializers.serialize(
      object.distanceKm,
      specifiedType: const FullType(num),
    );
    yield r'duration_mins';
    yield serializers.serialize(
      object.durationMins,
      specifiedType: const FullType(int),
    );
    if (object.polylineEncoded != null) {
      yield r'polyline_encoded';
      yield serializers.serialize(
        object.polylineEncoded,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteGenerateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteGenerateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'route_geojson':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.routeGeojson = valueDes;
          break;
        case r'distance_km':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceKm = valueDes;
          break;
        case r'duration_mins':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationMins = valueDes;
          break;
        case r'polyline_encoded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.polylineEncoded = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteGenerateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteGenerateResponseBuilder();
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

