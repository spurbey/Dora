//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/advisory_insight_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_insight_list_response.g.dart';

/// AdvisoryInsightListResponse
///
/// Properties:
/// * [insights] 
/// * [total] 
@BuiltValue()
abstract class AdvisoryInsightListResponse implements Built<AdvisoryInsightListResponse, AdvisoryInsightListResponseBuilder> {
  @BuiltValueField(wireName: r'insights')
  BuiltList<AdvisoryInsightResponse> get insights;

  @BuiltValueField(wireName: r'total')
  int get total;

  AdvisoryInsightListResponse._();

  factory AdvisoryInsightListResponse([void updates(AdvisoryInsightListResponseBuilder b)]) = _$AdvisoryInsightListResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryInsightListResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryInsightListResponse> get serializer => _$AdvisoryInsightListResponseSerializer();
}

class _$AdvisoryInsightListResponseSerializer implements PrimitiveSerializer<AdvisoryInsightListResponse> {
  @override
  final Iterable<Type> types = const [AdvisoryInsightListResponse, _$AdvisoryInsightListResponse];

  @override
  final String wireName = r'AdvisoryInsightListResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryInsightListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'insights';
    yield serializers.serialize(
      object.insights,
      specifiedType: const FullType(BuiltList, [FullType(AdvisoryInsightResponse)]),
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
    AdvisoryInsightListResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryInsightListResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'insights':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AdvisoryInsightResponse)]),
          ) as BuiltList<AdvisoryInsightResponse>;
          result.insights.replace(valueDes);
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
  AdvisoryInsightListResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryInsightListResponseBuilder();
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

