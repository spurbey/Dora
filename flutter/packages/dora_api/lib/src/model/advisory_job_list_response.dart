//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/advisory_job_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_job_list_response.g.dart';

/// AdvisoryJobListResponse
///
/// Properties:
/// * [jobs] 
/// * [total] 
@BuiltValue()
abstract class AdvisoryJobListResponse implements Built<AdvisoryJobListResponse, AdvisoryJobListResponseBuilder> {
  @BuiltValueField(wireName: r'jobs')
  BuiltList<AdvisoryJobResponse> get jobs;

  @BuiltValueField(wireName: r'total')
  int get total;

  AdvisoryJobListResponse._();

  factory AdvisoryJobListResponse([void updates(AdvisoryJobListResponseBuilder b)]) = _$AdvisoryJobListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryJobListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryJobListResponse> get serializer => _$AdvisoryJobListResponseSerializer();
}

class _$AdvisoryJobListResponseSerializer implements PrimitiveSerializer<AdvisoryJobListResponse> {
  @override
  final Iterable<Type> types = const [AdvisoryJobListResponse, _$AdvisoryJobListResponse];

  @override
  final String wireName = r'AdvisoryJobListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryJobListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'jobs';
    yield serializers.serialize(
      object.jobs,
      specifiedType: const FullType(BuiltList, [FullType(AdvisoryJobResponse)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryJobListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryJobListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'jobs':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdvisoryJobResponse)]),
          ) as BuiltList<AdvisoryJobResponse>;
          result.jobs.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryJobListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryJobListResponseBuilder();
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

