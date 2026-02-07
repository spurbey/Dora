//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'waypoint_response.g.dart';

/// Waypoint response schema.
///
/// Properties:
/// * [lat] 
/// * [lng] 
/// * [name] 
/// * [waypointType] 
/// * [notes] 
/// * [orderInRoute] 
/// * [stoppedAt] 
/// * [id] 
/// * [routeId] 
/// * [tripId] 
/// * [userId] 
/// * [createdAt] 
@BuiltValue()
abstract class WaypointResponse implements Built<WaypointResponse, WaypointResponseBuilder> {
  @BuiltValueField(wireName: r'lat')
  num get lat;

  @BuiltValueField(wireName: r'lng')
  num get lng;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'waypoint_type')
  WaypointResponseWaypointTypeEnum get waypointType;
  // enum waypointTypeEnum {  stop,  note,  photo,  poi,  };

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  @BuiltValueField(wireName: r'order_in_route')
  int get orderInRoute;

  @BuiltValueField(wireName: r'stopped_at')
  DateTime? get stoppedAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'route_id')
  String get routeId;

  @BuiltValueField(wireName: r'trip_id')
  String get tripId;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  WaypointResponse._();

  factory WaypointResponse([void updates(WaypointResponseBuilder b)]) = _$WaypointResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WaypointResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WaypointResponse> get serializer => _$WaypointResponseSerializer();
}

class _$WaypointResponseSerializer implements PrimitiveSerializer<WaypointResponse> {
  @override
  final Iterable<Type> types = const [WaypointResponse, _$WaypointResponse];

  @override
  final String wireName = r'WaypointResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WaypointResponse object, {
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
      specifiedType: const FullType(WaypointResponseWaypointTypeEnum),
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
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'route_id';
    yield serializers.serialize(
      object.routeId,
      specifiedType: const FullType(String),
    );
    yield r'trip_id';
    yield serializers.serialize(
      object.tripId,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WaypointResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WaypointResponseBuilder result,
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
            specifiedType: const FullType(WaypointResponseWaypointTypeEnum),
          ) as WaypointResponseWaypointTypeEnum;
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
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'route_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.routeId = valueDes;
          break;
        case r'trip_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.tripId = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WaypointResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WaypointResponseBuilder();
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

class WaypointResponseWaypointTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'stop')
  static const WaypointResponseWaypointTypeEnum stop = _$waypointResponseWaypointTypeEnum_stop;
  @BuiltValueEnumConst(wireName: r'note')
  static const WaypointResponseWaypointTypeEnum note = _$waypointResponseWaypointTypeEnum_note;
  @BuiltValueEnumConst(wireName: r'photo')
  static const WaypointResponseWaypointTypeEnum photo = _$waypointResponseWaypointTypeEnum_photo;
  @BuiltValueEnumConst(wireName: r'poi')
  static const WaypointResponseWaypointTypeEnum poi = _$waypointResponseWaypointTypeEnum_poi;

  static Serializer<WaypointResponseWaypointTypeEnum> get serializer => _$waypointResponseWaypointTypeEnumSerializer;

  const WaypointResponseWaypointTypeEnum._(String name): super(name);

  static BuiltSet<WaypointResponseWaypointTypeEnum> get values => _$waypointResponseWaypointTypeEnumValues;
  static WaypointResponseWaypointTypeEnum valueOf(String name) => _$waypointResponseWaypointTypeEnumValueOf(name);
}

