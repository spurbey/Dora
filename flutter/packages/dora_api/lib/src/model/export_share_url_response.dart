//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_share_url_response.g.dart';

/// ExportShareUrlResponse
///
/// Properties:
/// * [shareUrl] 
/// * [expiresAt] 
/// * [ttlSeconds] 
@BuiltValue()
abstract class ExportShareUrlResponse implements Built<ExportShareUrlResponse, ExportShareUrlResponseBuilder> {
  @BuiltValueField(wireName: r'share_url')
  String get shareUrl;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'ttl_seconds')
  int get ttlSeconds;

  ExportShareUrlResponse._();

  factory ExportShareUrlResponse([void updates(ExportShareUrlResponseBuilder b)]) = _$ExportShareUrlResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportShareUrlResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportShareUrlResponse> get serializer => _$ExportShareUrlResponseSerializer();
}

class _$ExportShareUrlResponseSerializer implements PrimitiveSerializer<ExportShareUrlResponse> {
  @override
  final Iterable<Type> types = const [ExportShareUrlResponse, _$ExportShareUrlResponse];

  @override
  final String wireName = r'ExportShareUrlResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportShareUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'share_url';
    yield serializers.serialize(
      object.shareUrl,
      specifiedType: const FullType(String),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ttl_seconds';
    yield serializers.serialize(
      object.ttlSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportShareUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportShareUrlResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'share_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.shareUrl = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'ttl_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.ttlSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportShareUrlResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportShareUrlResponseBuilder();
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

