//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_download_url_response.g.dart';

/// ExportDownloadUrlResponse
///
/// Properties:
/// * [downloadUrl] 
/// * [expiresAt] 
/// * [ttlSeconds] 
@BuiltValue()
abstract class ExportDownloadUrlResponse implements Built<ExportDownloadUrlResponse, ExportDownloadUrlResponseBuilder> {
  @BuiltValueField(wireName: r'download_url')
  String get downloadUrl;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'ttl_seconds')
  int get ttlSeconds;

  ExportDownloadUrlResponse._();

  factory ExportDownloadUrlResponse([void updates(ExportDownloadUrlResponseBuilder b)]) = _$ExportDownloadUrlResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportDownloadUrlResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportDownloadUrlResponse> get serializer => _$ExportDownloadUrlResponseSerializer();
}

class _$ExportDownloadUrlResponseSerializer implements PrimitiveSerializer<ExportDownloadUrlResponse> {
  @override
  final Iterable<Type> types = const [ExportDownloadUrlResponse, _$ExportDownloadUrlResponse];

  @override
  final String wireName = r'ExportDownloadUrlResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportDownloadUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'download_url';
    yield serializers.serialize(
      object.downloadUrl,
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
    ExportDownloadUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportDownloadUrlResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'download_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.downloadUrl = valueDes;
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
  ExportDownloadUrlResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportDownloadUrlResponseBuilder();
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

