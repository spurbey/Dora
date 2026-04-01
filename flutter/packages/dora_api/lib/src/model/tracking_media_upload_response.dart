//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_media_upload_response.g.dart';

/// TrackingMediaUploadResponse
///
/// Properties:
/// * [tripId] 
/// * [uploadRef] 
/// * [mimeType] 
/// * [fileSizeBytes] 
@BuiltValue()
abstract class TrackingMediaUploadResponse implements Built<TrackingMediaUploadResponse, TrackingMediaUploadResponseBuilder> {
  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'upload_ref')
  String get uploadRef;

  @BuiltValueField(wireName: r'mime_type')
  String? get mimeType;

  @BuiltValueField(wireName: r'file_size_bytes')
  int get fileSizeBytes;

  TrackingMediaUploadResponse._();

  factory TrackingMediaUploadResponse([void updates(TrackingMediaUploadResponseBuilder b)]) = _$TrackingMediaUploadResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingMediaUploadResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingMediaUploadResponse> get serializer => _$TrackingMediaUploadResponseSerializer();
}

class _$TrackingMediaUploadResponseSerializer implements PrimitiveSerializer<TrackingMediaUploadResponse> {
  @override
  final Iterable<Type> types = const [TrackingMediaUploadResponse, _$TrackingMediaUploadResponse];

  @override
  final String wireName = r'TrackingMediaUploadResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingMediaUploadResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
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
    yield r'file_size_bytes';
    yield serializers.serialize(
      object.fileSizeBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingMediaUploadResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingMediaUploadResponseBuilder result,
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
            specifiedType: const FullType(int),
          ) as int;
          result.fileSizeBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingMediaUploadResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingMediaUploadResponseBuilder();
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

