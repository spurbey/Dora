// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WaypointResponseWaypointTypeEnum _$waypointResponseWaypointTypeEnum_stop =
    const WaypointResponseWaypointTypeEnum._('stop');
const WaypointResponseWaypointTypeEnum _$waypointResponseWaypointTypeEnum_note =
    const WaypointResponseWaypointTypeEnum._('note');
const WaypointResponseWaypointTypeEnum
    _$waypointResponseWaypointTypeEnum_photo =
    const WaypointResponseWaypointTypeEnum._('photo');
const WaypointResponseWaypointTypeEnum _$waypointResponseWaypointTypeEnum_poi =
    const WaypointResponseWaypointTypeEnum._('poi');

WaypointResponseWaypointTypeEnum _$waypointResponseWaypointTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'stop':
      return _$waypointResponseWaypointTypeEnum_stop;
    case 'note':
      return _$waypointResponseWaypointTypeEnum_note;
    case 'photo':
      return _$waypointResponseWaypointTypeEnum_photo;
    case 'poi':
      return _$waypointResponseWaypointTypeEnum_poi;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WaypointResponseWaypointTypeEnum>
    _$waypointResponseWaypointTypeEnumValues = BuiltSet<
        WaypointResponseWaypointTypeEnum>(const <WaypointResponseWaypointTypeEnum>[
  _$waypointResponseWaypointTypeEnum_stop,
  _$waypointResponseWaypointTypeEnum_note,
  _$waypointResponseWaypointTypeEnum_photo,
  _$waypointResponseWaypointTypeEnum_poi,
]);

Serializer<WaypointResponseWaypointTypeEnum>
    _$waypointResponseWaypointTypeEnumSerializer =
    _$WaypointResponseWaypointTypeEnumSerializer();

class _$WaypointResponseWaypointTypeEnumSerializer
    implements PrimitiveSerializer<WaypointResponseWaypointTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'stop': 'stop',
    'note': 'note',
    'photo': 'photo',
    'poi': 'poi',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'stop': 'stop',
    'note': 'note',
    'photo': 'photo',
    'poi': 'poi',
  };

  @override
  final Iterable<Type> types = const <Type>[WaypointResponseWaypointTypeEnum];
  @override
  final String wireName = 'WaypointResponseWaypointTypeEnum';

  @override
  Object serialize(
          Serializers serializers, WaypointResponseWaypointTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WaypointResponseWaypointTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WaypointResponseWaypointTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WaypointResponse extends WaypointResponse {
  @override
  final num lat;
  @override
  final num lng;
  @override
  final String name;
  @override
  final WaypointResponseWaypointTypeEnum waypointType;
  @override
  final String? notes;
  @override
  final int orderInRoute;
  @override
  final DateTime? stoppedAt;
  @override
  final String id;
  @override
  final String routeId;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final DateTime createdAt;

  factory _$WaypointResponse(
          [void Function(WaypointResponseBuilder)? updates]) =>
      (WaypointResponseBuilder()..update(updates))._build();

  _$WaypointResponse._(
      {required this.lat,
      required this.lng,
      required this.name,
      required this.waypointType,
      this.notes,
      required this.orderInRoute,
      this.stoppedAt,
      required this.id,
      required this.routeId,
      required this.tripId,
      required this.userId,
      required this.createdAt})
      : super._();
  @override
  WaypointResponse rebuild(void Function(WaypointResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaypointResponseBuilder toBuilder() =>
      WaypointResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaypointResponse &&
        lat == other.lat &&
        lng == other.lng &&
        name == other.name &&
        waypointType == other.waypointType &&
        notes == other.notes &&
        orderInRoute == other.orderInRoute &&
        stoppedAt == other.stoppedAt &&
        id == other.id &&
        routeId == other.routeId &&
        tripId == other.tripId &&
        userId == other.userId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, waypointType.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jc(_$hash, orderInRoute.hashCode);
    _$hash = $jc(_$hash, stoppedAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WaypointResponse')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('name', name)
          ..add('waypointType', waypointType)
          ..add('notes', notes)
          ..add('orderInRoute', orderInRoute)
          ..add('stoppedAt', stoppedAt)
          ..add('id', id)
          ..add('routeId', routeId)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class WaypointResponseBuilder
    implements Builder<WaypointResponse, WaypointResponseBuilder> {
  _$WaypointResponse? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  WaypointResponseWaypointTypeEnum? _waypointType;
  WaypointResponseWaypointTypeEnum? get waypointType => _$this._waypointType;
  set waypointType(WaypointResponseWaypointTypeEnum? waypointType) =>
      _$this._waypointType = waypointType;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  int? _orderInRoute;
  int? get orderInRoute => _$this._orderInRoute;
  set orderInRoute(int? orderInRoute) => _$this._orderInRoute = orderInRoute;

  DateTime? _stoppedAt;
  DateTime? get stoppedAt => _$this._stoppedAt;
  set stoppedAt(DateTime? stoppedAt) => _$this._stoppedAt = stoppedAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  WaypointResponseBuilder() {
    WaypointResponse._defaults(this);
  }

  WaypointResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _name = $v.name;
      _waypointType = $v.waypointType;
      _notes = $v.notes;
      _orderInRoute = $v.orderInRoute;
      _stoppedAt = $v.stoppedAt;
      _id = $v.id;
      _routeId = $v.routeId;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WaypointResponse other) {
    _$v = other as _$WaypointResponse;
  }

  @override
  void update(void Function(WaypointResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaypointResponse build() => _build();

  _$WaypointResponse _build() {
    final _$result = _$v ??
        _$WaypointResponse._(
          lat: BuiltValueNullFieldError.checkNotNull(
              lat, r'WaypointResponse', 'lat'),
          lng: BuiltValueNullFieldError.checkNotNull(
              lng, r'WaypointResponse', 'lng'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'WaypointResponse', 'name'),
          waypointType: BuiltValueNullFieldError.checkNotNull(
              waypointType, r'WaypointResponse', 'waypointType'),
          notes: notes,
          orderInRoute: BuiltValueNullFieldError.checkNotNull(
              orderInRoute, r'WaypointResponse', 'orderInRoute'),
          stoppedAt: stoppedAt,
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'WaypointResponse', 'id'),
          routeId: BuiltValueNullFieldError.checkNotNull(
              routeId, r'WaypointResponse', 'routeId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'WaypointResponse', 'tripId'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'WaypointResponse', 'userId'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'WaypointResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
