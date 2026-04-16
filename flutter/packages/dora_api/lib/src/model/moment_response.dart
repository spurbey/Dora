//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_response.g.dart';

/// MomentResponse
///
/// Properties:
/// * [id] 
/// * [tripId] 
/// * [userId] 
/// * [candidateId] 
/// * [linkedTripPlaceId] 
/// * [source_] 
/// * [confidence] 
/// * [capturedAt] 
/// * [latitude] 
/// * [longitude] 
/// * [note] 
/// * [mediaRefs] 
/// * [extraPayload] 
/// * [lockedFields] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class MomentResponse implements Built<MomentResponse, MomentResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'candidate_id')
  String? get candidateId;

  @BuiltValueField(wireName: r'linked_trip_place_id')
  String? get linkedTripPlaceId;

  @BuiltValueField(wireName: r'source')
  MomentResponseSource_Enum get source_;
  // enum source_Enum {  manual,  auto,  edited_auto,  };

  @BuiltValueField(wireName: r'confidence')
  num? get confidence;

  @BuiltValueField(wireName: r'captured_at')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'media_refs')
  BuiltList<BuiltMap<String, JsonObject?>>? get mediaRefs;

  @BuiltValueField(wireName: r'extra_payload')
  BuiltMap<String, JsonObject?>? get extraPayload;

  @BuiltValueField(wireName: r'locked_fields')
  BuiltMap<String, JsonObject?>? get lockedFields;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  MomentResponse._();

  factory MomentResponse([void updates(MomentResponseBuilder b)]) = _$MomentResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentResponse> get serializer => _$MomentResponseSerializer();
}

class _$MomentResponseSerializer implements PrimitiveSerializer<MomentResponse> {
  @override
  final Iterable<Type> types = const [MomentResponse, _$MomentResponse];

  @override
  final String wireName = r'MomentResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentResponse object, {
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
    if (object.candidateId != null) {
      yield r'candidate_id';
      yield serializers.serialize(
        object.candidateId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.linkedTripPlaceId != null) {
      yield r'linked_trip_place_id';
      yield serializers.serialize(
        object.linkedTripPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(MomentResponseSource_Enum),
    );
    if (object.confidence != null) {
      yield r'confidence';
      yield serializers.serialize(
        object.confidence,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'captured_at';
    yield serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.latitude != null) {
      yield r'latitude';
      yield serializers.serialize(
        object.latitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.longitude != null) {
      yield r'longitude';
      yield serializers.serialize(
        object.longitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.mediaRefs != null) {
      yield r'media_refs';
      yield serializers.serialize(
        object.mediaRefs,
        specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
      );
    }
    if (object.extraPayload != null) {
      yield r'extra_payload';
      yield serializers.serialize(
        object.extraPayload,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    if (object.lockedFields != null) {
      yield r'locked_fields';
      yield serializers.serialize(
        object.lockedFields,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
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
    MomentResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentResponseBuilder result,
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
        case r'candidate_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.candidateId = valueDes;
          break;
        case r'linked_trip_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.linkedTripPlaceId = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MomentResponseSource_Enum),
          ) as MomentResponseSource_Enum;
          result.source_ = valueDes;
          break;
        case r'confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.confidence = valueDes;
          break;
        case r'captured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.capturedAt = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.longitude = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'media_refs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
          result.mediaRefs.replace(valueDes);
          break;
        case r'extra_payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.extraPayload.replace(valueDes);
          break;
        case r'locked_fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.lockedFields.replace(valueDes);
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
  MomentResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentResponseBuilder();
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

class MomentResponseSource_Enum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'manual')
  static const MomentResponseSource_Enum manual = _$momentResponseSourceEnum_manual;
  @BuiltValueEnumConst(wireName: r'auto')
  static const MomentResponseSource_Enum auto = _$momentResponseSourceEnum_auto;
  @BuiltValueEnumConst(wireName: r'edited_auto')
  static const MomentResponseSource_Enum editedAuto = _$momentResponseSourceEnum_editedAuto;

  static Serializer<MomentResponseSource_Enum> get serializer => _$momentResponseSourceEnumSerializer;

  const MomentResponseSource_Enum._(String name): super(name);

  static BuiltSet<MomentResponseSource_Enum> get values => _$momentResponseSourceEnumValues;
  static MomentResponseSource_Enum valueOf(String name) => _$momentResponseSourceEnumValueOf(name);
}

