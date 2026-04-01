//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:dora_api/src/model/compiled_timeline_day_group.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dora_api/src/model/compiled_projection_stats.dart';
import 'package:dora_api/src/model/compiled_timeline_entry.dart';
import 'package:dora_api/src/model/compiled_route_segment.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compiled_projection_response.g.dart';

/// CompiledProjectionResponse
///
/// Properties:
/// * [tripId] 
/// * [compilerVersion] 
/// * [stale] 
/// * [compiledAt] 
/// * [timelineEntries] 
/// * [timelineGroups] 
/// * [routeSegments] 
/// * [stats] 
@BuiltValue()
abstract class CompiledProjectionResponse implements Built<CompiledProjectionResponse, CompiledProjectionResponseBuilder> {
  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'compiler_version')
  int get compilerVersion;

  @BuiltValueField(wireName: r'stale')
  bool get stale;

  @BuiltValueField(wireName: r'compiled_at')
  DateTime? get compiledAt;

  @BuiltValueField(wireName: r'timeline_entries')
  BuiltList<CompiledTimelineEntry>? get timelineEntries;

  @BuiltValueField(wireName: r'timeline_groups')
  BuiltList<CompiledTimelineDayGroup>? get timelineGroups;

  @BuiltValueField(wireName: r'route_segments')
  BuiltList<CompiledRouteSegment>? get routeSegments;

  @BuiltValueField(wireName: r'stats')
  CompiledProjectionStats? get stats;

  CompiledProjectionResponse._();

  factory CompiledProjectionResponse([void updates(CompiledProjectionResponseBuilder b)]) = _$CompiledProjectionResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompiledProjectionResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompiledProjectionResponse> get serializer => _$CompiledProjectionResponseSerializer();
}

class _$CompiledProjectionResponseSerializer implements PrimitiveSerializer<CompiledProjectionResponse> {
  @override
  final Iterable<Type> types = const [CompiledProjectionResponse, _$CompiledProjectionResponse];

  @override
  final String wireName = r'CompiledProjectionResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompiledProjectionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'compiler_version';
    yield serializers.serialize(
      object.compilerVersion,
      specifiedType: const FullType(int),
    );
    yield r'stale';
    yield serializers.serialize(
      object.stale,
      specifiedType: const FullType(bool),
    );
    if (object.compiledAt != null) {
      yield r'compiled_at';
      yield serializers.serialize(
        object.compiledAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    if (object.timelineEntries != null) {
      yield r'timeline_entries';
      yield serializers.serialize(
        object.timelineEntries,
        specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineEntry)]),
      );
    }
    if (object.timelineGroups != null) {
      yield r'timeline_groups';
      yield serializers.serialize(
        object.timelineGroups,
        specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineDayGroup)]),
      );
    }
    if (object.routeSegments != null) {
      yield r'route_segments';
      yield serializers.serialize(
        object.routeSegments,
        specifiedType: const FullType(BuiltList, [FullType(CompiledRouteSegment)]),
      );
    }
    if (object.stats != null) {
      yield r'stats';
      yield serializers.serialize(
        object.stats,
        specifiedType: const FullType(CompiledProjectionStats),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompiledProjectionResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompiledProjectionResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'compiler_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.compilerVersion = valueDes;
          break;
        case r'stale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.stale = valueDes;
          break;
        case r'compiled_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.compiledAt = valueDes;
          break;
        case r'timeline_entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineEntry)]),
          ) as BuiltList<CompiledTimelineEntry>;
          result.timelineEntries.replace(valueDes);
          break;
        case r'timeline_groups':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CompiledTimelineDayGroup)]),
          ) as BuiltList<CompiledTimelineDayGroup>;
          result.timelineGroups.replace(valueDes);
          break;
        case r'route_segments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CompiledRouteSegment)]),
          ) as BuiltList<CompiledRouteSegment>;
          result.routeSegments.replace(valueDes);
          break;
        case r'stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CompiledProjectionStats),
          ) as CompiledProjectionStats;
          result.stats.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompiledProjectionResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompiledProjectionResponseBuilder();
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

