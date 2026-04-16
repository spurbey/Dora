//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_payload_chunk_response.g.dart';

/// V2PublishPayloadChunkResponse
///
/// Properties:
/// * [publishToken] 
/// * [manifestStatus] 
/// * [manifestPhase] 
/// * [chunkIndex] 
/// * [totalChunks] 
/// * [acceptedTotalBytes] 
@BuiltValue()
abstract class V2PublishPayloadChunkResponse implements Built<V2PublishPayloadChunkResponse, V2PublishPayloadChunkResponseBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'manifest_status')
  V2PublishPayloadChunkResponseManifestStatusEnum get manifestStatus;
  // enum manifestStatusEnum {  started,  failed_retryable,  failed_terminal,  idempotency_conflict,  committed,  };

  @BuiltValueField(wireName: r'manifest_phase')
  V2PublishPayloadChunkResponseManifestPhaseEnum get manifestPhase;
  // enum manifestPhaseEnum {  start_received,  media_verified,  chunks_complete,  raw_ingest_completed,  projection_compiled,  finalized,  };

  @BuiltValueField(wireName: r'chunk_index')
  int get chunkIndex;

  @BuiltValueField(wireName: r'total_chunks')
  int get totalChunks;

  @BuiltValueField(wireName: r'accepted_total_bytes')
  int get acceptedTotalBytes;

  V2PublishPayloadChunkResponse._();

  factory V2PublishPayloadChunkResponse([void updates(V2PublishPayloadChunkResponseBuilder b)]) = _$V2PublishPayloadChunkResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishPayloadChunkResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishPayloadChunkResponse> get serializer => _$V2PublishPayloadChunkResponseSerializer();
}

class _$V2PublishPayloadChunkResponseSerializer implements PrimitiveSerializer<V2PublishPayloadChunkResponse> {
  @override
  final Iterable<Type> types = const [V2PublishPayloadChunkResponse, _$V2PublishPayloadChunkResponse];

  @override
  final String wireName = r'V2PublishPayloadChunkResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishPayloadChunkResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'publish_token';
    yield serializers.serialize(
      object.publishToken,
      specifiedType: const FullType(String),
    );
    yield r'manifest_status';
    yield serializers.serialize(
      object.manifestStatus,
      specifiedType: const FullType(V2PublishPayloadChunkResponseManifestStatusEnum),
    );
    yield r'manifest_phase';
    yield serializers.serialize(
      object.manifestPhase,
      specifiedType: const FullType(V2PublishPayloadChunkResponseManifestPhaseEnum),
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
    yield r'accepted_total_bytes';
    yield serializers.serialize(
      object.acceptedTotalBytes,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishPayloadChunkResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishPayloadChunkResponseBuilder result,
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
        case r'manifest_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(V2PublishPayloadChunkResponseManifestStatusEnum),
          ) as V2PublishPayloadChunkResponseManifestStatusEnum;
          result.manifestStatus = valueDes;
          break;
        case r'manifest_phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(V2PublishPayloadChunkResponseManifestPhaseEnum),
          ) as V2PublishPayloadChunkResponseManifestPhaseEnum;
          result.manifestPhase = valueDes;
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
        case r'accepted_total_bytes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedTotalBytes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishPayloadChunkResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishPayloadChunkResponseBuilder();
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

class V2PublishPayloadChunkResponseManifestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'started')
  static const V2PublishPayloadChunkResponseManifestStatusEnum started = _$v2PublishPayloadChunkResponseManifestStatusEnum_started;
  @BuiltValueEnumConst(wireName: r'failed_retryable')
  static const V2PublishPayloadChunkResponseManifestStatusEnum failedRetryable = _$v2PublishPayloadChunkResponseManifestStatusEnum_failedRetryable;
  @BuiltValueEnumConst(wireName: r'failed_terminal')
  static const V2PublishPayloadChunkResponseManifestStatusEnum failedTerminal = _$v2PublishPayloadChunkResponseManifestStatusEnum_failedTerminal;
  @BuiltValueEnumConst(wireName: r'idempotency_conflict')
  static const V2PublishPayloadChunkResponseManifestStatusEnum idempotencyConflict = _$v2PublishPayloadChunkResponseManifestStatusEnum_idempotencyConflict;
  @BuiltValueEnumConst(wireName: r'committed')
  static const V2PublishPayloadChunkResponseManifestStatusEnum committed = _$v2PublishPayloadChunkResponseManifestStatusEnum_committed;

  static Serializer<V2PublishPayloadChunkResponseManifestStatusEnum> get serializer => _$v2PublishPayloadChunkResponseManifestStatusEnumSerializer;

  const V2PublishPayloadChunkResponseManifestStatusEnum._(String name): super(name);

  static BuiltSet<V2PublishPayloadChunkResponseManifestStatusEnum> get values => _$v2PublishPayloadChunkResponseManifestStatusEnumValues;
  static V2PublishPayloadChunkResponseManifestStatusEnum valueOf(String name) => _$v2PublishPayloadChunkResponseManifestStatusEnumValueOf(name);
}

class V2PublishPayloadChunkResponseManifestPhaseEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'start_received')
  static const V2PublishPayloadChunkResponseManifestPhaseEnum startReceived = _$v2PublishPayloadChunkResponseManifestPhaseEnum_startReceived;
  @BuiltValueEnumConst(wireName: r'media_verified')
  static const V2PublishPayloadChunkResponseManifestPhaseEnum mediaVerified = _$v2PublishPayloadChunkResponseManifestPhaseEnum_mediaVerified;
  @BuiltValueEnumConst(wireName: r'chunks_complete')
  static const V2PublishPayloadChunkResponseManifestPhaseEnum chunksComplete = _$v2PublishPayloadChunkResponseManifestPhaseEnum_chunksComplete;
  @BuiltValueEnumConst(wireName: r'raw_ingest_completed')
  static const V2PublishPayloadChunkResponseManifestPhaseEnum rawIngestCompleted = _$v2PublishPayloadChunkResponseManifestPhaseEnum_rawIngestCompleted;
  @BuiltValueEnumConst(wireName: r'projection_compiled')
  static const V2PublishPayloadChunkResponseManifestPhaseEnum projectionCompiled = _$v2PublishPayloadChunkResponseManifestPhaseEnum_projectionCompiled;
  @BuiltValueEnumConst(wireName: r'finalized')
  static const V2PublishPayloadChunkResponseManifestPhaseEnum finalized = _$v2PublishPayloadChunkResponseManifestPhaseEnum_finalized;

  static Serializer<V2PublishPayloadChunkResponseManifestPhaseEnum> get serializer => _$v2PublishPayloadChunkResponseManifestPhaseEnumSerializer;

  const V2PublishPayloadChunkResponseManifestPhaseEnum._(String name): super(name);

  static BuiltSet<V2PublishPayloadChunkResponseManifestPhaseEnum> get values => _$v2PublishPayloadChunkResponseManifestPhaseEnumValues;
  static V2PublishPayloadChunkResponseManifestPhaseEnum valueOf(String name) => _$v2PublishPayloadChunkResponseManifestPhaseEnumValueOf(name);
}

