//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'v2_timeline_entry_response.g.dart';

/// V2TimelineEntryResponse
///
/// Properties:
/// * [entryId] 
/// * [entryKind] 
/// * [sourceServerId] 
/// * [capturedAt] 
/// * [bucketType] 
/// * [placeBindName] 
/// * [placeBindId] 
/// * [decisionSource] 
/// * [manualLock] 
/// * [anchorLatitude] 
/// * [anchorLongitude] 
/// * [routeSegmentKey] 
/// * [routeDistanceM] 
/// * [title] 
/// * [subtitle] 
/// * [renderPayloadJson] 
@BuiltValue()
abstract class V2TimelineEntryResponse implements Built<V2TimelineEntryResponse, V2TimelineEntryResponseBuilder> {
  @BuiltValueField(wireName: r'entry_id')
  String get entryId;

  @BuiltValueField(wireName: r'entry_kind')
  String get entryKind;

  @BuiltValueField(wireName: r'source_server_id')
  String get sourceServerId;

  @BuiltValueField(wireName: r'captured_at')
  DateTime get capturedAt;

  @BuiltValueField(wireName: r'bucket_type')
  String get bucketType;

  @BuiltValueField(wireName: r'place_bind_name')
  String? get placeBindName;

  @BuiltValueField(wireName: r'place_bind_id')
  String? get placeBindId;

  @BuiltValueField(wireName: r'decision_source')
  String? get decisionSource;

  @BuiltValueField(wireName: r'manual_lock')
  bool get manualLock;

  @BuiltValueField(wireName: r'anchor_latitude')
  num get anchorLatitude;

  @BuiltValueField(wireName: r'anchor_longitude')
  num get anchorLongitude;

  @BuiltValueField(wireName: r'route_segment_key')
  String? get routeSegmentKey;

  @BuiltValueField(wireName: r'route_distance_m')
  num? get routeDistanceM;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'subtitle')
  String? get subtitle;

  @BuiltValueField(wireName: r'render_payload_json')
  JsonObject? get renderPayloadJson;

  V2TimelineEntryResponse._();

  factory V2TimelineEntryResponse([void updates(V2TimelineEntryResponseBuilder b)]) = _$V2TimelineEntryResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(V2TimelineEntryResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<V2TimelineEntryResponse> get serializer => _$V2TimelineEntryResponseSerializer();
}

class _$V2TimelineEntryResponseSerializer implements PrimitiveSerializer<V2TimelineEntryResponse> {
  @override
  final Iterable<Type> types = const [V2TimelineEntryResponse, _$V2TimelineEntryResponse];

  @override
  final String wireName = r'V2TimelineEntryResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    V2TimelineEntryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'entry_id';
    yield serializers.serialize(
      object.entryId,
      specifiedType: const FullType(String),
    );
    yield r'entry_kind';
    yield serializers.serialize(
      object.entryKind,
      specifiedType: const FullType(String),
    );
    yield r'source_server_id';
    yield serializers.serialize(
      object.sourceServerId,
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
    if (object.placeBindName != null) {
      yield r'place_bind_name';
      yield serializers.serialize(
        object.placeBindName,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.placeBindId != null) {
      yield r'place_bind_id';
      yield serializers.serialize(
        object.placeBindId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.decisionSource != null) {
      yield r'decision_source';
      yield serializers.serialize(
        object.decisionSource,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'manual_lock';
    yield serializers.serialize(
      object.manualLock,
      specifiedType: const FullType(bool),
    );
    yield r'anchor_latitude';
    yield serializers.serialize(
      object.anchorLatitude,
      specifiedType: const FullType(num),
    );
    yield r'anchor_longitude';
    yield serializers.serialize(
      object.anchorLongitude,
      specifiedType: const FullType(num),
    );
    if (object.routeSegmentKey != null) {
      yield r'route_segment_key';
      yield serializers.serialize(
        object.routeSegmentKey,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.routeDistanceM != null) {
      yield r'route_distance_m';
      yield serializers.serialize(
        object.routeDistanceM,
        specifiedType: const FullType.nullable(num),
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
    if (object.renderPayloadJson != null) {
      yield r'render_payload_json';
      yield serializers.serialize(
        object.renderPayloadJson,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    V2TimelineEntryResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required V2TimelineEntryResponseBuilder result,
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
        case r'entry_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entryKind = valueDes;
          break;
        case r'source_server_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceServerId = valueDes;
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
        case r'place_bind_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.placeBindName = valueDes;
          break;
        case r'place_bind_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.placeBindId = valueDes;
          break;
        case r'decision_source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.decisionSource = valueDes;
          break;
        case r'manual_lock':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.manualLock = valueDes;
          break;
        case r'anchor_latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.anchorLatitude = valueDes;
          break;
        case r'anchor_longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.anchorLongitude = valueDes;
          break;
        case r'route_segment_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.routeSegmentKey = valueDes;
          break;
        case r'route_distance_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.routeDistanceM = valueDes;
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
        case r'render_payload_json':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.renderPayloadJson = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  V2TimelineEntryResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = V2TimelineEntryResponseBuilder();
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

