//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_media_complete_response.g.dart';

/// V2PublishMediaCompleteResponse
///
/// Properties:
/// * [publishToken] 
/// * [manifestStatus] 
/// * [manifestPhase] 
/// * [acceptedMediaCount] 
@BuiltValue()
abstract class V2PublishMediaCompleteResponse implements Built<V2PublishMediaCompleteResponse, V2PublishMediaCompleteResponseBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'manifest_status')
  V2PublishMediaCompleteResponseManifestStatusEnum get manifestStatus;
  // enum manifestStatusEnum {  started,  failed_retryable,  failed_terminal,  idempotency_conflict,  committed,  };

  @BuiltValueField(wireName: r'manifest_phase')
  V2PublishMediaCompleteResponseManifestPhaseEnum get manifestPhase;
  // enum manifestPhaseEnum {  start_received,  media_verified,  chunks_complete,  raw_ingest_completed,  projection_compiled,  finalized,  };

  @BuiltValueField(wireName: r'accepted_media_count')
  int get acceptedMediaCount;

  V2PublishMediaCompleteResponse._();

  factory V2PublishMediaCompleteResponse([void updates(V2PublishMediaCompleteResponseBuilder b)]) = _$V2PublishMediaCompleteResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishMediaCompleteResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishMediaCompleteResponse> get serializer => _$V2PublishMediaCompleteResponseSerializer();
}

class _$V2PublishMediaCompleteResponseSerializer implements PrimitiveSerializer<V2PublishMediaCompleteResponse> {
  @override
  final Iterable<Type> types = const [V2PublishMediaCompleteResponse, _$V2PublishMediaCompleteResponse];

  @override
  final String wireName = r'V2PublishMediaCompleteResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishMediaCompleteResponse object, {
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
      specifiedType: const FullType(V2PublishMediaCompleteResponseManifestStatusEnum),
    );
    yield r'manifest_phase';
    yield serializers.serialize(
      object.manifestPhase,
      specifiedType: const FullType(V2PublishMediaCompleteResponseManifestPhaseEnum),
    );
    yield r'accepted_media_count';
    yield serializers.serialize(
      object.acceptedMediaCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishMediaCompleteResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishMediaCompleteResponseBuilder result,
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
            specifiedType: const FullType(V2PublishMediaCompleteResponseManifestStatusEnum),
          ) as V2PublishMediaCompleteResponseManifestStatusEnum;
          result.manifestStatus = valueDes;
          break;
        case r'manifest_phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(V2PublishMediaCompleteResponseManifestPhaseEnum),
          ) as V2PublishMediaCompleteResponseManifestPhaseEnum;
          result.manifestPhase = valueDes;
          break;
        case r'accepted_media_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedMediaCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishMediaCompleteResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishMediaCompleteResponseBuilder();
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

class V2PublishMediaCompleteResponseManifestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'started')
  static const V2PublishMediaCompleteResponseManifestStatusEnum started = _$v2PublishMediaCompleteResponseManifestStatusEnum_started;
  @BuiltValueEnumConst(wireName: r'failed_retryable')
  static const V2PublishMediaCompleteResponseManifestStatusEnum failedRetryable = _$v2PublishMediaCompleteResponseManifestStatusEnum_failedRetryable;
  @BuiltValueEnumConst(wireName: r'failed_terminal')
  static const V2PublishMediaCompleteResponseManifestStatusEnum failedTerminal = _$v2PublishMediaCompleteResponseManifestStatusEnum_failedTerminal;
  @BuiltValueEnumConst(wireName: r'idempotency_conflict')
  static const V2PublishMediaCompleteResponseManifestStatusEnum idempotencyConflict = _$v2PublishMediaCompleteResponseManifestStatusEnum_idempotencyConflict;
  @BuiltValueEnumConst(wireName: r'committed')
  static const V2PublishMediaCompleteResponseManifestStatusEnum committed = _$v2PublishMediaCompleteResponseManifestStatusEnum_committed;

  static Serializer<V2PublishMediaCompleteResponseManifestStatusEnum> get serializer => _$v2PublishMediaCompleteResponseManifestStatusEnumSerializer;

  const V2PublishMediaCompleteResponseManifestStatusEnum._(String name): super(name);

  static BuiltSet<V2PublishMediaCompleteResponseManifestStatusEnum> get values => _$v2PublishMediaCompleteResponseManifestStatusEnumValues;
  static V2PublishMediaCompleteResponseManifestStatusEnum valueOf(String name) => _$v2PublishMediaCompleteResponseManifestStatusEnumValueOf(name);
}

class V2PublishMediaCompleteResponseManifestPhaseEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'start_received')
  static const V2PublishMediaCompleteResponseManifestPhaseEnum startReceived = _$v2PublishMediaCompleteResponseManifestPhaseEnum_startReceived;
  @BuiltValueEnumConst(wireName: r'media_verified')
  static const V2PublishMediaCompleteResponseManifestPhaseEnum mediaVerified = _$v2PublishMediaCompleteResponseManifestPhaseEnum_mediaVerified;
  @BuiltValueEnumConst(wireName: r'chunks_complete')
  static const V2PublishMediaCompleteResponseManifestPhaseEnum chunksComplete = _$v2PublishMediaCompleteResponseManifestPhaseEnum_chunksComplete;
  @BuiltValueEnumConst(wireName: r'raw_ingest_completed')
  static const V2PublishMediaCompleteResponseManifestPhaseEnum rawIngestCompleted = _$v2PublishMediaCompleteResponseManifestPhaseEnum_rawIngestCompleted;
  @BuiltValueEnumConst(wireName: r'projection_compiled')
  static const V2PublishMediaCompleteResponseManifestPhaseEnum projectionCompiled = _$v2PublishMediaCompleteResponseManifestPhaseEnum_projectionCompiled;
  @BuiltValueEnumConst(wireName: r'finalized')
  static const V2PublishMediaCompleteResponseManifestPhaseEnum finalized = _$v2PublishMediaCompleteResponseManifestPhaseEnum_finalized;

  static Serializer<V2PublishMediaCompleteResponseManifestPhaseEnum> get serializer => _$v2PublishMediaCompleteResponseManifestPhaseEnumSerializer;

  const V2PublishMediaCompleteResponseManifestPhaseEnum._(String name): super(name);

  static BuiltSet<V2PublishMediaCompleteResponseManifestPhaseEnum> get values => _$v2PublishMediaCompleteResponseManifestPhaseEnumValues;
  static V2PublishMediaCompleteResponseManifestPhaseEnum valueOf(String name) => _$v2PublishMediaCompleteResponseManifestPhaseEnumValueOf(name);
}

