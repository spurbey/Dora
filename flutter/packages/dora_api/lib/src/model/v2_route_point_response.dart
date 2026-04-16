//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_route_point_response.g.dart';

/// V2RoutePointResponse
///
/// Properties:
/// * [latitude] 
/// * [longitude] 
/// * [capturedAt] 
@BuiltValue()
abstract class V2RoutePointResponse implements Built<V2RoutePointResponse, V2RoutePointResponseBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'captured_at')
  DateTime? get capturedAt;

  V2RoutePointResponse._();

  factory V2RoutePointResponse([void updates(V2RoutePointResponseBuilder b)]) = _$V2RoutePointResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2RoutePointResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2RoutePointResponse> get serializer => _$V2RoutePointResponseSerializer();
}

class _$V2RoutePointResponseSerializer implements PrimitiveSerializer<V2RoutePointResponse> {
  @override
  final Iterable<Type> types = const [V2RoutePointResponse, _$V2RoutePointResponse];

  @override
  final String wireName = r'V2RoutePointResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2RoutePointResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    if (object.capturedAt != null) {
      yield r'captured_at';
      yield serializers.serialize(
        object.capturedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2RoutePointResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2RoutePointResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'captured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.capturedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2RoutePointResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2RoutePointResponseBuilder();
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

