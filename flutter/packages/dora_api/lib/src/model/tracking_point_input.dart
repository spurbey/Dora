//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tracking_point_input.g.dart';

/// TrackingPointInput
///
/// Properties:
/// * [pointId] 
/// * [recordedAt] 
/// * [latitude] 
/// * [longitude] 
/// * [accuracyM] 
/// * [speedMps] 
/// * [headingDeg] 
/// * [altitudeM] 
/// * [provider] 
@BuiltValue()
abstract class TrackingPointInput implements Built<TrackingPointInput, TrackingPointInputBuilder> {
  @BuiltValueField(wireName: r'point_id')
  String get pointId;

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

  @BuiltValueField(wireName: r'heading_deg')
  num? get headingDeg;

  @BuiltValueField(wireName: r'altitude_m')
  num? get altitudeM;

  @BuiltValueField(wireName: r'provider')
  String? get provider;

  TrackingPointInput._();

  factory TrackingPointInput([void updates(TrackingPointInputBuilder b)]) = _$TrackingPointInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TrackingPointInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TrackingPointInput> get serializer => _$TrackingPointInputSerializer();
}

class _$TrackingPointInputSerializer implements PrimitiveSerializer<TrackingPointInput> {
  @override
  final Iterable<Type> types = const [TrackingPointInput, _$TrackingPointInput];

  @override
  final String wireName = r'TrackingPointInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TrackingPointInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'point_id';
    yield serializers.serialize(
      object.pointId,
      specifiedType: const FullType(String),
    );
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
    if (object.headingDeg != null) {
      yield r'heading_deg';
      yield serializers.serialize(
        object.headingDeg,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.altitudeM != null) {
      yield r'altitude_m';
      yield serializers.serialize(
        object.altitudeM,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TrackingPointInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TrackingPointInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'point_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pointId = valueDes;
          break;
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
        case r'heading_deg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.headingDeg = valueDes;
          break;
        case r'altitude_m':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.altitudeM = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.provider = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TrackingPointInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TrackingPointInputBuilder();
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

