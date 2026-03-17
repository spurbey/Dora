//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/export_stage.dart';
import 'package:dora_api/src/model/export_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_job_summary_response.g.dart';

/// ExportJobSummaryResponse
///
/// Properties:
/// * [jobId] 
/// * [tripId] 
/// * [tripTitle] 
/// * [template] 
/// * [status] 
/// * [stage] 
/// * [progress] 
/// * [outputUrl] 
/// * [thumbnailUrl] 
/// * [errorCode] 
/// * [errorMessage] 
/// * [createdAt] 
/// * [completedAt] 
@BuiltValue()
abstract class ExportJobSummaryResponse implements Built<ExportJobSummaryResponse, ExportJobSummaryResponseBuilder> {
  @BuiltValueField(wireName: r'job_id')
  String get jobId;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'trip_title')
  String? get tripTitle;

  @BuiltValueField(wireName: r'template')
  String get template;

  @BuiltValueField(wireName: r'status')
  ExportStatus get status;
  // enum statusEnum {  queued,  processing,  cancel_requested,  completed,  failed,  canceled,  blocked,  };

  @BuiltValueField(wireName: r'stage')
  ExportStage? get stage;
  // enum stageEnum {  snapshotting,  asset_fetch,  rendering,  encoding,  uploading,  finalizing,  };

  @BuiltValueField(wireName: r'progress')
  num get progress;

  @BuiltValueField(wireName: r'output_url')
  String? get outputUrl;

  @BuiltValueField(wireName: r'thumbnail_url')
  String? get thumbnailUrl;

  @BuiltValueField(wireName: r'error_code')
  String? get errorCode;

  @BuiltValueField(wireName: r'error_message')
  String? get errorMessage;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'completed_at')
  DateTime? get completedAt;

  ExportJobSummaryResponse._();

  factory ExportJobSummaryResponse([void updates(ExportJobSummaryResponseBuilder b)]) = _$ExportJobSummaryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportJobSummaryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportJobSummaryResponse> get serializer => _$ExportJobSummaryResponseSerializer();
}

class _$ExportJobSummaryResponseSerializer implements PrimitiveSerializer<ExportJobSummaryResponse> {
  @override
  final Iterable<Type> types = const [ExportJobSummaryResponse, _$ExportJobSummaryResponse];

  @override
  final String wireName = r'ExportJobSummaryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportJobSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'job_id';
    yield serializers.serialize(
      object.jobId,
      specifiedType: const FullType(String),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    if (object.tripTitle != null) {
      yield r'trip_title';
      yield serializers.serialize(
        object.tripTitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'template';
    yield serializers.serialize(
      object.template,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ExportStatus),
    );
    if (object.stage != null) {
      yield r'stage';
      yield serializers.serialize(
        object.stage,
        specifiedType: const FullType.nullable(ExportStage),
      );
    }
    yield r'progress';
    yield serializers.serialize(
      object.progress,
      specifiedType: const FullType(num),
    );
    if (object.outputUrl != null) {
      yield r'output_url';
      yield serializers.serialize(
        object.outputUrl,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.thumbnailUrl != null) {
      yield r'thumbnail_url';
      yield serializers.serialize(
        object.thumbnailUrl,
        specifiedType: const FullType.nullable(String),
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
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.completedAt != null) {
      yield r'completed_at';
      yield serializers.serialize(
        object.completedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportJobSummaryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportJobSummaryResponseBuilder result,
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
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'trip_title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripTitle = valueDes;
          break;
        case r'template':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.template = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExportStatus),
          ) as ExportStatus;
          result.status = valueDes;
          break;
        case r'stage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(ExportStage),
          ) as ExportStage?;
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
        case r'output_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.outputUrl = valueDes;
          break;
        case r'thumbnail_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.thumbnailUrl = valueDes;
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
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'completed_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.completedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportJobSummaryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportJobSummaryResponseBuilder();
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

