//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/export_template.dart';
import 'package:dora_api/src/model/export_aspect_ratio.dart';
import 'package:dora_api/src/model/export_quality.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'export_create_request.g.dart';

/// ExportCreateRequest
///
/// Properties:
/// * [template] 
/// * [aspectRatio] 
/// * [durationSec] 
/// * [quality] 
/// * [fps] 
@BuiltValue()
abstract class ExportCreateRequest implements Built<ExportCreateRequest, ExportCreateRequestBuilder> {
  @BuiltValueField(wireName: r'template')
  ExportTemplate? get template;
  // enum templateEnum {  classic,  cinematic,  };

  @BuiltValueField(wireName: r'aspect_ratio')
  ExportAspectRatio? get aspectRatio;
  // enum aspectRatioEnum {  9:16,  1:1,  16:9,  };

  @BuiltValueField(wireName: r'duration_sec')
  int? get durationSec;

  @BuiltValueField(wireName: r'quality')
  ExportQuality? get quality;
  // enum qualityEnum {  480p,  720p,  1080p,  };

  @BuiltValueField(wireName: r'fps')
  int? get fps;

  ExportCreateRequest._();

  factory ExportCreateRequest([void updates(ExportCreateRequestBuilder b)]) = _$ExportCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExportCreateRequestBuilder b) => b
      ..template = ExportTemplate.classic
      ..aspectRatio = ExportAspectRatio.n9colon16
      ..durationSec = 15
      ..quality = ExportQuality.n720p
      ..fps = 30;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExportCreateRequest> get serializer => _$ExportCreateRequestSerializer();
}

class _$ExportCreateRequestSerializer implements PrimitiveSerializer<ExportCreateRequest> {
  @override
  final Iterable<Type> types = const [ExportCreateRequest, _$ExportCreateRequest];

  @override
  final String wireName = r'ExportCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExportCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.template != null) {
      yield r'template';
      yield serializers.serialize(
        object.template,
        specifiedType: const FullType(ExportTemplate),
      );
    }
    if (object.aspectRatio != null) {
      yield r'aspect_ratio';
      yield serializers.serialize(
        object.aspectRatio,
        specifiedType: const FullType(ExportAspectRatio),
      );
    }
    if (object.durationSec != null) {
      yield r'duration_sec';
      yield serializers.serialize(
        object.durationSec,
        specifiedType: const FullType(int),
      );
    }
    if (object.quality != null) {
      yield r'quality';
      yield serializers.serialize(
        object.quality,
        specifiedType: const FullType(ExportQuality),
      );
    }
    if (object.fps != null) {
      yield r'fps';
      yield serializers.serialize(
        object.fps,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ExportCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ExportCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'template':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExportTemplate),
          ) as ExportTemplate;
          result.template = valueDes;
          break;
        case r'aspect_ratio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExportAspectRatio),
          ) as ExportAspectRatio;
          result.aspectRatio = valueDes;
          break;
        case r'duration_sec':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationSec = valueDes;
          break;
        case r'quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ExportQuality),
          ) as ExportQuality;
          result.quality = valueDes;
          break;
        case r'fps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.fps = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExportCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExportCreateRequestBuilder();
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

