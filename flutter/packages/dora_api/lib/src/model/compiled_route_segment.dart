//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compiled_route_segment.g.dart';

/// CompiledRouteSegment
///
/// Properties:
/// * [segmentId] 
/// * [sessionId] 
/// * [startedAt] 
/// * [endedAt] 
/// * [distanceM] 
/// * [rawPointCount] 
/// * [simplifiedPointCount] 
/// * [geometry] 
@BuiltValue()
abstract class CompiledRouteSegment implements Built<CompiledRouteSegment, CompiledRouteSegmentBuilder> {
  @BuiltValueField(wireName: r'segment_id')
  String get segmentId;

  @BuiltValueField(wireName: r'session_id')
  String? get sessionId;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime get endedAt;

  @BuiltValueField(wireName: r'distance_m')
  num get distanceM;

  @BuiltValueField(wireName: r'raw_point_count')
  int get rawPointCount;

  @BuiltValueField(wireName: r'simplified_point_count')
  int get simplifiedPointCount;

  @BuiltValueField(wireName: r'geometry')
  JsonObject? get geometry;

  CompiledRouteSegment._();

  factory CompiledRouteSegment([void updates(CompiledRouteSegmentBuilder b)]) = _$CompiledRouteSegment;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompiledRouteSegmentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompiledRouteSegment> get serializer => _$CompiledRouteSegmentSerializer();
}

class _$CompiledRouteSegmentSerializer implements PrimitiveSerializer<CompiledRouteSegment> {
  @override
  final Iterable<Type> types = const [CompiledRouteSegment, _$CompiledRouteSegment];

  @override
  final String wireName = r'CompiledRouteSegment';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompiledRouteSegment object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'segment_id';
    yield serializers.serialize(
      object.segmentId,
      specifiedType: const FullType(String),
    );
    if (object.sessionId != null) {
      yield r'session_id';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    yield r'distance_m';
    yield serializers.serialize(
      object.distanceM,
      specifiedType: const FullType(num),
    );
    yield r'raw_point_count';
    yield serializers.serialize(
      object.rawPointCount,
      specifiedType: const FullType(int),
    );
    yield r'simplified_point_count';
    yield serializers.serialize(
      object.simplifiedPointCount,
      specifiedType: const FullType(int),
    );
    if (object.geometry != null) {
      yield r'geometry';
      yield serializers.serialize(
        object.geometry,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompiledRouteSegment object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompiledRouteSegmentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'segment_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.segmentId = valueDes;
          break;
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sessionId = valueDes;
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
        case r'distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.distanceM = valueDes;
          break;
        case r'raw_point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rawPointCount = valueDes;
          break;
        case r'simplified_point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.simplifiedPointCount = valueDes;
          break;
        case r'geometry':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.geometry = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompiledRouteSegment deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompiledRouteSegmentBuilder();
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

