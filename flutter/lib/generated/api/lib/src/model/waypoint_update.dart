//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waypoint_update.g.dart';

/// Waypoint update schema (partial updates).  All fields are optional.
///
/// Properties:
/// * [lat] 
/// * [lng] 
/// * [name] 
/// * [waypointType] 
/// * [notes] 
/// * [orderInRoute] 
/// * [stoppedAt] 
@BuiltValue()
abstract class WaypointUpdate implements Built<WaypointUpdate, WaypointUpdateBuilder> {
  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'waypoint_type')
  WaypointUpdateWaypointTypeEnum? get waypointType;
  // enum waypointTypeEnum {  stop,  note,  photo,  poi,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'order_in_route')
  int? get orderInRoute;

  @BuiltValueField(wireName: r'stopped_at')
  DateTime? get stoppedAt;

  WaypointUpdate._();

  factory WaypointUpdate([void updates(WaypointUpdateBuilder b)]) = _$WaypointUpdate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaypointUpdateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaypointUpdate> get serializer => _$WaypointUpdateSerializer();
}

class _$WaypointUpdateSerializer implements PrimitiveSerializer<WaypointUpdate> {
  @override
  final Iterable<Type> types = const [WaypointUpdate, _$WaypointUpdate];

  @override
  final String wireName = r'WaypointUpdate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaypointUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.waypointType != null) {
      yield r'waypoint_type';
      yield serializers.serialize(
        object.waypointType,
        specifiedType: const FullType.nullable(WaypointUpdateWaypointTypeEnum),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.orderInRoute != null) {
      yield r'order_in_route';
      yield serializers.serialize(
        object.orderInRoute,
        specifiedType: const FullType.nullable(int),
      );
    }
    if (object.stoppedAt != null) {
      yield r'stopped_at';
      yield serializers.serialize(
        object.stoppedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WaypointUpdate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WaypointUpdateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'waypoint_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(WaypointUpdateWaypointTypeEnum),
          ) as WaypointUpdateWaypointTypeEnum?;
          if (valueDes == null) continue;
          result.waypointType = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.notes = valueDes;
          break;
        case r'order_in_route':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.orderInRoute = valueDes;
          break;
        case r'stopped_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.stoppedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WaypointUpdate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaypointUpdateBuilder();
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

class WaypointUpdateWaypointTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'stop')
  static const WaypointUpdateWaypointTypeEnum stop = _$waypointUpdateWaypointTypeEnum_stop;
  @BuiltValueEnumConst(wireName: r'note')
  static const WaypointUpdateWaypointTypeEnum note = _$waypointUpdateWaypointTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'photo')
  static const WaypointUpdateWaypointTypeEnum photo = _$waypointUpdateWaypointTypeEnum_photo;
  @BuiltValueEnumConst(wireName: r'poi')
  static const WaypointUpdateWaypointTypeEnum poi = _$waypointUpdateWaypointTypeEnum_poi;

  static Serializer<WaypointUpdateWaypointTypeEnum> get serializer => _$waypointUpdateWaypointTypeEnumSerializer;

  const WaypointUpdateWaypointTypeEnum._(String name): super(name);

  static BuiltSet<WaypointUpdateWaypointTypeEnum> get values => _$waypointUpdateWaypointTypeEnumValues;
  static WaypointUpdateWaypointTypeEnum valueOf(String name) => _$waypointUpdateWaypointTypeEnumValueOf(name);
}

