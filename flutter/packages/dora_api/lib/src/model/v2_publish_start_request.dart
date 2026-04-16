//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/v2_publish_summary.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/v2_media_manifest_item.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_start_request.g.dart';

/// V2PublishStartRequest
///
/// Properties:
/// * [clientJobId] 
/// * [schemaVersion] 
/// * [publishSummary] 
/// * [mediaManifest] 
/// * [mediaManifestDigest] 
@BuiltValue()
abstract class V2PublishStartRequest implements Built<V2PublishStartRequest, V2PublishStartRequestBuilder> {
  @BuiltValueField(wireName: r'client_job_id')
  String get clientJobId;

  @BuiltValueField(wireName: r'schema_version')
  int get schemaVersion;

  @BuiltValueField(wireName: r'publish_summary')
  V2PublishSummary get publishSummary;

  @BuiltValueField(wireName: r'media_manifest')
  BuiltList<V2MediaManifestItem>? get mediaManifest;

  @BuiltValueField(wireName: r'media_manifest_digest')
  String get mediaManifestDigest;

  V2PublishStartRequest._();

  factory V2PublishStartRequest([void updates(V2PublishStartRequestBuilder b)]) = _$V2PublishStartRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishStartRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishStartRequest> get serializer => _$V2PublishStartRequestSerializer();
}

class _$V2PublishStartRequestSerializer implements PrimitiveSerializer<V2PublishStartRequest> {
  @override
  final Iterable<Type> types = const [V2PublishStartRequest, _$V2PublishStartRequest];

  @override
  final String wireName = r'V2PublishStartRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'publish_summary';
    yield serializers.serialize(
      object.publishSummary,
      specifiedType: const FullType(V2PublishSummary),
    );
    if (object.mediaManifest != null) {
      yield r'media_manifest';
      yield serializers.serialize(
        object.mediaManifest,
        specifiedType: const FullType(BuiltList, [FullType(V2MediaManifestItem)]),
      );
    }
    yield r'media_manifest_digest';
    yield serializers.serialize(
      object.mediaManifestDigest,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishStartRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'publish_summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(V2PublishSummary),
          ) as V2PublishSummary;
          result.publishSummary.replace(valueDes);
          break;
        case r'media_manifest':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(V2MediaManifestItem)]),
          ) as BuiltList<V2MediaManifestItem>;
          result.mediaManifest.replace(valueDes);
          break;
        case r'media_manifest_digest':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaManifestDigest = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishStartRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishStartRequestBuilder();
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

