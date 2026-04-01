//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/tracking_path_point_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_path_response.g.dart';

/// TrackingPathResponse
///
/// Properties:
/// * [tripId] 
/// * [sessionId] 
/// * [pointsCount] 
/// * [points] 
@BuiltValue()
abstract class TrackingPathResponse implements Built<TrackingPathResponse, TrackingPathResponseBuilder> {
  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'session_id')
  String get sessionId;

  @BuiltValueField(wireName: r'points_count')
  int get pointsCount;

  @BuiltValueField(wireName: r'points')
  BuiltList<TrackingPathPointResponse> get points;

  TrackingPathResponse._();

  factory TrackingPathResponse([void updates(TrackingPathResponseBuilder b)]) = _$TrackingPathResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingPathResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingPathResponse> get serializer => _$TrackingPathResponseSerializer();
}

class _$TrackingPathResponseSerializer implements PrimitiveSerializer<TrackingPathResponse> {
  @override
  final Iterable<Type> types = const [TrackingPathResponse, _$TrackingPathResponse];

  @override
  final String wireName = r'TrackingPathResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingPathResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'session_id';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
    yield r'points_count';
    yield serializers.serialize(
      object.pointsCount,
      specifiedType: const FullType(int),
    );
    yield r'points';
    yield serializers.serialize(
      object.points,
      specifiedType: const FullType(BuiltList, [FullType(TrackingPathPointResponse)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingPathResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingPathResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'points_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pointsCount = valueDes;
          break;
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackingPathPointResponse)]),
          ) as BuiltList<TrackingPathPointResponse>;
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
  TrackingPathResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingPathResponseBuilder();
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

