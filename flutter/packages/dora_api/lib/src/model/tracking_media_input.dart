//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_media_input.g.dart';

/// TrackingMediaInput
///
/// Properties:
/// * [clientMediaId] 
/// * [clientEventId] 
/// * [mediaType] 
/// * [bindMode] 
/// * [capturedAt] 
/// * [tripPlaceId] 
/// * [location] 
/// * [uploadRef] 
/// * [mimeType] 
/// * [fileSizeBytes] 
/// * [payload] 
@BuiltValue()
abstract class TrackingMediaInput implements Built<TrackingMediaInput, TrackingMediaInputBuilder> {
  @BuiltValueField(wireName: r'client_media_id')
  String get clientMediaId;

  @BuiltValueField(wireName: r'client_event_id')
  String get clientEventId;

  @BuiltValueField(wireName: r'media_type')
  TrackingMediaInputMediaTypeEnum get mediaType;
  // enum mediaTypeEnum {  photo,  media,  };

  @BuiltValueField(wireName: r'bind_mode')
  TrackingMediaInputBindModeEnum get bindMode;
  // enum bindModeEnum {  place,  route,  };

  @BuiltValueField(wireName: r'captured_at')
  JsonObject? get capturedAt;

  @BuiltValueField(wireName: r'trip_place_id')
  String? get tripPlaceId;

  @BuiltValueField(wireName: r'location')
  BuiltMap<String, JsonObject?>? get location;

  @BuiltValueField(wireName: r'upload_ref')
  String get uploadRef;

  @BuiltValueField(wireName: r'mime_type')
  String? get mimeType;

  @BuiltValueField(wireName: r'file_size_bytes')
  int? get fileSizeBytes;

  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?>? get payload;

  TrackingMediaInput._();

  factory TrackingMediaInput([void updates(TrackingMediaInputBuilder b)]) = _$TrackingMediaInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingMediaInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingMediaInput> get serializer => _$TrackingMediaInputSerializer();
}

class _$TrackingMediaInputSerializer implements PrimitiveSerializer<TrackingMediaInput> {
  @override
  final Iterable<Type> types = const [TrackingMediaInput, _$TrackingMediaInput];

  @override
  final String wireName = r'TrackingMediaInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingMediaInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_media_id';
    yield serializers.serialize(
      object.clientMediaId,
      specifiedType: const FullType(String),
    );
    yield r'client_event_id';
    yield serializers.serialize(
      object.clientEventId,
      specifiedType: const FullType(String),
    );
    yield r'media_type';
    yield serializers.serialize(
      object.mediaType,
      specifiedType: const FullType(TrackingMediaInputMediaTypeEnum),
    );
    yield r'bind_mode';
    yield serializers.serialize(
      object.bindMode,
      specifiedType: const FullType(TrackingMediaInputBindModeEnum),
    );
    yield r'captured_at';
    yield object.capturedAt == null ? null : serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType.nullable(JsonObject),
    );
    if (object.tripPlaceId != null) {
      yield r'trip_place_id';
      yield serializers.serialize(
        object.tripPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
    yield r'upload_ref';
    yield serializers.serialize(
      object.uploadRef,
      specifiedType: const FullType(String),
    );
    if (object.mimeType != null) {
      yield r'mime_type';
      yield serializers.serialize(
        object.mimeType,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.fileSizeBytes != null) {
      yield r'file_size_bytes';
      yield serializers.serialize(
        object.fileSizeBytes,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.payload != null) {
      yield r'payload';
      yield serializers.serialize(
        object.payload,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingMediaInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingMediaInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientMediaId = valueDes;
          break;
        case r'client_event_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientEventId = valueDes;
          break;
        case r'media_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackingMediaInputMediaTypeEnum),
          ) as TrackingMediaInputMediaTypeEnum;
          result.mediaType = valueDes;
          break;
        case r'bind_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TrackingMediaInputBindModeEnum),
          ) as TrackingMediaInputBindModeEnum;
          result.bindMode = valueDes;
          break;
        case r'captured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.capturedAt = valueDes;
          break;
        case r'trip_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripPlaceId = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.location.replace(valueDes);
          break;
        case r'upload_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.uploadRef = valueDes;
          break;
        case r'mime_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mimeType = valueDes;
          break;
        case r'file_size_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.fileSizeBytes = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingMediaInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingMediaInputBuilder();
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

class TrackingMediaInputMediaTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'photo')
  static const TrackingMediaInputMediaTypeEnum photo = _$trackingMediaInputMediaTypeEnum_photo;
  @BuiltValueEnumConst(wireName: r'media')
  static const TrackingMediaInputMediaTypeEnum media = _$trackingMediaInputMediaTypeEnum_media;

  static Serializer<TrackingMediaInputMediaTypeEnum> get serializer => _$trackingMediaInputMediaTypeEnumSerializer;

  const TrackingMediaInputMediaTypeEnum._(String name): super(name);

  static BuiltSet<TrackingMediaInputMediaTypeEnum> get values => _$trackingMediaInputMediaTypeEnumValues;
  static TrackingMediaInputMediaTypeEnum valueOf(String name) => _$trackingMediaInputMediaTypeEnumValueOf(name);
}

class TrackingMediaInputBindModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'place')
  static const TrackingMediaInputBindModeEnum place = _$trackingMediaInputBindModeEnum_place;
  @BuiltValueEnumConst(wireName: r'route')
  static const TrackingMediaInputBindModeEnum route = _$trackingMediaInputBindModeEnum_route;

  static Serializer<TrackingMediaInputBindModeEnum> get serializer => _$trackingMediaInputBindModeEnumSerializer;

  const TrackingMediaInputBindModeEnum._(String name): super(name);

  static BuiltSet<TrackingMediaInputBindModeEnum> get values => _$trackingMediaInputBindModeEnumValues;
  static TrackingMediaInputBindModeEnum valueOf(String name) => _$trackingMediaInputBindModeEnumValueOf(name);
}

