//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_path_point_response.g.dart';

/// TrackingPathPointResponse
///
/// Properties:
/// * [recordedAt] 
/// * [latitude] 
/// * [longitude] 
/// * [accuracyM] 
/// * [speedMps] 
@BuiltValue()
abstract class TrackingPathPointResponse implements Built<TrackingPathPointResponse, TrackingPathPointResponseBuilder> {
  @BuiltValueField(wireName: r'recorded_at')
  DateTime get recordedAt;

  @BuiltValueField(wireName: r'latitude')
  num get latitude;

  @BuiltValueField(wireName: r'longitude')
  num get longitude;

  @BuiltValueField(wireName: r'accuracy_m')
  num? get accuracyM;

  @BuiltValueField(wireName: r'speed_mps')
  num? get speedMps;

  TrackingPathPointResponse._();

  factory TrackingPathPointResponse([void updates(TrackingPathPointResponseBuilder b)]) = _$TrackingPathPointResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingPathPointResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingPathPointResponse> get serializer => _$TrackingPathPointResponseSerializer();
}

class _$TrackingPathPointResponseSerializer implements PrimitiveSerializer<TrackingPathPointResponse> {
  @override
  final Iterable<Type> types = const [TrackingPathPointResponse, _$TrackingPathPointResponse];

  @override
  final String wireName = r'TrackingPathPointResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingPathPointResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'recorded_at';
    yield serializers.serialize(
      object.recordedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'latitude';
    yield serializers.serialize(
      object.latitude,
      specifiedType: const FullType(num),
    );
    yield r'longitude';
    yield serializers.serialize(
      object.longitude,
      specifiedType: const FullType(num),
    );
    if (object.accuracyM != null) {
      yield r'accuracy_m';
      yield serializers.serialize(
        object.accuracyM,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.speedMps != null) {
      yield r'speed_mps';
      yield serializers.serialize(
        object.speedMps,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingPathPointResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingPathPointResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'recorded_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.recordedAt = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'accuracy_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.accuracyM = valueDes;
          break;
        case r'speed_mps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.speedMps = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingPathPointResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingPathPointResponseBuilder();
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

