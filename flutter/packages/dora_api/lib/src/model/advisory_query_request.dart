//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'advisory_query_request.g.dart';

/// AdvisoryQueryRequest
///
/// Properties:
/// * [queryText] - Natural-language query, e.g. 'find me a quiet cafe'
@BuiltValue()
abstract class AdvisoryQueryRequest implements Built<AdvisoryQueryRequest, AdvisoryQueryRequestBuilder> {
  /// Natural-language query, e.g. 'find me a quiet cafe'
  @BuiltValueField(wireName: r'query_text')
  String get queryText;

  AdvisoryQueryRequest._();

  factory AdvisoryQueryRequest([void updates(AdvisoryQueryRequestBuilder b)]) = _$AdvisoryQueryRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdvisoryQueryRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdvisoryQueryRequest> get serializer => _$AdvisoryQueryRequestSerializer();
}

class _$AdvisoryQueryRequestSerializer implements PrimitiveSerializer<AdvisoryQueryRequest> {
  @override
  final Iterable<Type> types = const [AdvisoryQueryRequest, _$AdvisoryQueryRequest];

  @override
  final String wireName = r'AdvisoryQueryRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdvisoryQueryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'query_text';
    yield serializers.serialize(
      object.queryText,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AdvisoryQueryRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdvisoryQueryRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'query_text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.queryText = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdvisoryQueryRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdvisoryQueryRequestBuilder();
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

