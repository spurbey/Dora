//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_session_response.g.dart';

/// TrackingSessionResponse
///
/// Properties:
/// * [sessionId] 
/// * [tripId] 
/// * [userId] 
/// * [state] 
/// * [clientSessionId] 
/// * [startedAt] 
/// * [pausedAt] 
/// * [resumedAt] 
/// * [endedAt] 
/// * [abandonedAt] 
/// * [lastPointAt] 
/// * [timezone] 
/// * [deviceContext] 
/// * [tripStatus] 
/// * [trackingEnabled] 
/// * [trackingStartedAt] 
/// * [trackingEndedAt] 
@BuiltValue()
abstract class TrackingSessionResponse implements Built<TrackingSessionResponse, TrackingSessionResponseBuilder> {
  @BuiltValueField(wireName: r'session_id')
  String get sessionId;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'state')
  TrackingSessionResponseStateEnum get state;
  // enum stateEnum {  active,  paused,  ended,  abandoned,  };

  @BuiltValueField(wireName: r'client_session_id')
  String get clientSessionId;

  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'paused_at')
  DateTime? get pausedAt;

  @BuiltValueField(wireName: r'resumed_at')
  DateTime? get resumedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  @BuiltValueField(wireName: r'abandoned_at')
  DateTime? get abandonedAt;

  @BuiltValueField(wireName: r'last_point_at')
  DateTime? get lastPointAt;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'device_context')
  JsonObject? get deviceContext;

  @BuiltValueField(wireName: r'trip_status')
  TrackingSessionResponseTripStatusEnum get tripStatus;
  // enum tripStatusEnum {  planned,  tracking_active,  tracking_paused,  review_pending,  completed,  shared,  };

  @BuiltValueField(wireName: r'tracking_enabled')
  bool get trackingEnabled;

  @BuiltValueField(wireName: r'tracking_started_at')
  DateTime? get trackingStartedAt;

  @BuiltValueField(wireName: r'tracking_ended_at')
  DateTime? get trackingEndedAt;

  TrackingSessionResponse._();

  factory TrackingSessionResponse([void updates(TrackingSessionResponseBuilder b)]) = _$TrackingSessionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingSessionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingSessionResponse> get serializer => _$TrackingSessionResponseSerializer();
}

class _$TrackingSessionResponseSerializer implements PrimitiveSerializer<TrackingSessionResponse> {
  @override
  final Iterable<Type> types = const [TrackingSessionResponse, _$TrackingSessionResponse];

  @override
  final String wireName = r'TrackingSessionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'session_id';
    yield serializers.serialize(
      object.sessionId,
      specifiedType: const FullType(String),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'state';
    yield serializers.serialize(
      object.state,
      specifiedType: const FullType(TrackingSessionResponseStateEnum),
    );
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
    if (object.pausedAt != null) {
      yield r'paused_at';
      yield serializers.serialize(
        object.pausedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.resumedAt != null) {
      yield r'resumed_at';
      yield serializers.serialize(
        object.resumedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.endedAt != null) {
      yield r'ended_at';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.abandonedAt != null) {
      yield r'abandoned_at';
      yield serializers.serialize(
        object.abandonedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.lastPointAt != null) {
      yield r'last_point_at';
      yield serializers.serialize(
        object.lastPointAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
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
    yield r'trip_status';
    yield serializers.serialize(
      object.tripStatus,
      specifiedType: const FullType(TrackingSessionResponseTripStatusEnum),
    );
    yield r'tracking_enabled';
    yield serializers.serialize(
      object.trackingEnabled,
      specifiedType: const FullType(bool),
    );
    if (object.trackingStartedAt != null) {
      yield r'tracking_started_at';
      yield serializers.serialize(
        object.trackingStartedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.trackingEndedAt != null) {
      yield r'tracking_ended_at';
      yield serializers.serialize(
        object.trackingEndedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingSessionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingSessionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackingSessionResponseStateEnum),
          ) as TrackingSessionResponseStateEnum;
          result.state = valueDes;
          break;
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
        case r'paused_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.pausedAt = valueDes;
          break;
        case r'resumed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resumedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        case r'abandoned_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.abandonedAt = valueDes;
          break;
        case r'last_point_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastPointAt = valueDes;
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
        case r'trip_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackingSessionResponseTripStatusEnum),
          ) as TrackingSessionResponseTripStatusEnum;
          result.tripStatus = valueDes;
          break;
        case r'tracking_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.trackingEnabled = valueDes;
          break;
        case r'tracking_started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.trackingStartedAt = valueDes;
          break;
        case r'tracking_ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.trackingEndedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingSessionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingSessionResponseBuilder();
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

class TrackingSessionResponseStateEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'active')
  static const TrackingSessionResponseStateEnum active = _$trackingSessionResponseStateEnum_active;
  @BuiltValueEnumConst(wireName: r'paused')
  static const TrackingSessionResponseStateEnum paused = _$trackingSessionResponseStateEnum_paused;
  @BuiltValueEnumConst(wireName: r'ended')
  static const TrackingSessionResponseStateEnum ended = _$trackingSessionResponseStateEnum_ended;
  @BuiltValueEnumConst(wireName: r'abandoned')
  static const TrackingSessionResponseStateEnum abandoned = _$trackingSessionResponseStateEnum_abandoned;

  static Serializer<TrackingSessionResponseStateEnum> get serializer => _$trackingSessionResponseStateEnumSerializer;

  const TrackingSessionResponseStateEnum._(String name): super(name);

  static BuiltSet<TrackingSessionResponseStateEnum> get values => _$trackingSessionResponseStateEnumValues;
  static TrackingSessionResponseStateEnum valueOf(String name) => _$trackingSessionResponseStateEnumValueOf(name);
}

class TrackingSessionResponseTripStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'planned')
  static const TrackingSessionResponseTripStatusEnum planned = _$trackingSessionResponseTripStatusEnum_planned;
  @BuiltValueEnumConst(wireName: r'tracking_active')
  static const TrackingSessionResponseTripStatusEnum trackingActive = _$trackingSessionResponseTripStatusEnum_trackingActive;
  @BuiltValueEnumConst(wireName: r'tracking_paused')
  static const TrackingSessionResponseTripStatusEnum trackingPaused = _$trackingSessionResponseTripStatusEnum_trackingPaused;
  @BuiltValueEnumConst(wireName: r'review_pending')
  static const TrackingSessionResponseTripStatusEnum reviewPending = _$trackingSessionResponseTripStatusEnum_reviewPending;
  @BuiltValueEnumConst(wireName: r'completed')
  static const TrackingSessionResponseTripStatusEnum completed = _$trackingSessionResponseTripStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'shared')
  static const TrackingSessionResponseTripStatusEnum shared = _$trackingSessionResponseTripStatusEnum_shared;

  static Serializer<TrackingSessionResponseTripStatusEnum> get serializer => _$trackingSessionResponseTripStatusEnumSerializer;

  const TrackingSessionResponseTripStatusEnum._(String name): super(name);

  static BuiltSet<TrackingSessionResponseTripStatusEnum> get values => _$trackingSessionResponseTripStatusEnumValues;
  static TrackingSessionResponseTripStatusEnum valueOf(String name) => _$trackingSessionResponseTripStatusEnumValueOf(name);
}

