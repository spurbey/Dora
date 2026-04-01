//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_media_accepted_response.g.dart';

/// TrackingMediaAcceptedResponse
///
/// Properties:
/// * [clientMediaId] 
/// * [mediaId] 
/// * [duplicate] 
@BuiltValue()
abstract class TrackingMediaAcceptedResponse implements Built<TrackingMediaAcceptedResponse, TrackingMediaAcceptedResponseBuilder> {
  @BuiltValueField(wireName: r'client_media_id')
  String get clientMediaId;

  @BuiltValueField(wireName: r'media_id')
  String get mediaId;

  @BuiltValueField(wireName: r'duplicate')
  bool get duplicate;

  TrackingMediaAcceptedResponse._();

  factory TrackingMediaAcceptedResponse([void updates(TrackingMediaAcceptedResponseBuilder b)]) = _$TrackingMediaAcceptedResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingMediaAcceptedResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingMediaAcceptedResponse> get serializer => _$TrackingMediaAcceptedResponseSerializer();
}

class _$TrackingMediaAcceptedResponseSerializer implements PrimitiveSerializer<TrackingMediaAcceptedResponse> {
  @override
  final Iterable<Type> types = const [TrackingMediaAcceptedResponse, _$TrackingMediaAcceptedResponse];

  @override
  final String wireName = r'TrackingMediaAcceptedResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingMediaAcceptedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_media_id';
    yield serializers.serialize(
      object.clientMediaId,
      specifiedType: const FullType(String),
    );
    yield r'media_id';
    yield serializers.serialize(
      object.mediaId,
      specifiedType: const FullType(String),
    );
    yield r'duplicate';
    yield serializers.serialize(
      object.duplicate,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingMediaAcceptedResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingMediaAcceptedResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'client_media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.clientMediaId = valueDes;
          break;
        case r'media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaId = valueDes;
          break;
        case r'duplicate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.duplicate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingMediaAcceptedResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingMediaAcceptedResponseBuilder();
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

