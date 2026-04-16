//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_session_response.g.dart';

/// V2SessionResponse
///
/// Properties:
/// * [sessionServerId] 
/// * [tripId] 
/// * [clientSessionId] 
/// * [status] 
/// * [startedAt] 
/// * [endedAt] 
/// * [stopServerPending] 
/// * [stopClientEventId] 
/// * [sealVersion] 
/// * [timezone] 
/// * [commitToken] 
@BuiltValue()
abstract class V2SessionResponse implements Built<V2SessionResponse, V2SessionResponseBuilder> {
  @BuiltValueField(wireName: r'session_server_id')
  String get sessionServerId;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'client_session_id')
  String get clientSessionId;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  @BuiltValueField(wireName: r'stop_server_pending')
  bool get stopServerPending;

  @BuiltValueField(wireName: r'stop_client_event_id')
  String? get stopClientEventId;

  @BuiltValueField(wireName: r'seal_version')
  int get sealVersion;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'commit_token')
  String? get commitToken;

  V2SessionResponse._();

  factory V2SessionResponse([void updates(V2SessionResponseBuilder b)]) = _$V2SessionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2SessionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2SessionResponse> get serializer => _$V2SessionResponseSerializer();
}

class _$V2SessionResponseSerializer implements PrimitiveSerializer<V2SessionResponse> {
  @override
  final Iterable<Type> types = const [V2SessionResponse, _$V2SessionResponse];

  @override
  final String wireName = r'V2SessionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2SessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'session_server_id';
    yield serializers.serialize(
      object.sessionServerId,
      specifiedType: const FullType(String),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'client_session_id';
    yield serializers.serialize(
      object.clientSessionId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.endedAt != null) {
      yield r'ended_at';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'stop_server_pending';
    yield serializers.serialize(
      object.stopServerPending,
      specifiedType: const FullType(bool),
    );
    if (object.stopClientEventId != null) {
      yield r'stop_client_event_id';
      yield serializers.serialize(
        object.stopClientEventId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'seal_version';
    yield serializers.serialize(
      object.sealVersion,
      specifiedType: const FullType(int),
    );
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.commitToken != null) {
      yield r'commit_token';
      yield serializers.serialize(
        object.commitToken,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2SessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2SessionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'session_server_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionServerId = valueDes;
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'client_session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientSessionId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        case r'stop_server_pending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.stopServerPending = valueDes;
          break;
        case r'stop_client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.stopClientEventId = valueDes;
          break;
        case r'seal_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sealVersion = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.timezone = valueDes;
          break;
        case r'commit_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.commitToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2SessionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2SessionResponseBuilder();
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

