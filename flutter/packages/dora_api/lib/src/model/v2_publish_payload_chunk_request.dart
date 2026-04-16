//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_payload_chunk_request.g.dart';

/// V2PublishPayloadChunkRequest
///
/// Properties:
/// * [publishToken] 
/// * [clientJobId] 
/// * [schemaVersion] 
/// * [chunkIndex] 
/// * [totalChunks] 
/// * [chunkContentHash] 
/// * [chunkJson] 
@BuiltValue()
abstract class V2PublishPayloadChunkRequest implements Built<V2PublishPayloadChunkRequest, V2PublishPayloadChunkRequestBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'client_job_id')
  String get clientJobId;

  @BuiltValueField(wireName: r'schema_version')
  int get schemaVersion;

  @BuiltValueField(wireName: r'chunk_index')
  int get chunkIndex;

  @BuiltValueField(wireName: r'total_chunks')
  int get totalChunks;

  @BuiltValueField(wireName: r'chunk_content_hash')
  String get chunkContentHash;

  @BuiltValueField(wireName: r'chunk_json')
  String get chunkJson;

  V2PublishPayloadChunkRequest._();

  factory V2PublishPayloadChunkRequest([void updates(V2PublishPayloadChunkRequestBuilder b)]) = _$V2PublishPayloadChunkRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishPayloadChunkRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishPayloadChunkRequest> get serializer => _$V2PublishPayloadChunkRequestSerializer();
}

class _$V2PublishPayloadChunkRequestSerializer implements PrimitiveSerializer<V2PublishPayloadChunkRequest> {
  @override
  final Iterable<Type> types = const [V2PublishPayloadChunkRequest, _$V2PublishPayloadChunkRequest];

  @override
  final String wireName = r'V2PublishPayloadChunkRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishPayloadChunkRequest object, {
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
    yield r'chunk_index';
    yield serializers.serialize(
      object.chunkIndex,
      specifiedType: const FullType(int),
    );
    yield r'total_chunks';
    yield serializers.serialize(
      object.totalChunks,
      specifiedType: const FullType(int),
    );
    yield r'chunk_content_hash';
    yield serializers.serialize(
      object.chunkContentHash,
      specifiedType: const FullType(String),
    );
    yield r'chunk_json';
    yield serializers.serialize(
      object.chunkJson,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishPayloadChunkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishPayloadChunkRequestBuilder result,
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
        case r'chunk_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.chunkIndex = valueDes;
          break;
        case r'total_chunks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalChunks = valueDes;
          break;
        case r'chunk_content_hash':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.chunkContentHash = valueDes;
          break;
        case r'chunk_json':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.chunkJson = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishPayloadChunkRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishPayloadChunkRequestBuilder();
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

