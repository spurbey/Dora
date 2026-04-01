//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_event_accepted_response.g.dart';

/// TrackingEventAcceptedResponse
///
/// Properties:
/// * [clientEventId] 
/// * [eventId] 
/// * [duplicate] 
@BuiltValue()
abstract class TrackingEventAcceptedResponse implements Built<TrackingEventAcceptedResponse, TrackingEventAcceptedResponseBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'event_id')
  String get eventId;

  @BuiltValueField(wireName: r'duplicate')
  bool get duplicate;

  TrackingEventAcceptedResponse._();

  factory TrackingEventAcceptedResponse([void updates(TrackingEventAcceptedResponseBuilder b)]) = _$TrackingEventAcceptedResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingEventAcceptedResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingEventAcceptedResponse> get serializer => _$TrackingEventAcceptedResponseSerializer();
}

class _$TrackingEventAcceptedResponseSerializer implements PrimitiveSerializer<TrackingEventAcceptedResponse> {
  @override
  final Iterable<Type> types = const [TrackingEventAcceptedResponse, _$TrackingEventAcceptedResponse];

  @override
  final String wireName = r'TrackingEventAcceptedResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingEventAcceptedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'event_id';
    yield serializers.serialize(
      object.eventId,
      specifiedType: const FullType(String),
    );
    yield r'duplicate';
    yield serializers.serialize(
      object.duplicate,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingEventAcceptedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingEventAcceptedResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientEventId = valueDes;
          break;
        case r'event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventId = valueDes;
          break;
        case r'duplicate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.duplicate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingEventAcceptedResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingEventAcceptedResponseBuilder();
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

