// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waypoint_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const WaypointUpdateWaypointTypeEnum _$waypointUpdateWaypointTypeEnum_stop =
    const WaypointUpdateWaypointTypeEnum._('stop');
const WaypointUpdateWaypointTypeEnum _$waypointUpdateWaypointTypeEnum_note =
    const WaypointUpdateWaypointTypeEnum._('note');
const WaypointUpdateWaypointTypeEnum _$waypointUpdateWaypointTypeEnum_photo =
    const WaypointUpdateWaypointTypeEnum._('photo');
const WaypointUpdateWaypointTypeEnum _$waypointUpdateWaypointTypeEnum_poi =
    const WaypointUpdateWaypointTypeEnum._('poi');

WaypointUpdateWaypointTypeEnum _$waypointUpdateWaypointTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'stop':
      return _$waypointUpdateWaypointTypeEnum_stop;
    case 'note':
      return _$waypointUpdateWaypointTypeEnum_note;
    case 'photo':
      return _$waypointUpdateWaypointTypeEnum_photo;
    case 'poi':
      return _$waypointUpdateWaypointTypeEnum_poi;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<WaypointUpdateWaypointTypeEnum>
    _$waypointUpdateWaypointTypeEnumValues = BuiltSet<
        WaypointUpdateWaypointTypeEnum>(const <WaypointUpdateWaypointTypeEnum>[
  _$waypointUpdateWaypointTypeEnum_stop,
  _$waypointUpdateWaypointTypeEnum_note,
  _$waypointUpdateWaypointTypeEnum_photo,
  _$waypointUpdateWaypointTypeEnum_poi,
]);

Serializer<WaypointUpdateWaypointTypeEnum>
    _$waypointUpdateWaypointTypeEnumSerializer =
    _$WaypointUpdateWaypointTypeEnumSerializer();

class _$WaypointUpdateWaypointTypeEnumSerializer
    implements PrimitiveSerializer<WaypointUpdateWaypointTypeEnum> {
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
  final Iterable<Type> types = const <Type>[WaypointUpdateWaypointTypeEnum];
  @override
  final String wireName = 'WaypointUpdateWaypointTypeEnum';

  @override
  Object serialize(
          Serializers serializers, WaypointUpdateWaypointTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  WaypointUpdateWaypointTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      WaypointUpdateWaypointTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$WaypointUpdate extends WaypointUpdate {
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String? name;
  @override
  final WaypointUpdateWaypointTypeEnum? waypointType;
  @override
  final String? notes;
  @override
  final int? orderInRoute;
  @override
  final DateTime? stoppedAt;

  factory _$WaypointUpdate([void Function(WaypointUpdateBuilder)? updates]) =>
      (WaypointUpdateBuilder()..update(updates))._build();

  _$WaypointUpdate._(
      {this.lat,
      this.lng,
      this.name,
      this.waypointType,
      this.notes,
      this.orderInRoute,
      this.stoppedAt})
      : super._();
  @override
  WaypointUpdate rebuild(void Function(WaypointUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WaypointUpdateBuilder toBuilder() => WaypointUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WaypointUpdate &&
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
    return (newBuiltValueToStringHelper(r'WaypointUpdate')
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

class WaypointUpdateBuilder
    implements Builder<WaypointUpdate, WaypointUpdateBuilder> {
  _$WaypointUpdate? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  WaypointUpdateWaypointTypeEnum? _waypointType;
  WaypointUpdateWaypointTypeEnum? get waypointType => _$this._waypointType;
  set waypointType(WaypointUpdateWaypointTypeEnum? waypointType) =>
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

  WaypointUpdateBuilder() {
    WaypointUpdate._defaults(this);
  }

  WaypointUpdateBuilder get _$this {
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
  void replace(WaypointUpdate other) {
    _$v = other as _$WaypointUpdate;
  }

  @override
  void update(void Function(WaypointUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WaypointUpdate build() => _build();

  _$WaypointUpdate _build() {
    final _$result = _$v ??
        _$WaypointUpdate._(
          lat: lat,
          lng: lng,
          name: name,
          waypointType: waypointType,
          notes: notes,
          orderInRoute: orderInRoute,
          stoppedAt: stoppedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
