//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkin_place_override.g.dart';

/// CheckinPlaceOverride
///
/// Properties:
/// * [tripPlaceId] 
/// * [name] 
/// * [latitude] 
/// * [longitude] 
@BuiltValue()
abstract class CheckinPlaceOverride implements Built<CheckinPlaceOverride, CheckinPlaceOverrideBuilder> {
  @BuiltValueField(wireName: r'trip_place_id')
  String? get tripPlaceId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  CheckinPlaceOverride._();

  factory CheckinPlaceOverride([void updates(CheckinPlaceOverrideBuilder b)]) = _$CheckinPlaceOverride;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckinPlaceOverrideBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckinPlaceOverride> get serializer => _$CheckinPlaceOverrideSerializer();
}

class _$CheckinPlaceOverrideSerializer implements PrimitiveSerializer<CheckinPlaceOverride> {
  @override
  final Iterable<Type> types = const [CheckinPlaceOverride, _$CheckinPlaceOverride];

  @override
  final String wireName = r'CheckinPlaceOverride';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckinPlaceOverride object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tripPlaceId != null) {
      yield r'trip_place_id';
      yield serializers.serialize(
        object.tripPlaceId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.latitude != null) {
      yield r'latitude';
      yield serializers.serialize(
        object.latitude,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.longitude != null) {
      yield r'longitude';
      yield serializers.serialize(
        object.longitude,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckinPlaceOverride object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckinPlaceOverrideBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'trip_place_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tripPlaceId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.longitude = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckinPlaceOverride deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckinPlaceOverrideBuilder();
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

