//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkin_candidate_response.g.dart';

/// CheckinCandidateResponse
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [userId] 
/// * [sessionId] 
/// * [fingerprint] 
/// * [status] 
/// * [confidence] 
/// * [suggestedName] 
/// * [suggestedLatitude] 
/// * [suggestedLongitude] 
/// * [startedAt] 
/// * [endedAt] 
/// * [confirmedTripPlaceId] 
/// * [rejectedReason] 
/// * [snoozedUntil] 
/// * [cooldownUntil] 
/// * [payload] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class CheckinCandidateResponse implements Built<CheckinCandidateResponse, CheckinCandidateResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'session_id')
  String? get sessionId;

  @BuiltValueField(wireName: r'fingerprint')
  String get fingerprint;

  @BuiltValueField(wireName: r'status')
  CheckinCandidateResponseStatusEnum get status;
  // enum statusEnum {  pending,  confirmed,  rejected,  snoozed,  expired,  };

  @BuiltValueField(wireName: r'confidence')
  num get confidence;

  @BuiltValueField(wireName: r'suggested_name')
  String? get suggestedName;

  @BuiltValueField(wireName: r'suggested_latitude')
  num? get suggestedLatitude;

  @BuiltValueField(wireName: r'suggested_longitude')
  num? get suggestedLongitude;

  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  @BuiltValueField(wireName: r'confirmed_trip_place_id')
  String? get confirmedTripPlaceId;

  @BuiltValueField(wireName: r'rejected_reason')
  String? get rejectedReason;

  @BuiltValueField(wireName: r'snoozed_until')
  DateTime? get snoozedUntil;

  @BuiltValueField(wireName: r'cooldown_until')
  DateTime? get cooldownUntil;

  @BuiltValueField(wireName: r'payload')
  JsonObject? get payload;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  CheckinCandidateResponse._();

  factory CheckinCandidateResponse([void updates(CheckinCandidateResponseBuilder b)]) = _$CheckinCandidateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckinCandidateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckinCandidateResponse> get serializer => _$CheckinCandidateResponseSerializer();
}

class _$CheckinCandidateResponseSerializer implements PrimitiveSerializer<CheckinCandidateResponse> {
  @override
  final Iterable<Type> types = const [CheckinCandidateResponse, _$CheckinCandidateResponse];

  @override
  final String wireName = r'CheckinCandidateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckinCandidateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
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
    if (object.sessionId != null) {
      yield r'session_id';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'fingerprint';
    yield serializers.serialize(
      object.fingerprint,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CheckinCandidateResponseStatusEnum),
    );
    yield r'confidence';
    yield serializers.serialize(
      object.confidence,
      specifiedType: const FullType(num),
    );
    if (object.suggestedName != null) {
      yield r'suggested_name';
      yield serializers.serialize(
        object.suggestedName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.suggestedLatitude != null) {
      yield r'suggested_latitude';
      yield serializers.serialize(
        object.suggestedLatitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.suggestedLongitude != null) {
      yield r'suggested_longitude';
      yield serializers.serialize(
        object.suggestedLongitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
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
    if (object.confirmedTripPlaceId != null) {
      yield r'confirmed_trip_place_id';
      yield serializers.serialize(
        object.confirmedTripPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.rejectedReason != null) {
      yield r'rejected_reason';
      yield serializers.serialize(
        object.rejectedReason,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.snoozedUntil != null) {
      yield r'snoozed_until';
      yield serializers.serialize(
        object.snoozedUntil,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.cooldownUntil != null) {
      yield r'cooldown_until';
      yield serializers.serialize(
        object.cooldownUntil,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.payload != null) {
      yield r'payload';
      yield serializers.serialize(
        object.payload,
        specifiedType: const FullType(JsonObject),
      );
    }
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckinCandidateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckinCandidateResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
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
        case r'session_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sessionId = valueDes;
          break;
        case r'fingerprint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fingerprint = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CheckinCandidateResponseStatusEnum),
          ) as CheckinCandidateResponseStatusEnum;
          result.status = valueDes;
          break;
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.confidence = valueDes;
          break;
        case r'suggested_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.suggestedName = valueDes;
          break;
        case r'suggested_latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.suggestedLatitude = valueDes;
          break;
        case r'suggested_longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.suggestedLongitude = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
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
        case r'confirmed_trip_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.confirmedTripPlaceId = valueDes;
          break;
        case r'rejected_reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.rejectedReason = valueDes;
          break;
        case r'snoozed_until':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.snoozedUntil = valueDes;
          break;
        case r'cooldown_until':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.cooldownUntil = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.payload = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckinCandidateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckinCandidateResponseBuilder();
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

class CheckinCandidateResponseStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'pending')
  static const CheckinCandidateResponseStatusEnum pending = _$checkinCandidateResponseStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'confirmed')
  static const CheckinCandidateResponseStatusEnum confirmed = _$checkinCandidateResponseStatusEnum_confirmed;
  @BuiltValueEnumConst(wireName: r'rejected')
  static const CheckinCandidateResponseStatusEnum rejected = _$checkinCandidateResponseStatusEnum_rejected;
  @BuiltValueEnumConst(wireName: r'snoozed')
  static const CheckinCandidateResponseStatusEnum snoozed = _$checkinCandidateResponseStatusEnum_snoozed;
  @BuiltValueEnumConst(wireName: r'expired')
  static const CheckinCandidateResponseStatusEnum expired = _$checkinCandidateResponseStatusEnum_expired;

  static Serializer<CheckinCandidateResponseStatusEnum> get serializer => _$checkinCandidateResponseStatusEnumSerializer;

  const CheckinCandidateResponseStatusEnum._(String name): super(name);

  static BuiltSet<CheckinCandidateResponseStatusEnum> get values => _$checkinCandidateResponseStatusEnumValues;
  static CheckinCandidateResponseStatusEnum valueOf(String name) => _$checkinCandidateResponseStatusEnumValueOf(name);
}

