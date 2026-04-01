//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_event_rejected_response.g.dart';

/// TrackingEventRejectedResponse
///
/// Properties:
/// * [clientEventId] 
/// * [reasonCode] 
/// * [message] 
@BuiltValue()
abstract class TrackingEventRejectedResponse implements Built<TrackingEventRejectedResponse, TrackingEventRejectedResponseBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String? get clientEventId;

  @BuiltValueField(wireName: r'reason_code')
  String get reasonCode;

  @BuiltValueField(wireName: r'message')
  String get message;

  TrackingEventRejectedResponse._();

  factory TrackingEventRejectedResponse([void updates(TrackingEventRejectedResponseBuilder b)]) = _$TrackingEventRejectedResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingEventRejectedResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingEventRejectedResponse> get serializer => _$TrackingEventRejectedResponseSerializer();
}

class _$TrackingEventRejectedResponseSerializer implements PrimitiveSerializer<TrackingEventRejectedResponse> {
  @override
  final Iterable<Type> types = const [TrackingEventRejectedResponse, _$TrackingEventRejectedResponse];

  @override
  final String wireName = r'TrackingEventRejectedResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingEventRejectedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clientEventId != null) {
      yield r'client_event_id';
      yield serializers.serialize(
        object.clientEventId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'reason_code';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingEventRejectedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingEventRejectedResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientEventId = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reasonCode = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingEventRejectedResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingEventRejectedResponseBuilder();
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

