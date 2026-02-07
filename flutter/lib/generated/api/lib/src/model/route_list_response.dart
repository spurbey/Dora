//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/route_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'route_list_response.g.dart';

/// Paginated route list response.
///
/// Properties:
/// * [routes] 
/// * [total] 
@BuiltValue()
abstract class RouteListResponse implements Built<RouteListResponse, RouteListResponseBuilder> {
  @BuiltValueField(wireName: r'routes')
  BuiltList<RouteResponse> get routes;

  @BuiltValueField(wireName: r'total')
  int get total;

  RouteListResponse._();

  factory RouteListResponse([void updates(RouteListResponseBuilder b)]) = _$RouteListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RouteListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RouteListResponse> get serializer => _$RouteListResponseSerializer();
}

class _$RouteListResponseSerializer implements PrimitiveSerializer<RouteListResponse> {
  @override
  final Iterable<Type> types = const [RouteListResponse, _$RouteListResponse];

  @override
  final String wireName = r'RouteListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RouteListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'routes';
    yield serializers.serialize(
      object.routes,
      specifiedType: const FullType(BuiltList, [FullType(RouteResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RouteListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RouteListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'routes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(RouteResponse)]),
          ) as BuiltList<RouteResponse>;
          result.routes.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RouteListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RouteListResponseBuilder();
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

