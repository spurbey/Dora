//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'story_report_request.g.dart';

/// StoryReportRequest
///
/// Properties:
/// * [reason] 
/// * [details] 
@BuiltValue()
abstract class StoryReportRequest implements Built<StoryReportRequest, StoryReportRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  @BuiltValueField(wireName: r'details')
  String? get details;

  StoryReportRequest._();

  factory StoryReportRequest([void updates(StoryReportRequestBuilder b)]) = _$StoryReportRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StoryReportRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StoryReportRequest> get serializer => _$StoryReportRequestSerializer();
}

class _$StoryReportRequestSerializer implements PrimitiveSerializer<StoryReportRequest> {
  @override
  final Iterable<Type> types = const [StoryReportRequest, _$StoryReportRequest];

  @override
  final String wireName = r'StoryReportRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StoryReportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StoryReportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StoryReportRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.details = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StoryReportRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StoryReportRequestBuilder();
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

