//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/advisory_job_type.dart';
import 'package:dora_api/src/model/advisory_job_status.dart';
import 'package:dora_api/src/model/advisory_job_stage.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_job_response.g.dart';

/// AdvisoryJobResponse
///
/// Properties:
/// * [jobId] 
/// * [status] 
/// * [stage] 
/// * [progress] 
/// * [jobType] 
/// * [createdAt] 
/// * [startedAt] 
/// * [completedAt] 
/// * [errorCode] 
/// * [errorMessage] 
@BuiltValue()
abstract class AdvisoryJobResponse implements Built<AdvisoryJobResponse, AdvisoryJobResponseBuilder> {
  @BuiltValueField(wireName: r'job_id')
  String get jobId;

  @BuiltValueField(wireName: r'status')
  AdvisoryJobStatus get status;
  // enum statusEnum {  queued,  processing,  cancel_requested,  completed,  failed,  canceled,  blocked,  };

  @BuiltValueField(wireName: r'stage')
  AdvisoryJobStage? get stage;
  // enum stageEnum {  route_segmentation,  reddit_scrape,  tripadvisor_scrape,  gmaps_scrape,  llm_extraction,  scoring,  delivery,  };

  @BuiltValueField(wireName: r'progress')
  num get progress;

  @BuiltValueField(wireName: r'job_type')
  AdvisoryJobType get jobType;
  // enum jobTypeEnum {  pre_trip,  on_demand,  location_trigger,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'started_at')
  DateTime? get startedAt;

  @BuiltValueField(wireName: r'completed_at')
  DateTime? get completedAt;

  @BuiltValueField(wireName: r'error_code')
  String? get errorCode;

  @BuiltValueField(wireName: r'error_message')
  String? get errorMessage;

  AdvisoryJobResponse._();

  factory AdvisoryJobResponse([void updates(AdvisoryJobResponseBuilder b)]) = _$AdvisoryJobResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryJobResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryJobResponse> get serializer => _$AdvisoryJobResponseSerializer();
}

class _$AdvisoryJobResponseSerializer implements PrimitiveSerializer<AdvisoryJobResponse> {
  @override
  final Iterable<Type> types = const [AdvisoryJobResponse, _$AdvisoryJobResponse];

  @override
  final String wireName = r'AdvisoryJobResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryJobResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'job_id';
    yield serializers.serialize(
      object.jobId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(AdvisoryJobStatus),
    );
    if (object.stage != null) {
      yield r'stage';
      yield serializers.serialize(
        object.stage,
        specifiedType: const FullType.nullable(AdvisoryJobStage),
      );
    }
    yield r'progress';
    yield serializers.serialize(
      object.progress,
      specifiedType: const FullType(num),
    );
    yield r'job_type';
    yield serializers.serialize(
      object.jobType,
      specifiedType: const FullType(AdvisoryJobType),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.startedAt != null) {
      yield r'started_at';
      yield serializers.serialize(
        object.startedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.completedAt != null) {
      yield r'completed_at';
      yield serializers.serialize(
        object.completedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.errorCode != null) {
      yield r'error_code';
      yield serializers.serialize(
        object.errorCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.errorMessage != null) {
      yield r'error_message';
      yield serializers.serialize(
        object.errorMessage,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryJobResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryJobResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'job_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.jobId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdvisoryJobStatus),
          ) as AdvisoryJobStatus;
          result.status = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(AdvisoryJobStage),
          ) as AdvisoryJobStage?;
          if (valueDes == null) continue;
          result.stage = valueDes;
          break;
        case r'progress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.progress = valueDes;
          break;
        case r'job_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdvisoryJobType),
          ) as AdvisoryJobType;
          result.jobType = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startedAt = valueDes;
          break;
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        case r'error_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.errorCode = valueDes;
          break;
        case r'error_message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.errorMessage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryJobResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryJobResponseBuilder();
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

