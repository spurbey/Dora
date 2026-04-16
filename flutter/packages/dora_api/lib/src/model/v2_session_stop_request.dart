//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_session_stop_request.g.dart';

/// V2SessionStopRequest
///
/// Properties:
/// * [sealVersion] 
/// * [stopClientEventId] 
/// * [stoppedAt] 
/// * [reason] 
/// * [clientSessionId] 
@BuiltValue()
abstract class V2SessionStopRequest implements Built<V2SessionStopRequest, V2SessionStopRequestBuilder> {
  @BuiltValueField(wireName: r'seal_version')
  int get sealVersion;

  @BuiltValueField(wireName: r'stop_client_event_id')
  String get stopClientEventId;

  @BuiltValueField(wireName: r'stopped_at')
  DateTime get stoppedAt;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'client_session_id')
  String? get clientSessionId;

  V2SessionStopRequest._();

  factory V2SessionStopRequest([void updates(V2SessionStopRequestBuilder b)]) = _$V2SessionStopRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2SessionStopRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2SessionStopRequest> get serializer => _$V2SessionStopRequestSerializer();
}

class _$V2SessionStopRequestSerializer implements PrimitiveSerializer<V2SessionStopRequest> {
  @override
  final Iterable<Type> types = const [V2SessionStopRequest, _$V2SessionStopRequest];

  @override
  final String wireName = r'V2SessionStopRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2SessionStopRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'seal_version';
    yield serializers.serialize(
      object.sealVersion,
      specifiedType: const FullType(int),
    );
    yield r'stop_client_event_id';
    yield serializers.serialize(
      object.stopClientEventId,
      specifiedType: const FullType(String),
    );
    yield r'stopped_at';
    yield serializers.serialize(
      object.stoppedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.clientSessionId != null) {
      yield r'client_session_id';
      yield serializers.serialize(
        object.clientSessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2SessionStopRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2SessionStopRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'seal_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sealVersion = valueDes;
          break;
        case r'stop_client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.stopClientEventId = valueDes;
          break;
        case r'stopped_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.stoppedAt = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reason = valueDes;
          break;
        case r'client_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientSessionId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2SessionStopRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2SessionStopRequestBuilder();
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

