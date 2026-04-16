//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_session_start_request.g.dart';

/// V2SessionStartRequest
///
/// Properties:
/// * [clientSessionId] 
/// * [startedAt] 
/// * [timezone] 
/// * [deviceContext] 
@BuiltValue()
abstract class V2SessionStartRequest implements Built<V2SessionStartRequest, V2SessionStartRequestBuilder> {
  @BuiltValueField(wireName: r'client_session_id')
  String get clientSessionId;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'device_context')
  BuiltMap<String, JsonObject?>? get deviceContext;

  V2SessionStartRequest._();

  factory V2SessionStartRequest([void updates(V2SessionStartRequestBuilder b)]) = _$V2SessionStartRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2SessionStartRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2SessionStartRequest> get serializer => _$V2SessionStartRequestSerializer();
}

class _$V2SessionStartRequestSerializer implements PrimitiveSerializer<V2SessionStartRequest> {
  @override
  final Iterable<Type> types = const [V2SessionStartRequest, _$V2SessionStartRequest];

  @override
  final String wireName = r'V2SessionStartRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2SessionStartRequest object, {
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
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2SessionStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2SessionStartRequestBuilder result,
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
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.deviceContext.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2SessionStartRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2SessionStartRequestBuilder();
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

