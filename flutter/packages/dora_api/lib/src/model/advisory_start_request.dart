//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/advisory_job_type.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_start_request.g.dart';

/// AdvisoryStartRequest
///
/// Properties:
/// * [jobType] 
/// * [triggerPayload] 
@BuiltValue()
abstract class AdvisoryStartRequest implements Built<AdvisoryStartRequest, AdvisoryStartRequestBuilder> {
  @BuiltValueField(wireName: r'job_type')
  AdvisoryJobType? get jobType;
  // enum jobTypeEnum {  pre_trip,  on_demand,  location_trigger,  };

  @BuiltValueField(wireName: r'trigger_payload')
  BuiltMap<String, JsonObject?>? get triggerPayload;

  AdvisoryStartRequest._();

  factory AdvisoryStartRequest([void updates(AdvisoryStartRequestBuilder b)]) = _$AdvisoryStartRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryStartRequestBuilder b) => b
      ..jobType = AdvisoryJobType.preTrip;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryStartRequest> get serializer => _$AdvisoryStartRequestSerializer();
}

class _$AdvisoryStartRequestSerializer implements PrimitiveSerializer<AdvisoryStartRequest> {
  @override
  final Iterable<Type> types = const [AdvisoryStartRequest, _$AdvisoryStartRequest];

  @override
  final String wireName = r'AdvisoryStartRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.jobType != null) {
      yield r'job_type';
      yield serializers.serialize(
        object.jobType,
        specifiedType: const FullType(AdvisoryJobType),
      );
    }
    if (object.triggerPayload != null) {
      yield r'trigger_payload';
      yield serializers.serialize(
        object.triggerPayload,
        specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryStartRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryStartRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'job_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdvisoryJobType),
          ) as AdvisoryJobType;
          result.jobType = valueDes;
          break;
        case r'trigger_payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.triggerPayload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryStartRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryStartRequestBuilder();
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

