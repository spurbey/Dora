//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/v2_route_point_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_route_segment_response.g.dart';

/// V2RouteSegmentResponse
///
/// Properties:
/// * [segmentKey] 
/// * [sessionServerId] 
/// * [startedAt] 
/// * [endedAt] 
/// * [pointCount] 
/// * [rawPointCount] 
/// * [isSimplified] 
/// * [points] 
@BuiltValue()
abstract class V2RouteSegmentResponse implements Built<V2RouteSegmentResponse, V2RouteSegmentResponseBuilder> {
  @BuiltValueField(wireName: r'segment_key')
  String get segmentKey;

  @BuiltValueField(wireName: r'session_server_id')
  String get sessionServerId;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime get endedAt;

  @BuiltValueField(wireName: r'point_count')
  int get pointCount;

  @BuiltValueField(wireName: r'raw_point_count')
  int get rawPointCount;

  @BuiltValueField(wireName: r'is_simplified')
  bool get isSimplified;

  @BuiltValueField(wireName: r'points')
  BuiltList<V2RoutePointResponse>? get points;

  V2RouteSegmentResponse._();

  factory V2RouteSegmentResponse([void updates(V2RouteSegmentResponseBuilder b)]) = _$V2RouteSegmentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2RouteSegmentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2RouteSegmentResponse> get serializer => _$V2RouteSegmentResponseSerializer();
}

class _$V2RouteSegmentResponseSerializer implements PrimitiveSerializer<V2RouteSegmentResponse> {
  @override
  final Iterable<Type> types = const [V2RouteSegmentResponse, _$V2RouteSegmentResponse];

  @override
  final String wireName = r'V2RouteSegmentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2RouteSegmentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'segment_key';
    yield serializers.serialize(
      object.segmentKey,
      specifiedType: const FullType(String),
    );
    yield r'session_server_id';
    yield serializers.serialize(
      object.sessionServerId,
      specifiedType: const FullType(String),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ended_at';
    yield serializers.serialize(
      object.endedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'point_count';
    yield serializers.serialize(
      object.pointCount,
      specifiedType: const FullType(int),
    );
    yield r'raw_point_count';
    yield serializers.serialize(
      object.rawPointCount,
      specifiedType: const FullType(int),
    );
    yield r'is_simplified';
    yield serializers.serialize(
      object.isSimplified,
      specifiedType: const FullType(bool),
    );
    if (object.points != null) {
      yield r'points';
      yield serializers.serialize(
        object.points,
        specifiedType: const FullType(BuiltList, [FullType(V2RoutePointResponse)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2RouteSegmentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2RouteSegmentResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'segment_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.segmentKey = valueDes;
          break;
        case r'session_server_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionServerId = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.endedAt = valueDes;
          break;
        case r'point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pointCount = valueDes;
          break;
        case r'raw_point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rawPointCount = valueDes;
          break;
        case r'is_simplified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isSimplified = valueDes;
          break;
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(V2RoutePointResponse)]),
          ) as BuiltList<V2RoutePointResponse>;
          result.points.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2RouteSegmentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2RouteSegmentResponseBuilder();
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

