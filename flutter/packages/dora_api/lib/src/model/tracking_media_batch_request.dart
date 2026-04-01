//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/tracking_media_input.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_media_batch_request.g.dart';

/// TrackingMediaBatchRequest
///
/// Properties:
/// * [media] 
@BuiltValue()
abstract class TrackingMediaBatchRequest implements Built<TrackingMediaBatchRequest, TrackingMediaBatchRequestBuilder> {
  @BuiltValueField(wireName: r'media')
  BuiltList<TrackingMediaInput>? get media;

  TrackingMediaBatchRequest._();

  factory TrackingMediaBatchRequest([void updates(TrackingMediaBatchRequestBuilder b)]) = _$TrackingMediaBatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingMediaBatchRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingMediaBatchRequest> get serializer => _$TrackingMediaBatchRequestSerializer();
}

class _$TrackingMediaBatchRequestSerializer implements PrimitiveSerializer<TrackingMediaBatchRequest> {
  @override
  final Iterable<Type> types = const [TrackingMediaBatchRequest, _$TrackingMediaBatchRequest];

  @override
  final String wireName = r'TrackingMediaBatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingMediaBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.media != null) {
      yield r'media';
      yield serializers.serialize(
        object.media,
        specifiedType: const FullType(BuiltList, [FullType(TrackingMediaInput)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingMediaBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingMediaBatchRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(TrackingMediaInput)]),
          ) as BuiltList<TrackingMediaInput>;
          result.media.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingMediaBatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingMediaBatchRequestBuilder();
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

