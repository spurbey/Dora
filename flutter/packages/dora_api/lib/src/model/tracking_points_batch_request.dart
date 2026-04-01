//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/tracking_point_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_points_batch_request.g.dart';

/// TrackingPointsBatchRequest
///
/// Properties:
/// * [sessionId] 
/// * [clientBatchId] 
/// * [sentAt] 
/// * [points] 
@BuiltValue()
abstract class TrackingPointsBatchRequest implements Built<TrackingPointsBatchRequest, TrackingPointsBatchRequestBuilder> {
  @BuiltValueField(wireName: r'session_id')
  String get sessionId;

  @BuiltValueField(wireName: r'client_batch_id')
  String get clientBatchId;

  @BuiltValueField(wireName: r'sent_at')
  DateTime get sentAt;

  @BuiltValueField(wireName: r'points')
  BuiltList<TrackingPointInput>? get points;

  TrackingPointsBatchRequest._();

  factory TrackingPointsBatchRequest([void updates(TrackingPointsBatchRequestBuilder b)]) = _$TrackingPointsBatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingPointsBatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingPointsBatchRequest> get serializer => _$TrackingPointsBatchRequestSerializer();
}

class _$TrackingPointsBatchRequestSerializer implements PrimitiveSerializer<TrackingPointsBatchRequest> {
  @override
  final Iterable<Type> types = const [TrackingPointsBatchRequest, _$TrackingPointsBatchRequest];

  @override
  final String wireName = r'TrackingPointsBatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingPointsBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'session_id';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
    yield r'client_batch_id';
    yield serializers.serialize(
      object.clientBatchId,
      specifiedType: const FullType(String),
    );
    yield r'sent_at';
    yield serializers.serialize(
      object.sentAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.points != null) {
      yield r'points';
      yield serializers.serialize(
        object.points,
        specifiedType: const FullType(BuiltList, [FullType(TrackingPointInput)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingPointsBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingPointsBatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'client_batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientBatchId = valueDes;
          break;
        case r'sent_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.sentAt = valueDes;
          break;
        case r'points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackingPointInput)]),
          ) as BuiltList<TrackingPointInput>;
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
  TrackingPointsBatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingPointsBatchRequestBuilder();
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

