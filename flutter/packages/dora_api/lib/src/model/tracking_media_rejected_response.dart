//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_media_rejected_response.g.dart';

/// TrackingMediaRejectedResponse
///
/// Properties:
/// * [clientMediaId] 
/// * [reasonCode] 
/// * [message] 
@BuiltValue()
abstract class TrackingMediaRejectedResponse implements Built<TrackingMediaRejectedResponse, TrackingMediaRejectedResponseBuilder> {
  @BuiltValueField(wireName: r'client_media_id')
  String? get clientMediaId;

  @BuiltValueField(wireName: r'reason_code')
  String get reasonCode;

  @BuiltValueField(wireName: r'message')
  String get message;

  TrackingMediaRejectedResponse._();

  factory TrackingMediaRejectedResponse([void updates(TrackingMediaRejectedResponseBuilder b)]) = _$TrackingMediaRejectedResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingMediaRejectedResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingMediaRejectedResponse> get serializer => _$TrackingMediaRejectedResponseSerializer();
}

class _$TrackingMediaRejectedResponseSerializer implements PrimitiveSerializer<TrackingMediaRejectedResponse> {
  @override
  final Iterable<Type> types = const [TrackingMediaRejectedResponse, _$TrackingMediaRejectedResponse];

  @override
  final String wireName = r'TrackingMediaRejectedResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingMediaRejectedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.clientMediaId != null) {
      yield r'client_media_id';
      yield serializers.serialize(
        object.clientMediaId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'reason_code';
    yield serializers.serialize(
      object.reasonCode,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingMediaRejectedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingMediaRejectedResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.clientMediaId = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reasonCode = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingMediaRejectedResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingMediaRejectedResponseBuilder();
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

