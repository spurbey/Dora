//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_start_request.g.dart';

/// TrackingStartRequest
///
/// Properties:
/// * [clientSessionId] 
/// * [startedAt] 
/// * [timezone] 
/// * [deviceContext] 
@BuiltValue()
abstract class TrackingStartRequest implements Built<TrackingStartRequest, TrackingStartRequestBuilder> {
  @BuiltValueField(wireName: r'client_session_id')
  String get clientSessionId;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'device_context')
  JsonObject? get deviceContext;

  TrackingStartRequest._();

  factory TrackingStartRequest([void updates(TrackingStartRequestBuilder b)]) = _$TrackingStartRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingStartRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingStartRequest> get serializer => _$TrackingStartRequestSerializer();
}

class _$TrackingStartRequestSerializer implements PrimitiveSerializer<TrackingStartRequest> {
  @override
  final Iterable<Type> types = const [TrackingStartRequest, _$TrackingStartRequest];

  @override
  final String wireName = r'TrackingStartRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_session_id';
    yield serializers.serialize(
      object.clientSessionId,
      specifiedType: const FullType(String),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.deviceContext != null) {
      yield r'device_context';
      yield serializers.serialize(
        object.deviceContext,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingStartRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientSessionId = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'device_context':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.deviceContext = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingStartRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingStartRequestBuilder();
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

