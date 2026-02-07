// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WaypointCreateWaypointTypeEnum _$waypointCreateWaypointTypeEnum_stop =
    const WaypointCreateWaypointTypeEnum._('stop');
const WaypointCreateWaypointTypeEnum _$waypointCreateWaypointTypeEnum_note =
    const WaypointCreateWaypointTypeEnum._('note');
const WaypointCreateWaypointTypeEnum _$waypointCreateWaypointTypeEnum_photo =
    const WaypointCreateWaypointTypeEnum._('photo');
const WaypointCreateWaypointTypeEnum _$waypointCreateWaypointTypeEnum_poi =
    const WaypointCreateWaypointTypeEnum._('poi');

WaypointCreateWaypointTypeEnum _$waypointCreateWaypointTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'stop':
      return _$waypointCreateWaypointTypeEnum_stop;
    case 'note':
      return _$waypointCreateWaypointTypeEnum_note;
    case 'photo':
      return _$waypointCreateWaypointTypeEnum_photo;
    case 'poi':
      return _$waypointCreateWaypointTypeEnum_poi;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WaypointCreateWaypointTypeEnum>
    _$waypointCreateWaypointTypeEnumValues = BuiltSet<
        WaypointCreateWaypointTypeEnum>(const <WaypointCreateWaypointTypeEnum>[
  _$waypointCreateWaypointTypeEnum_stop,
  _$waypointCreateWaypointTypeEnum_note,
  _$waypointCreateWaypointTypeEnum_photo,
  _$waypointCreateWaypointTypeEnum_poi,
]);

Serializer<WaypointCreateWaypointTypeEnum>
    _$waypointCreateWaypointTypeEnumSerializer =
    _$WaypointCreateWaypointTypeEnumSerializer();

class _$WaypointCreateWaypointTypeEnumSerializer
    implements PrimitiveSerializer<WaypointCreateWaypointTypeEnum> {
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
  final Iterable<Type> types = const <Type>[WaypointCreateWaypointTypeEnum];
  @override
  final String wireName = 'WaypointCreateWaypointTypeEnum';

  @override
  Object serialize(
          Serializers serializers, WaypointCreateWaypointTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WaypointCreateWaypointTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WaypointCreateWaypointTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WaypointCreate extends WaypointCreate {
  @override
  final num lat;
  @override
  final num lng;
  @override
  final String name;
  @override
  final WaypointCreateWaypointTypeEnum waypointType;
  @override
  final String? notes;
  @override
  final int orderInRoute;
  @override
  final DateTime? stoppedAt;

  factory _$WaypointCreate([void Function(WaypointCreateBuilder)? updates]) =>
      (WaypointCreateBuilder()..update(updates))._build();

  _$WaypointCreate._(
      {required this.lat,
      required this.lng,
      required this.name,
      required this.waypointType,
      this.notes,
      required this.orderInRoute,
      this.stoppedAt})
      : super._();
  @override
  WaypointCreate rebuild(void Function(WaypointCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaypointCreateBuilder toBuilder() => WaypointCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaypointCreate &&
        lat == other.lat &&
        lng == other.lng &&
        name == other.name &&
        waypointType == other.waypointType &&
        notes == other.notes &&
        orderInRoute == other.orderInRoute &&
        stoppedAt == other.stoppedAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WaypointCreate')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('name', name)
          ..add('waypointType', waypointType)
          ..add('notes', notes)
          ..add('orderInRoute', orderInRoute)
          ..add('stoppedAt', stoppedAt))
        .toString();
  }
}

class WaypointCreateBuilder
    implements Builder<WaypointCreate, WaypointCreateBuilder> {
  _$WaypointCreate? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  WaypointCreateWaypointTypeEnum? _waypointType;
  WaypointCreateWaypointTypeEnum? get waypointType => _$this._waypointType;
  set waypointType(WaypointCreateWaypointTypeEnum? waypointType) =>
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

  WaypointCreateBuilder() {
    WaypointCreate._defaults(this);
  }

  WaypointCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _name = $v.name;
      _waypointType = $v.waypointType;
      _notes = $v.notes;
      _orderInRoute = $v.orderInRoute;
      _stoppedAt = $v.stoppedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WaypointCreate other) {
    _$v = other as _$WaypointCreate;
  }

  @override
  void update(void Function(WaypointCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaypointCreate build() => _build();

  _$WaypointCreate _build() {
    final _$result = _$v ??
        _$WaypointCreate._(
          lat: BuiltValueNullFieldError.checkNotNull(
              lat, r'WaypointCreate', 'lat'),
          lng: BuiltValueNullFieldError.checkNotNull(
              lng, r'WaypointCreate', 'lng'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'WaypointCreate', 'name'),
          waypointType: BuiltValueNullFieldError.checkNotNull(
              waypointType, r'WaypointCreate', 'waypointType'),
          notes: notes,
          orderInRoute: BuiltValueNullFieldError.checkNotNull(
              orderInRoute, r'WaypointCreate', 'orderInRoute'),
          stoppedAt: stoppedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
