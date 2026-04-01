//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/tracking_media_rejected_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/tracking_media_accepted_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_media_batch_response.g.dart';

/// TrackingMediaBatchResponse
///
/// Properties:
/// * [tripId] 
/// * [accepted] 
/// * [rejected] 
/// * [acceptedCount] 
/// * [rejectedCount] 
/// * [idempotencyReplayed] 
@BuiltValue()
abstract class TrackingMediaBatchResponse implements Built<TrackingMediaBatchResponse, TrackingMediaBatchResponseBuilder> {
  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'accepted')
  BuiltList<TrackingMediaAcceptedResponse> get accepted;

  @BuiltValueField(wireName: r'rejected')
  BuiltList<TrackingMediaRejectedResponse> get rejected;

  @BuiltValueField(wireName: r'accepted_count')
  int get acceptedCount;

  @BuiltValueField(wireName: r'rejected_count')
  int get rejectedCount;

  @BuiltValueField(wireName: r'idempotency_replayed')
  bool get idempotencyReplayed;

  TrackingMediaBatchResponse._();

  factory TrackingMediaBatchResponse([void updates(TrackingMediaBatchResponseBuilder b)]) = _$TrackingMediaBatchResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingMediaBatchResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingMediaBatchResponse> get serializer => _$TrackingMediaBatchResponseSerializer();
}

class _$TrackingMediaBatchResponseSerializer implements PrimitiveSerializer<TrackingMediaBatchResponse> {
  @override
  final Iterable<Type> types = const [TrackingMediaBatchResponse, _$TrackingMediaBatchResponse];

  @override
  final String wireName = r'TrackingMediaBatchResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingMediaBatchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'accepted';
    yield serializers.serialize(
      object.accepted,
      specifiedType: const FullType(BuiltList, [FullType(TrackingMediaAcceptedResponse)]),
    );
    yield r'rejected';
    yield serializers.serialize(
      object.rejected,
      specifiedType: const FullType(BuiltList, [FullType(TrackingMediaRejectedResponse)]),
    );
    yield r'accepted_count';
    yield serializers.serialize(
      object.acceptedCount,
      specifiedType: const FullType(int),
    );
    yield r'rejected_count';
    yield serializers.serialize(
      object.rejectedCount,
      specifiedType: const FullType(int),
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
    TrackingMediaBatchResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingMediaBatchResponseBuilder result,
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
        case r'accepted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackingMediaAcceptedResponse)]),
          ) as BuiltList<TrackingMediaAcceptedResponse>;
          result.accepted.replace(valueDes);
          break;
        case r'rejected':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackingMediaRejectedResponse)]),
          ) as BuiltList<TrackingMediaRejectedResponse>;
          result.rejected.replace(valueDes);
          break;
        case r'accepted_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedCount = valueDes;
          break;
        case r'rejected_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rejectedCount = valueDes;
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
  TrackingMediaBatchResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingMediaBatchResponseBuilder();
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

