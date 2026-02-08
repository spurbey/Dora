//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waypoint_create.g.dart';

/// Waypoint creation schema.  Used for POST /routes/{route_id}/waypoints endpoint. route_id is taken from URL path parameter.
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
abstract class WaypointCreate implements Built<WaypointCreate, WaypointCreateBuilder> {
  @BuiltValueField(wireName: r'lat')
  num get lat;

  @BuiltValueField(wireName: r'lng')
  num get lng;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'waypoint_type')
  WaypointCreateWaypointTypeEnum get waypointType;
  // enum waypointTypeEnum {  stop,  note,  photo,  poi,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'order_in_route')
  int get orderInRoute;

  @BuiltValueField(wireName: r'stopped_at')
  DateTime? get stoppedAt;

  WaypointCreate._();

  factory WaypointCreate([void updates(WaypointCreateBuilder b)]) = _$WaypointCreate;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaypointCreateBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaypointCreate> get serializer => _$WaypointCreateSerializer();
}

class _$WaypointCreateSerializer implements PrimitiveSerializer<WaypointCreate> {
  @override
  final Iterable<Type> types = const [WaypointCreate, _$WaypointCreate];

  @override
  final String wireName = r'WaypointCreate';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaypointCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'lat';
    yield serializers.serialize(
      object.lat,
      specifiedType: const FullType(num),
    );
    yield r'lng';
    yield serializers.serialize(
      object.lng,
      specifiedType: const FullType(num),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'waypoint_type';
    yield serializers.serialize(
      object.waypointType,
      specifiedType: const FullType(WaypointCreateWaypointTypeEnum),
    );
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'order_in_route';
    yield serializers.serialize(
      object.orderInRoute,
      specifiedType: const FullType(int),
    );
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
    WaypointCreate object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WaypointCreateBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.lng = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'waypoint_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WaypointCreateWaypointTypeEnum),
          ) as WaypointCreateWaypointTypeEnum;
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
            specifiedType: const FullType(int),
          ) as int;
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
  WaypointCreate deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaypointCreateBuilder();
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

class WaypointCreateWaypointTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'stop')
  static const WaypointCreateWaypointTypeEnum stop = _$waypointCreateWaypointTypeEnum_stop;
  @BuiltValueEnumConst(wireName: r'note')
  static const WaypointCreateWaypointTypeEnum note = _$waypointCreateWaypointTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'photo')
  static const WaypointCreateWaypointTypeEnum photo = _$waypointCreateWaypointTypeEnum_photo;
  @BuiltValueEnumConst(wireName: r'poi')
  static const WaypointCreateWaypointTypeEnum poi = _$waypointCreateWaypointTypeEnum_poi;

  static Serializer<WaypointCreateWaypointTypeEnum> get serializer => _$waypointCreateWaypointTypeEnumSerializer;

  const WaypointCreateWaypointTypeEnum._(String name): super(name);

  static BuiltSet<WaypointCreateWaypointTypeEnum> get values => _$waypointCreateWaypointTypeEnumValues;
  static WaypointCreateWaypointTypeEnum valueOf(String name) => _$waypointCreateWaypointTypeEnumValueOf(name);
}

