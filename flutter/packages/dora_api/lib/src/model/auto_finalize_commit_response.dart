//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auto_finalize_commit_response.g.dart';

/// AutoFinalizeCommitResponse
///
/// Properties:
/// * [tripId] 
/// * [status] 
/// * [trackingEnabled] 
/// * [trackingStartedAt] 
/// * [trackingEndedAt] 
/// * [idempotencyReplayed] 
@BuiltValue()
abstract class AutoFinalizeCommitResponse implements Built<AutoFinalizeCommitResponse, AutoFinalizeCommitResponseBuilder> {
  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'status')
  AutoFinalizeCommitResponseStatusEnum get status;
  // enum statusEnum {  planned,  tracking_active,  tracking_paused,  review_pending,  completed,  shared,  };

  @BuiltValueField(wireName: r'tracking_enabled')
  bool get trackingEnabled;

  @BuiltValueField(wireName: r'tracking_started_at')
  DateTime? get trackingStartedAt;

  @BuiltValueField(wireName: r'tracking_ended_at')
  DateTime? get trackingEndedAt;

  @BuiltValueField(wireName: r'idempotency_replayed')
  bool get idempotencyReplayed;

  AutoFinalizeCommitResponse._();

  factory AutoFinalizeCommitResponse([void updates(AutoFinalizeCommitResponseBuilder b)]) = _$AutoFinalizeCommitResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AutoFinalizeCommitResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AutoFinalizeCommitResponse> get serializer => _$AutoFinalizeCommitResponseSerializer();
}

class _$AutoFinalizeCommitResponseSerializer implements PrimitiveSerializer<AutoFinalizeCommitResponse> {
  @override
  final Iterable<Type> types = const [AutoFinalizeCommitResponse, _$AutoFinalizeCommitResponse];

  @override
  final String wireName = r'AutoFinalizeCommitResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AutoFinalizeCommitResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AutoFinalizeCommitResponseStatusEnum),
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
    yield r'idempotency_replayed';
    yield serializers.serialize(
      object.idempotencyReplayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AutoFinalizeCommitResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AutoFinalizeCommitResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AutoFinalizeCommitResponseStatusEnum),
          ) as AutoFinalizeCommitResponseStatusEnum;
          result.status = valueDes;
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
        case r'idempotency_replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.idempotencyReplayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AutoFinalizeCommitResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AutoFinalizeCommitResponseBuilder();
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

class AutoFinalizeCommitResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'planned')
  static const AutoFinalizeCommitResponseStatusEnum planned = _$autoFinalizeCommitResponseStatusEnum_planned;
  @BuiltValueEnumConst(wireName: r'tracking_active')
  static const AutoFinalizeCommitResponseStatusEnum trackingActive = _$autoFinalizeCommitResponseStatusEnum_trackingActive;
  @BuiltValueEnumConst(wireName: r'tracking_paused')
  static const AutoFinalizeCommitResponseStatusEnum trackingPaused = _$autoFinalizeCommitResponseStatusEnum_trackingPaused;
  @BuiltValueEnumConst(wireName: r'review_pending')
  static const AutoFinalizeCommitResponseStatusEnum reviewPending = _$autoFinalizeCommitResponseStatusEnum_reviewPending;
  @BuiltValueEnumConst(wireName: r'completed')
  static const AutoFinalizeCommitResponseStatusEnum completed = _$autoFinalizeCommitResponseStatusEnum_completed;
  @BuiltValueEnumConst(wireName: r'shared')
  static const AutoFinalizeCommitResponseStatusEnum shared = _$autoFinalizeCommitResponseStatusEnum_shared;

  static Serializer<AutoFinalizeCommitResponseStatusEnum> get serializer => _$autoFinalizeCommitResponseStatusEnumSerializer;

  const AutoFinalizeCommitResponseStatusEnum._(String name): super(name);

  static BuiltSet<AutoFinalizeCommitResponseStatusEnum> get values => _$autoFinalizeCommitResponseStatusEnumValues;
  static AutoFinalizeCommitResponseStatusEnum valueOf(String name) => _$autoFinalizeCommitResponseStatusEnumValueOf(name);
}

