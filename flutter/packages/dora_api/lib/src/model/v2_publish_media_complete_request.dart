//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/v2_uploaded_media_ref.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_media_complete_request.g.dart';

/// V2PublishMediaCompleteRequest
///
/// Properties:
/// * [publishToken] 
/// * [clientJobId] 
/// * [schemaVersion] 
/// * [uploadedMedia] 
@BuiltValue()
abstract class V2PublishMediaCompleteRequest implements Built<V2PublishMediaCompleteRequest, V2PublishMediaCompleteRequestBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'client_job_id')
  String get clientJobId;

  @BuiltValueField(wireName: r'schema_version')
  int get schemaVersion;

  @BuiltValueField(wireName: r'uploaded_media')
  BuiltList<V2UploadedMediaRef>? get uploadedMedia;

  V2PublishMediaCompleteRequest._();

  factory V2PublishMediaCompleteRequest([void updates(V2PublishMediaCompleteRequestBuilder b)]) = _$V2PublishMediaCompleteRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishMediaCompleteRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishMediaCompleteRequest> get serializer => _$V2PublishMediaCompleteRequestSerializer();
}

class _$V2PublishMediaCompleteRequestSerializer implements PrimitiveSerializer<V2PublishMediaCompleteRequest> {
  @override
  final Iterable<Type> types = const [V2PublishMediaCompleteRequest, _$V2PublishMediaCompleteRequest];

  @override
  final String wireName = r'V2PublishMediaCompleteRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishMediaCompleteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'publish_token';
    yield serializers.serialize(
      object.publishToken,
      specifiedType: const FullType(String),
    );
    yield r'client_job_id';
    yield serializers.serialize(
      object.clientJobId,
      specifiedType: const FullType(String),
    );
    yield r'schema_version';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType: const FullType(int),
    );
    if (object.uploadedMedia != null) {
      yield r'uploaded_media';
      yield serializers.serialize(
        object.uploadedMedia,
        specifiedType: const FullType(BuiltList, [FullType(V2UploadedMediaRef)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishMediaCompleteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishMediaCompleteRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'publish_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publishToken = valueDes;
          break;
        case r'client_job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientJobId = valueDes;
          break;
        case r'schema_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.schemaVersion = valueDes;
          break;
        case r'uploaded_media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(V2UploadedMediaRef)]),
          ) as BuiltList<V2UploadedMediaRef>;
          result.uploadedMedia.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishMediaCompleteRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishMediaCompleteRequestBuilder();
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

