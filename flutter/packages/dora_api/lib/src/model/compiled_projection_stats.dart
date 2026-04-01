//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'compiled_projection_stats.g.dart';

/// CompiledProjectionStats
///
/// Properties:
/// * [rawEventCount] 
/// * [compiledEventCount] 
/// * [rawPointCount] 
/// * [compiledRouteSegmentCount] 
/// * [hasDrift] 
/// * [rawEventCountDelta] 
/// * [compiledEventCountDelta] 
/// * [compiledRouteSegmentCountDelta] 
/// * [rawVsCompiledEventDelta] 
/// * [driftReasons] 
@BuiltValue()
abstract class CompiledProjectionStats implements Built<CompiledProjectionStats, CompiledProjectionStatsBuilder> {
  @BuiltValueField(wireName: r'raw_event_count')
  int? get rawEventCount;

  @BuiltValueField(wireName: r'compiled_event_count')
  int? get compiledEventCount;

  @BuiltValueField(wireName: r'raw_point_count')
  int? get rawPointCount;

  @BuiltValueField(wireName: r'compiled_route_segment_count')
  int? get compiledRouteSegmentCount;

  @BuiltValueField(wireName: r'has_drift')
  bool? get hasDrift;

  @BuiltValueField(wireName: r'raw_event_count_delta')
  int? get rawEventCountDelta;

  @BuiltValueField(wireName: r'compiled_event_count_delta')
  int? get compiledEventCountDelta;

  @BuiltValueField(wireName: r'compiled_route_segment_count_delta')
  int? get compiledRouteSegmentCountDelta;

  @BuiltValueField(wireName: r'raw_vs_compiled_event_delta')
  int? get rawVsCompiledEventDelta;

  @BuiltValueField(wireName: r'drift_reasons')
  BuiltList<String>? get driftReasons;

  CompiledProjectionStats._();

  factory CompiledProjectionStats([void updates(CompiledProjectionStatsBuilder b)]) = _$CompiledProjectionStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompiledProjectionStatsBuilder b) => b
      ..rawEventCount = 0
      ..compiledEventCount = 0
      ..rawPointCount = 0
      ..compiledRouteSegmentCount = 0
      ..hasDrift = false
      ..rawEventCountDelta = 0
      ..compiledEventCountDelta = 0
      ..compiledRouteSegmentCountDelta = 0
      ..rawVsCompiledEventDelta = 0;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompiledProjectionStats> get serializer => _$CompiledProjectionStatsSerializer();
}

class _$CompiledProjectionStatsSerializer implements PrimitiveSerializer<CompiledProjectionStats> {
  @override
  final Iterable<Type> types = const [CompiledProjectionStats, _$CompiledProjectionStats];

  @override
  final String wireName = r'CompiledProjectionStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompiledProjectionStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.rawEventCount != null) {
      yield r'raw_event_count';
      yield serializers.serialize(
        object.rawEventCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.compiledEventCount != null) {
      yield r'compiled_event_count';
      yield serializers.serialize(
        object.compiledEventCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.rawPointCount != null) {
      yield r'raw_point_count';
      yield serializers.serialize(
        object.rawPointCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.compiledRouteSegmentCount != null) {
      yield r'compiled_route_segment_count';
      yield serializers.serialize(
        object.compiledRouteSegmentCount,
        specifiedType: const FullType(int),
      );
    }
    if (object.hasDrift != null) {
      yield r'has_drift';
      yield serializers.serialize(
        object.hasDrift,
        specifiedType: const FullType(bool),
      );
    }
    if (object.rawEventCountDelta != null) {
      yield r'raw_event_count_delta';
      yield serializers.serialize(
        object.rawEventCountDelta,
        specifiedType: const FullType(int),
      );
    }
    if (object.compiledEventCountDelta != null) {
      yield r'compiled_event_count_delta';
      yield serializers.serialize(
        object.compiledEventCountDelta,
        specifiedType: const FullType(int),
      );
    }
    if (object.compiledRouteSegmentCountDelta != null) {
      yield r'compiled_route_segment_count_delta';
      yield serializers.serialize(
        object.compiledRouteSegmentCountDelta,
        specifiedType: const FullType(int),
      );
    }
    if (object.rawVsCompiledEventDelta != null) {
      yield r'raw_vs_compiled_event_delta';
      yield serializers.serialize(
        object.rawVsCompiledEventDelta,
        specifiedType: const FullType(int),
      );
    }
    if (object.driftReasons != null) {
      yield r'drift_reasons';
      yield serializers.serialize(
        object.driftReasons,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CompiledProjectionStats object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompiledProjectionStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'raw_event_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rawEventCount = valueDes;
          break;
        case r'compiled_event_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.compiledEventCount = valueDes;
          break;
        case r'raw_point_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rawPointCount = valueDes;
          break;
        case r'compiled_route_segment_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.compiledRouteSegmentCount = valueDes;
          break;
        case r'has_drift':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasDrift = valueDes;
          break;
        case r'raw_event_count_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rawEventCountDelta = valueDes;
          break;
        case r'compiled_event_count_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.compiledEventCountDelta = valueDes;
          break;
        case r'compiled_route_segment_count_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.compiledRouteSegmentCountDelta = valueDes;
          break;
        case r'raw_vs_compiled_event_delta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.rawVsCompiledEventDelta = valueDes;
          break;
        case r'drift_reasons':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.driftReasons.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompiledProjectionStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompiledProjectionStatsBuilder();
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

