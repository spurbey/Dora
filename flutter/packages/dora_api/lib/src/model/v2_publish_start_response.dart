//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/v2_upload_target.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_publish_start_response.g.dart';

/// V2PublishStartResponse
///
/// Properties:
/// * [publishToken] 
/// * [manifestStatus] 
/// * [manifestPhase] 
/// * [acceptedMediaCount] 
/// * [uploadTargets] 
@BuiltValue()
abstract class V2PublishStartResponse implements Built<V2PublishStartResponse, V2PublishStartResponseBuilder> {
  @BuiltValueField(wireName: r'publish_token')
  String get publishToken;

  @BuiltValueField(wireName: r'manifest_status')
  V2PublishStartResponseManifestStatusEnum get manifestStatus;
  // enum manifestStatusEnum {  started,  failed_retryable,  failed_terminal,  idempotency_conflict,  committed,  };

  @BuiltValueField(wireName: r'manifest_phase')
  V2PublishStartResponseManifestPhaseEnum get manifestPhase;
  // enum manifestPhaseEnum {  start_received,  media_verified,  chunks_complete,  raw_ingest_completed,  projection_compiled,  finalized,  };

  @BuiltValueField(wireName: r'accepted_media_count')
  int get acceptedMediaCount;

  @BuiltValueField(wireName: r'upload_targets')
  BuiltList<V2UploadTarget>? get uploadTargets;

  V2PublishStartResponse._();

  factory V2PublishStartResponse([void updates(V2PublishStartResponseBuilder b)]) = _$V2PublishStartResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2PublishStartResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2PublishStartResponse> get serializer => _$V2PublishStartResponseSerializer();
}

class _$V2PublishStartResponseSerializer implements PrimitiveSerializer<V2PublishStartResponse> {
  @override
  final Iterable<Type> types = const [V2PublishStartResponse, _$V2PublishStartResponse];

  @override
  final String wireName = r'V2PublishStartResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2PublishStartResponse object, {
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
      specifiedType: const FullType(V2PublishStartResponseManifestStatusEnum),
    );
    yield r'manifest_phase';
    yield serializers.serialize(
      object.manifestPhase,
      specifiedType: const FullType(V2PublishStartResponseManifestPhaseEnum),
    );
    yield r'accepted_media_count';
    yield serializers.serialize(
      object.acceptedMediaCount,
      specifiedType: const FullType(int),
    );
    if (object.uploadTargets != null) {
      yield r'upload_targets';
      yield serializers.serialize(
        object.uploadTargets,
        specifiedType: const FullType(BuiltList, [FullType(V2UploadTarget)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2PublishStartResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2PublishStartResponseBuilder result,
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
            specifiedType: const FullType(V2PublishStartResponseManifestStatusEnum),
          ) as V2PublishStartResponseManifestStatusEnum;
          result.manifestStatus = valueDes;
          break;
        case r'manifest_phase':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(V2PublishStartResponseManifestPhaseEnum),
          ) as V2PublishStartResponseManifestPhaseEnum;
          result.manifestPhase = valueDes;
          break;
        case r'accepted_media_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.acceptedMediaCount = valueDes;
          break;
        case r'upload_targets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(V2UploadTarget)]),
          ) as BuiltList<V2UploadTarget>;
          result.uploadTargets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2PublishStartResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2PublishStartResponseBuilder();
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

class V2PublishStartResponseManifestStatusEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'started')
  static const V2PublishStartResponseManifestStatusEnum started = _$v2PublishStartResponseManifestStatusEnum_started;
  @BuiltValueEnumConst(wireName: r'failed_retryable')
  static const V2PublishStartResponseManifestStatusEnum failedRetryable = _$v2PublishStartResponseManifestStatusEnum_failedRetryable;
  @BuiltValueEnumConst(wireName: r'failed_terminal')
  static const V2PublishStartResponseManifestStatusEnum failedTerminal = _$v2PublishStartResponseManifestStatusEnum_failedTerminal;
  @BuiltValueEnumConst(wireName: r'idempotency_conflict')
  static const V2PublishStartResponseManifestStatusEnum idempotencyConflict = _$v2PublishStartResponseManifestStatusEnum_idempotencyConflict;
  @BuiltValueEnumConst(wireName: r'committed')
  static const V2PublishStartResponseManifestStatusEnum committed = _$v2PublishStartResponseManifestStatusEnum_committed;

  static Serializer<V2PublishStartResponseManifestStatusEnum> get serializer => _$v2PublishStartResponseManifestStatusEnumSerializer;

  const V2PublishStartResponseManifestStatusEnum._(String name): super(name);

  static BuiltSet<V2PublishStartResponseManifestStatusEnum> get values => _$v2PublishStartResponseManifestStatusEnumValues;
  static V2PublishStartResponseManifestStatusEnum valueOf(String name) => _$v2PublishStartResponseManifestStatusEnumValueOf(name);
}

class V2PublishStartResponseManifestPhaseEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'start_received')
  static const V2PublishStartResponseManifestPhaseEnum startReceived = _$v2PublishStartResponseManifestPhaseEnum_startReceived;
  @BuiltValueEnumConst(wireName: r'media_verified')
  static const V2PublishStartResponseManifestPhaseEnum mediaVerified = _$v2PublishStartResponseManifestPhaseEnum_mediaVerified;
  @BuiltValueEnumConst(wireName: r'chunks_complete')
  static const V2PublishStartResponseManifestPhaseEnum chunksComplete = _$v2PublishStartResponseManifestPhaseEnum_chunksComplete;
  @BuiltValueEnumConst(wireName: r'raw_ingest_completed')
  static const V2PublishStartResponseManifestPhaseEnum rawIngestCompleted = _$v2PublishStartResponseManifestPhaseEnum_rawIngestCompleted;
  @BuiltValueEnumConst(wireName: r'projection_compiled')
  static const V2PublishStartResponseManifestPhaseEnum projectionCompiled = _$v2PublishStartResponseManifestPhaseEnum_projectionCompiled;
  @BuiltValueEnumConst(wireName: r'finalized')
  static const V2PublishStartResponseManifestPhaseEnum finalized = _$v2PublishStartResponseManifestPhaseEnum_finalized;

  static Serializer<V2PublishStartResponseManifestPhaseEnum> get serializer => _$v2PublishStartResponseManifestPhaseEnumSerializer;

  const V2PublishStartResponseManifestPhaseEnum._(String name): super(name);

  static BuiltSet<V2PublishStartResponseManifestPhaseEnum> get values => _$v2PublishStartResponseManifestPhaseEnumValues;
  static V2PublishStartResponseManifestPhaseEnum valueOf(String name) => _$v2PublishStartResponseManifestPhaseEnumValueOf(name);
}

