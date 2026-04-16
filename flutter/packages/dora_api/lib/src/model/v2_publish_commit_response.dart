//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_commit_response.g.dart';

/// V2PublishCommitResponse
///
/// Properties:
/// * [publishToken] 
/// * [manifestStatus] 
/// * [manifestPhase] 
/// * [acceptedSessionCount] 
/// * [acceptedEventCount] 
/// * [acceptedMediaCount] 
/// * [acceptedPointCount] 
/// * [compiledAt] 
@BuiltValue()
abstract class V2PublishCommitResponse implements Built<V2PublishCommitResponse, V2PublishCommitResponseBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'manifest_status')
  V2PublishCommitResponseManifestStatusEnum get manifestStatus;
  // enum manifestStatusEnum {  started,  failed_retryable,  failed_terminal,  idempotency_conflict,  committed,  };

  @BuiltValueField(wireName: r'manifest_phase')
  V2PublishCommitResponseManifestPhaseEnum get manifestPhase;
  // enum manifestPhaseEnum {  start_received,  media_verified,  chunks_complete,  raw_ingest_completed,  projection_compiled,  finalized,  };

  @BuiltValueField(wireName: r'accepted_session_count')
  int get acceptedSessionCount;

  @BuiltValueField(wireName: r'accepted_event_count')
  int get acceptedEventCount;

  @BuiltValueField(wireName: r'accepted_media_count')
  int get acceptedMediaCount;

  @BuiltValueField(wireName: r'accepted_point_count')
  int get acceptedPointCount;

  @BuiltValueField(wireName: r'compiled_at')
  DateTime get compiledAt;

  V2PublishCommitResponse._();

  factory V2PublishCommitResponse([void updates(V2PublishCommitResponseBuilder b)]) = _$V2PublishCommitResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishCommitResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishCommitResponse> get serializer => _$V2PublishCommitResponseSerializer();
}

class _$V2PublishCommitResponseSerializer implements PrimitiveSerializer<V2PublishCommitResponse> {
  @override
  final Iterable<Type> types = const [V2PublishCommitResponse, _$V2PublishCommitResponse];

  @override
  final String wireName = r'V2PublishCommitResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishCommitResponse object, {
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
      specifiedType: const FullType(V2PublishCommitResponseManifestStatusEnum),
    );
    yield r'manifest_phase';
    yield serializers.serialize(
      object.manifestPhase,
      specifiedType: const FullType(V2PublishCommitResponseManifestPhaseEnum),
    );
    yield r'accepted_session_count';
    yield serializers.serialize(
      object.acceptedSessionCount,
      specifiedType: const FullType(int),
    );
    yield r'accepted_event_count';
    yield serializers.serialize(
      object.acceptedEventCount,
      specifiedType: const FullType(int),
    );
    yield r'accepted_media_count';
    yield serializers.serialize(
      object.acceptedMediaCount,
      specifiedType: const FullType(int),
    );
    yield r'accepted_point_count';
    yield serializers.serialize(
      object.acceptedPointCount,
      specifiedType: const FullType(int),
    );
    yield r'compiled_at';
    yield serializers.serialize(
      object.compiledAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishCommitResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishCommitResponseBuilder result,
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
            specifiedType: const FullType(V2PublishCommitResponseManifestStatusEnum),
          ) as V2PublishCommitResponseManifestStatusEnum;
          result.manifestStatus = valueDes;
          break;
        case r'manifest_phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(V2PublishCommitResponseManifestPhaseEnum),
          ) as V2PublishCommitResponseManifestPhaseEnum;
          result.manifestPhase = valueDes;
          break;
        case r'accepted_session_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedSessionCount = valueDes;
          break;
        case r'accepted_event_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedEventCount = valueDes;
          break;
        case r'accepted_media_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedMediaCount = valueDes;
          break;
        case r'accepted_point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedPointCount = valueDes;
          break;
        case r'compiled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.compiledAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishCommitResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishCommitResponseBuilder();
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

class V2PublishCommitResponseManifestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'started')
  static const V2PublishCommitResponseManifestStatusEnum started = _$v2PublishCommitResponseManifestStatusEnum_started;
  @BuiltValueEnumConst(wireName: r'failed_retryable')
  static const V2PublishCommitResponseManifestStatusEnum failedRetryable = _$v2PublishCommitResponseManifestStatusEnum_failedRetryable;
  @BuiltValueEnumConst(wireName: r'failed_terminal')
  static const V2PublishCommitResponseManifestStatusEnum failedTerminal = _$v2PublishCommitResponseManifestStatusEnum_failedTerminal;
  @BuiltValueEnumConst(wireName: r'idempotency_conflict')
  static const V2PublishCommitResponseManifestStatusEnum idempotencyConflict = _$v2PublishCommitResponseManifestStatusEnum_idempotencyConflict;
  @BuiltValueEnumConst(wireName: r'committed')
  static const V2PublishCommitResponseManifestStatusEnum committed = _$v2PublishCommitResponseManifestStatusEnum_committed;

  static Serializer<V2PublishCommitResponseManifestStatusEnum> get serializer => _$v2PublishCommitResponseManifestStatusEnumSerializer;

  const V2PublishCommitResponseManifestStatusEnum._(String name): super(name);

  static BuiltSet<V2PublishCommitResponseManifestStatusEnum> get values => _$v2PublishCommitResponseManifestStatusEnumValues;
  static V2PublishCommitResponseManifestStatusEnum valueOf(String name) => _$v2PublishCommitResponseManifestStatusEnumValueOf(name);
}

class V2PublishCommitResponseManifestPhaseEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'start_received')
  static const V2PublishCommitResponseManifestPhaseEnum startReceived = _$v2PublishCommitResponseManifestPhaseEnum_startReceived;
  @BuiltValueEnumConst(wireName: r'media_verified')
  static const V2PublishCommitResponseManifestPhaseEnum mediaVerified = _$v2PublishCommitResponseManifestPhaseEnum_mediaVerified;
  @BuiltValueEnumConst(wireName: r'chunks_complete')
  static const V2PublishCommitResponseManifestPhaseEnum chunksComplete = _$v2PublishCommitResponseManifestPhaseEnum_chunksComplete;
  @BuiltValueEnumConst(wireName: r'raw_ingest_completed')
  static const V2PublishCommitResponseManifestPhaseEnum rawIngestCompleted = _$v2PublishCommitResponseManifestPhaseEnum_rawIngestCompleted;
  @BuiltValueEnumConst(wireName: r'projection_compiled')
  static const V2PublishCommitResponseManifestPhaseEnum projectionCompiled = _$v2PublishCommitResponseManifestPhaseEnum_projectionCompiled;
  @BuiltValueEnumConst(wireName: r'finalized')
  static const V2PublishCommitResponseManifestPhaseEnum finalized = _$v2PublishCommitResponseManifestPhaseEnum_finalized;

  static Serializer<V2PublishCommitResponseManifestPhaseEnum> get serializer => _$v2PublishCommitResponseManifestPhaseEnumSerializer;

  const V2PublishCommitResponseManifestPhaseEnum._(String name): super(name);

  static BuiltSet<V2PublishCommitResponseManifestPhaseEnum> get values => _$v2PublishCommitResponseManifestPhaseEnumValues;
  static V2PublishCommitResponseManifestPhaseEnum valueOf(String name) => _$v2PublishCommitResponseManifestPhaseEnumValueOf(name);
}

