//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dora_api/src/model/moment_location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_update_request.g.dart';

/// MomentUpdateRequest
///
/// Properties:
/// * [clientEventId] 
/// * [capturedAt] 
/// * [note] 
/// * [location] 
/// * [mediaRefs] 
/// * [linkedTripPlaceId] 
/// * [extraPayload] 
@BuiltValue()
abstract class MomentUpdateRequest implements Built<MomentUpdateRequest, MomentUpdateRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'captured_at')
  DateTime? get capturedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'location')
  MomentLocation? get location;

  @BuiltValueField(wireName: r'media_refs')
  BuiltList<JsonObject>? get mediaRefs;

  @BuiltValueField(wireName: r'linked_trip_place_id')
  String? get linkedTripPlaceId;

  @BuiltValueField(wireName: r'extra_payload')
  JsonObject? get extraPayload;

  MomentUpdateRequest._();

  factory MomentUpdateRequest([void updates(MomentUpdateRequestBuilder b)]) = _$MomentUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentUpdateRequest> get serializer => _$MomentUpdateRequestSerializer();
}

class _$MomentUpdateRequestSerializer implements PrimitiveSerializer<MomentUpdateRequest> {
  @override
  final Iterable<Type> types = const [MomentUpdateRequest, _$MomentUpdateRequest];

  @override
  final String wireName = r'MomentUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    if (object.capturedAt != null) {
      yield r'captured_at';
      yield serializers.serialize(
        object.capturedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType.nullable(MomentLocation),
      );
    }
    if (object.mediaRefs != null) {
      yield r'media_refs';
      yield serializers.serialize(
        object.mediaRefs,
        specifiedType: const FullType.nullable(BuiltList, [FullType(JsonObject)]),
      );
    }
    if (object.linkedTripPlaceId != null) {
      yield r'linked_trip_place_id';
      yield serializers.serialize(
        object.linkedTripPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.extraPayload != null) {
      yield r'extra_payload';
      yield serializers.serialize(
        object.extraPayload,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentUpdateRequestBuilder result,
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
        case r'captured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.capturedAt = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MomentLocation),
          ) as MomentLocation?;
          if (valueDes == null) continue;
          result.location.replace(valueDes);
          break;
        case r'media_refs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(JsonObject)]),
          ) as BuiltList<JsonObject>?;
          if (valueDes == null) continue;
          result.mediaRefs.replace(valueDes);
          break;
        case r'linked_trip_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.linkedTripPlaceId = valueDes;
          break;
        case r'extra_payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.extraPayload = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentUpdateRequestBuilder();
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

