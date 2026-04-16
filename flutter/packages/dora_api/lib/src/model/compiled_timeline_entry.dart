//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compiled_timeline_entry.g.dart';

/// CompiledTimelineEntry
///
/// Properties:
/// * [entryId] 
/// * [sourceKind] 
/// * [sourceId] 
/// * [eventType] 
/// * [capturedAt] 
/// * [bucketType] 
/// * [placeId] 
/// * [placeName] 
/// * [bindSource] 
/// * [bindConfidence] 
/// * [reasonCode] 
/// * [title] 
/// * [subtitle] 
/// * [payload] 
@BuiltValue()
abstract class CompiledTimelineEntry implements Built<CompiledTimelineEntry, CompiledTimelineEntryBuilder> {
  @BuiltValueField(wireName: r'entry_id')
  String get entryId;

  @BuiltValueField(wireName: r'source_kind')
  String get sourceKind;

  @BuiltValueField(wireName: r'source_id')
  String get sourceId;

  @BuiltValueField(wireName: r'event_type')
  String get eventType;

  @BuiltValueField(wireName: r'captured_at')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'bucket_type')
  String get bucketType;

  @BuiltValueField(wireName: r'place_id')
  String? get placeId;

  @BuiltValueField(wireName: r'place_name')
  String? get placeName;

  @BuiltValueField(wireName: r'bind_source')
  String get bindSource;

  @BuiltValueField(wireName: r'bind_confidence')
  num? get bindConfidence;

  @BuiltValueField(wireName: r'reason_code')
  String? get reasonCode;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'subtitle')
  String? get subtitle;

  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?>? get payload;

  CompiledTimelineEntry._();

  factory CompiledTimelineEntry([void updates(CompiledTimelineEntryBuilder b)]) = _$CompiledTimelineEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompiledTimelineEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompiledTimelineEntry> get serializer => _$CompiledTimelineEntrySerializer();
}

class _$CompiledTimelineEntrySerializer implements PrimitiveSerializer<CompiledTimelineEntry> {
  @override
  final Iterable<Type> types = const [CompiledTimelineEntry, _$CompiledTimelineEntry];

  @override
  final String wireName = r'CompiledTimelineEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompiledTimelineEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entry_id';
    yield serializers.serialize(
      object.entryId,
      specifiedType: const FullType(String),
    );
    yield r'source_kind';
    yield serializers.serialize(
      object.sourceKind,
      specifiedType: const FullType(String),
    );
    yield r'source_id';
    yield serializers.serialize(
      object.sourceId,
      specifiedType: const FullType(String),
    );
    yield r'event_type';
    yield serializers.serialize(
      object.eventType,
      specifiedType: const FullType(String),
    );
    yield r'captured_at';
    yield serializers.serialize(
      object.capturedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'bucket_type';
    yield serializers.serialize(
      object.bucketType,
      specifiedType: const FullType(String),
    );
    if (object.placeId != null) {
      yield r'place_id';
      yield serializers.serialize(
        object.placeId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.placeName != null) {
      yield r'place_name';
      yield serializers.serialize(
        object.placeName,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'bind_source';
    yield serializers.serialize(
      object.bindSource,
      specifiedType: const FullType(String),
    );
    if (object.bindConfidence != null) {
      yield r'bind_confidence';
      yield serializers.serialize(
        object.bindConfidence,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.reasonCode != null) {
      yield r'reason_code';
      yield serializers.serialize(
        object.reasonCode,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.subtitle != null) {
      yield r'subtitle';
      yield serializers.serialize(
        object.subtitle,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.payload != null) {
      yield r'payload';
      yield serializers.serialize(
        object.payload,
        specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompiledTimelineEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompiledTimelineEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'entry_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entryId = valueDes;
          break;
        case r'source_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceKind = valueDes;
          break;
        case r'source_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceId = valueDes;
          break;
        case r'event_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventType = valueDes;
          break;
        case r'captured_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.capturedAt = valueDes;
          break;
        case r'bucket_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bucketType = valueDes;
          break;
        case r'place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.placeId = valueDes;
          break;
        case r'place_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.placeName = valueDes;
          break;
        case r'bind_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bindSource = valueDes;
          break;
        case r'bind_confidence':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.bindConfidence = valueDes;
          break;
        case r'reason_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.reasonCode = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'subtitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.subtitle = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompiledTimelineEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompiledTimelineEntryBuilder();
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

