//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/export_stage.dart';
import 'package:dora_api/src/model/export_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_create_response.g.dart';

/// ExportCreateResponse
///
/// Properties:
/// * [jobId] 
/// * [status] 
/// * [stage] 
/// * [progress] 
@BuiltValue()
abstract class ExportCreateResponse implements Built<ExportCreateResponse, ExportCreateResponseBuilder> {
  @BuiltValueField(wireName: r'job_id')
  String get jobId;

  @BuiltValueField(wireName: r'status')
  ExportStatus get status;
  // enum statusEnum {  queued,  processing,  cancel_requested,  completed,  failed,  canceled,  blocked,  };

  @BuiltValueField(wireName: r'stage')
  ExportStage? get stage;
  // enum stageEnum {  snapshotting,  asset_fetch,  rendering,  encoding,  uploading,  finalizing,  };

  @BuiltValueField(wireName: r'progress')
  num get progress;

  ExportCreateResponse._();

  factory ExportCreateResponse([void updates(ExportCreateResponseBuilder b)]) = _$ExportCreateResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportCreateResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportCreateResponse> get serializer => _$ExportCreateResponseSerializer();
}

class _$ExportCreateResponseSerializer implements PrimitiveSerializer<ExportCreateResponse> {
  @override
  final Iterable<Type> types = const [ExportCreateResponse, _$ExportCreateResponse];

  @override
  final String wireName = r'ExportCreateResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportCreateResponse object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportCreateResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportCreateResponseBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportCreateResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportCreateResponseBuilder();
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

