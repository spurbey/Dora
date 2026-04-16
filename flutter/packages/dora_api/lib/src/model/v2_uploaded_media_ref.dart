//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_uploaded_media_ref.g.dart';

/// V2UploadedMediaRef
///
/// Properties:
/// * [clientMediaId] 
/// * [storageRef] 
@BuiltValue()
abstract class V2UploadedMediaRef implements Built<V2UploadedMediaRef, V2UploadedMediaRefBuilder> {
  @BuiltValueField(wireName: r'client_media_id')
  String get clientMediaId;

  @BuiltValueField(wireName: r'storage_ref')
  String get storageRef;

  V2UploadedMediaRef._();

  factory V2UploadedMediaRef([void updates(V2UploadedMediaRefBuilder b)]) = _$V2UploadedMediaRef;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2UploadedMediaRefBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2UploadedMediaRef> get serializer => _$V2UploadedMediaRefSerializer();
}

class _$V2UploadedMediaRefSerializer implements PrimitiveSerializer<V2UploadedMediaRef> {
  @override
  final Iterable<Type> types = const [V2UploadedMediaRef, _$V2UploadedMediaRef];

  @override
  final String wireName = r'V2UploadedMediaRef';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2UploadedMediaRef object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'client_media_id';
    yield serializers.serialize(
      object.clientMediaId,
      specifiedType: const FullType(String),
    );
    yield r'storage_ref';
    yield serializers.serialize(
      object.storageRef,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    V2UploadedMediaRef object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2UploadedMediaRefBuilder result,
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
        case r'storage_ref':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.storageRef = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2UploadedMediaRef deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2UploadedMediaRefBuilder();
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

