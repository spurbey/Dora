//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_pause_request.g.dart';

/// TrackingPauseRequest
///
/// Properties:
/// * [clientEventId] 
/// * [sessionId] 
/// * [pausedAt] 
/// * [reason] 
@BuiltValue()
abstract class TrackingPauseRequest implements Built<TrackingPauseRequest, TrackingPauseRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'session_id')
  String? get sessionId;

  @BuiltValueField(wireName: r'paused_at')
  DateTime get pausedAt;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  TrackingPauseRequest._();

  factory TrackingPauseRequest([void updates(TrackingPauseRequestBuilder b)]) = _$TrackingPauseRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingPauseRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingPauseRequest> get serializer => _$TrackingPauseRequestSerializer();
}

class _$TrackingPauseRequestSerializer implements PrimitiveSerializer<TrackingPauseRequest> {
  @override
  final Iterable<Type> types = const [TrackingPauseRequest, _$TrackingPauseRequest];

  @override
  final String wireName = r'TrackingPauseRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingPauseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    if (object.sessionId != null) {
      yield r'session_id';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'paused_at';
    yield serializers.serialize(
      object.pausedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingPauseRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingPauseRequestBuilder result,
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
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sessionId = valueDes;
          break;
        case r'paused_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.pausedAt = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingPauseRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingPauseRequestBuilder();
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

