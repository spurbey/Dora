//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dora_api/src/model/moment_location.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'moment_create_request.g.dart';

/// MomentCreateRequest
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
abstract class MomentCreateRequest implements Built<MomentCreateRequest, MomentCreateRequestBuilder> {
  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'captured_at')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'location')
  MomentLocation? get location;

  @BuiltValueField(wireName: r'media_refs')
  BuiltList<BuiltMap<String, JsonObject?>>? get mediaRefs;

  @BuiltValueField(wireName: r'linked_trip_place_id')
  String? get linkedTripPlaceId;

  @BuiltValueField(wireName: r'extra_payload')
  BuiltMap<String, JsonObject?>? get extraPayload;

  MomentCreateRequest._();

  factory MomentCreateRequest([void updates(MomentCreateRequestBuilder b)]) = _$MomentCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MomentCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MomentCreateRequest> get serializer => _$MomentCreateRequestSerializer();
}

class _$MomentCreateRequestSerializer implements PrimitiveSerializer<MomentCreateRequest> {
  @override
  final Iterable<Type> types = const [MomentCreateRequest, _$MomentCreateRequest];

  @override
  final String wireName = r'MomentCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MomentCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'captured_at';
    yield serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType(DateTime),
    );
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
        specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
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
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MomentCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MomentCreateRequestBuilder result,
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
            specifiedType: const FullType(DateTime),
          ) as DateTime;
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
            specifiedType: const FullType(BuiltList, [FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)])]),
          ) as BuiltList<BuiltMap<String, JsonObject?>>;
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
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.extraPayload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MomentCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MomentCreateRequestBuilder();
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

