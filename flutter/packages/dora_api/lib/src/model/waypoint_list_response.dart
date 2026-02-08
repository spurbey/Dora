//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/waypoint_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waypoint_list_response.g.dart';

/// Waypoint list response.
///
/// Properties:
/// * [waypoints] 
/// * [total] 
@BuiltValue()
abstract class WaypointListResponse implements Built<WaypointListResponse, WaypointListResponseBuilder> {
  @BuiltValueField(wireName: r'waypoints')
  BuiltList<WaypointResponse> get waypoints;

  @BuiltValueField(wireName: r'total')
  int get total;

  WaypointListResponse._();

  factory WaypointListResponse([void updates(WaypointListResponseBuilder b)]) = _$WaypointListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaypointListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaypointListResponse> get serializer => _$WaypointListResponseSerializer();
}

class _$WaypointListResponseSerializer implements PrimitiveSerializer<WaypointListResponse> {
  @override
  final Iterable<Type> types = const [WaypointListResponse, _$WaypointListResponse];

  @override
  final String wireName = r'WaypointListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaypointListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'waypoints';
    yield serializers.serialize(
      object.waypoints,
      specifiedType: const FullType(BuiltList, [FullType(WaypointResponse)]),
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
    WaypointListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WaypointListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'waypoints':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(WaypointResponse)]),
          ) as BuiltList<WaypointResponse>;
          result.waypoints.replace(valueDes);
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
  WaypointListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaypointListResponseBuilder();
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

