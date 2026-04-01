//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_resume_request.g.dart';

/// TrackingResumeRequest
///
/// Properties:
/// * [clientEventId] 
/// * [sessionId] 
/// * [resumedAt] 
@BuiltValue()
abstract class TrackingResumeRequest implements Built<TrackingResumeRequest, TrackingResumeRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'session_id')
  String? get sessionId;

  @BuiltValueField(wireName: r'resumed_at')
  DateTime get resumedAt;

  TrackingResumeRequest._();

  factory TrackingResumeRequest([void updates(TrackingResumeRequestBuilder b)]) = _$TrackingResumeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingResumeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingResumeRequest> get serializer => _$TrackingResumeRequestSerializer();
}

class _$TrackingResumeRequestSerializer implements PrimitiveSerializer<TrackingResumeRequest> {
  @override
  final Iterable<Type> types = const [TrackingResumeRequest, _$TrackingResumeRequest];

  @override
  final String wireName = r'TrackingResumeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingResumeRequest object, {
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
    yield r'resumed_at';
    yield serializers.serialize(
      object.resumedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingResumeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingResumeRequestBuilder result,
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
        case r'resumed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.resumedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingResumeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingResumeRequestBuilder();
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

