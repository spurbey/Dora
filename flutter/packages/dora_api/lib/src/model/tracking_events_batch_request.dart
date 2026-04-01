//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/tracking_event_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_events_batch_request.g.dart';

/// TrackingEventsBatchRequest
///
/// Properties:
/// * [events] 
@BuiltValue()
abstract class TrackingEventsBatchRequest implements Built<TrackingEventsBatchRequest, TrackingEventsBatchRequestBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<TrackingEventInput>? get events;

  TrackingEventsBatchRequest._();

  factory TrackingEventsBatchRequest([void updates(TrackingEventsBatchRequestBuilder b)]) = _$TrackingEventsBatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingEventsBatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingEventsBatchRequest> get serializer => _$TrackingEventsBatchRequestSerializer();
}

class _$TrackingEventsBatchRequestSerializer implements PrimitiveSerializer<TrackingEventsBatchRequest> {
  @override
  final Iterable<Type> types = const [TrackingEventsBatchRequest, _$TrackingEventsBatchRequest];

  @override
  final String wireName = r'TrackingEventsBatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingEventsBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.events != null) {
      yield r'events';
      yield serializers.serialize(
        object.events,
        specifiedType: const FullType(BuiltList, [FullType(TrackingEventInput)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingEventsBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingEventsBatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackingEventInput)]),
          ) as BuiltList<TrackingEventInput>;
          result.events.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingEventsBatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingEventsBatchRequestBuilder();
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

