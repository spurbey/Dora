//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_points_batch_response.g.dart';

/// TrackingPointsBatchResponse
///
/// Properties:
/// * [tripId] 
/// * [sessionId] 
/// * [clientBatchId] 
/// * [acceptedPoints] 
/// * [duplicatePoints] 
/// * [ingestJobId] 
/// * [idempotencyReplayed] 
@BuiltValue()
abstract class TrackingPointsBatchResponse implements Built<TrackingPointsBatchResponse, TrackingPointsBatchResponseBuilder> {
  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'session_id')
  String get sessionId;

  @BuiltValueField(wireName: r'client_batch_id')
  String get clientBatchId;

  @BuiltValueField(wireName: r'accepted_points')
  int get acceptedPoints;

  @BuiltValueField(wireName: r'duplicate_points')
  int get duplicatePoints;

  @BuiltValueField(wireName: r'ingest_job_id')
  String get ingestJobId;

  @BuiltValueField(wireName: r'idempotency_replayed')
  bool get idempotencyReplayed;

  TrackingPointsBatchResponse._();

  factory TrackingPointsBatchResponse([void updates(TrackingPointsBatchResponseBuilder b)]) = _$TrackingPointsBatchResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingPointsBatchResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingPointsBatchResponse> get serializer => _$TrackingPointsBatchResponseSerializer();
}

class _$TrackingPointsBatchResponseSerializer implements PrimitiveSerializer<TrackingPointsBatchResponse> {
  @override
  final Iterable<Type> types = const [TrackingPointsBatchResponse, _$TrackingPointsBatchResponse];

  @override
  final String wireName = r'TrackingPointsBatchResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingPointsBatchResponse object, {
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
    yield r'client_batch_id';
    yield serializers.serialize(
      object.clientBatchId,
      specifiedType: const FullType(String),
    );
    yield r'accepted_points';
    yield serializers.serialize(
      object.acceptedPoints,
      specifiedType: const FullType(int),
    );
    yield r'duplicate_points';
    yield serializers.serialize(
      object.duplicatePoints,
      specifiedType: const FullType(int),
    );
    yield r'ingest_job_id';
    yield serializers.serialize(
      object.ingestJobId,
      specifiedType: const FullType(String),
    );
    yield r'idempotency_replayed';
    yield serializers.serialize(
      object.idempotencyReplayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingPointsBatchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingPointsBatchResponseBuilder result,
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
        case r'client_batch_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientBatchId = valueDes;
          break;
        case r'accepted_points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedPoints = valueDes;
          break;
        case r'duplicate_points':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.duplicatePoints = valueDes;
          break;
        case r'ingest_job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ingestJobId = valueDes;
          break;
        case r'idempotency_replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.idempotencyReplayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingPointsBatchResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingPointsBatchResponseBuilder();
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

