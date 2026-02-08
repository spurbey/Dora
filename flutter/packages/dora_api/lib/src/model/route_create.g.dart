// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RouteCreateTransportModeEnum _$routeCreateTransportModeEnum_car =
    const RouteCreateTransportModeEnum._('car');
const RouteCreateTransportModeEnum _$routeCreateTransportModeEnum_bike =
    const RouteCreateTransportModeEnum._('bike');
const RouteCreateTransportModeEnum _$routeCreateTransportModeEnum_foot =
    const RouteCreateTransportModeEnum._('foot');
const RouteCreateTransportModeEnum _$routeCreateTransportModeEnum_air =
    const RouteCreateTransportModeEnum._('air');
const RouteCreateTransportModeEnum _$routeCreateTransportModeEnum_bus =
    const RouteCreateTransportModeEnum._('bus');
const RouteCreateTransportModeEnum _$routeCreateTransportModeEnum_train =
    const RouteCreateTransportModeEnum._('train');

RouteCreateTransportModeEnum _$routeCreateTransportModeEnumValueOf(
    String name) {
  switch (name) {
    case 'car':
      return _$routeCreateTransportModeEnum_car;
    case 'bike':
      return _$routeCreateTransportModeEnum_bike;
    case 'foot':
      return _$routeCreateTransportModeEnum_foot;
    case 'air':
      return _$routeCreateTransportModeEnum_air;
    case 'bus':
      return _$routeCreateTransportModeEnum_bus;
    case 'train':
      return _$routeCreateTransportModeEnum_train;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteCreateTransportModeEnum>
    _$routeCreateTransportModeEnumValues =
    BuiltSet<RouteCreateTransportModeEnum>(const <RouteCreateTransportModeEnum>[
  _$routeCreateTransportModeEnum_car,
  _$routeCreateTransportModeEnum_bike,
  _$routeCreateTransportModeEnum_foot,
  _$routeCreateTransportModeEnum_air,
  _$routeCreateTransportModeEnum_bus,
  _$routeCreateTransportModeEnum_train,
]);

const RouteCreateRouteCategoryEnum _$routeCreateRouteCategoryEnum_ground =
    const RouteCreateRouteCategoryEnum._('ground');
const RouteCreateRouteCategoryEnum _$routeCreateRouteCategoryEnum_air =
    const RouteCreateRouteCategoryEnum._('air');

RouteCreateRouteCategoryEnum _$routeCreateRouteCategoryEnumValueOf(
    String name) {
  switch (name) {
    case 'ground':
      return _$routeCreateRouteCategoryEnum_ground;
    case 'air':
      return _$routeCreateRouteCategoryEnum_air;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteCreateRouteCategoryEnum>
    _$routeCreateRouteCategoryEnumValues =
    BuiltSet<RouteCreateRouteCategoryEnum>(const <RouteCreateRouteCategoryEnum>[
  _$routeCreateRouteCategoryEnum_ground,
  _$routeCreateRouteCategoryEnum_air,
]);

Serializer<RouteCreateTransportModeEnum>
    _$routeCreateTransportModeEnumSerializer =
    _$RouteCreateTransportModeEnumSerializer();
Serializer<RouteCreateRouteCategoryEnum>
    _$routeCreateRouteCategoryEnumSerializer =
    _$RouteCreateRouteCategoryEnumSerializer();

class _$RouteCreateTransportModeEnumSerializer
    implements PrimitiveSerializer<RouteCreateTransportModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'car': 'car',
    'bike': 'bike',
    'foot': 'foot',
    'air': 'air',
    'bus': 'bus',
    'train': 'train',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'car': 'car',
    'bike': 'bike',
    'foot': 'foot',
    'air': 'air',
    'bus': 'bus',
    'train': 'train',
  };

  @override
  final Iterable<Type> types = const <Type>[RouteCreateTransportModeEnum];
  @override
  final String wireName = 'RouteCreateTransportModeEnum';

  @override
  Object serialize(Serializers serializers, RouteCreateTransportModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteCreateTransportModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteCreateTransportModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteCreateRouteCategoryEnumSerializer
    implements PrimitiveSerializer<RouteCreateRouteCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ground': 'ground',
    'air': 'air',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ground': 'ground',
    'air': 'air',
  };

  @override
  final Iterable<Type> types = const <Type>[RouteCreateRouteCategoryEnum];
  @override
  final String wireName = 'RouteCreateRouteCategoryEnum';

  @override
  Object serialize(Serializers serializers, RouteCreateRouteCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteCreateRouteCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteCreateRouteCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteCreate extends RouteCreate {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final RouteCreateTransportModeEnum transportMode;
  @override
  final RouteCreateRouteCategoryEnum routeCategory;
  @override
  final String? startPlaceId;
  @override
  final String? endPlaceId;
  @override
  final int? orderInTrip;
  @override
  final JsonObject routeGeojson;

  factory _$RouteCreate([void Function(RouteCreateBuilder)? updates]) =>
      (RouteCreateBuilder()..update(updates))._build();

  _$RouteCreate._(
      {this.name,
      this.description,
      required this.transportMode,
      required this.routeCategory,
      this.startPlaceId,
      this.endPlaceId,
      this.orderInTrip,
      required this.routeGeojson})
      : super._();
  @override
  RouteCreate rebuild(void Function(RouteCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteCreateBuilder toBuilder() => RouteCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteCreate &&
        name == other.name &&
        description == other.description &&
        transportMode == other.transportMode &&
        routeCategory == other.routeCategory &&
        startPlaceId == other.startPlaceId &&
        endPlaceId == other.endPlaceId &&
        orderInTrip == other.orderInTrip &&
        routeGeojson == other.routeGeojson;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, transportMode.hashCode);
    _$hash = $jc(_$hash, routeCategory.hashCode);
    _$hash = $jc(_$hash, startPlaceId.hashCode);
    _$hash = $jc(_$hash, endPlaceId.hashCode);
    _$hash = $jc(_$hash, orderInTrip.hashCode);
    _$hash = $jc(_$hash, routeGeojson.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteCreate')
          ..add('name', name)
          ..add('description', description)
          ..add('transportMode', transportMode)
          ..add('routeCategory', routeCategory)
          ..add('startPlaceId', startPlaceId)
          ..add('endPlaceId', endPlaceId)
          ..add('orderInTrip', orderInTrip)
          ..add('routeGeojson', routeGeojson))
        .toString();
  }
}

class RouteCreateBuilder implements Builder<RouteCreate, RouteCreateBuilder> {
  _$RouteCreate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  RouteCreateTransportModeEnum? _transportMode;
  RouteCreateTransportModeEnum? get transportMode => _$this._transportMode;
  set transportMode(RouteCreateTransportModeEnum? transportMode) =>
      _$this._transportMode = transportMode;

  RouteCreateRouteCategoryEnum? _routeCategory;
  RouteCreateRouteCategoryEnum? get routeCategory => _$this._routeCategory;
  set routeCategory(RouteCreateRouteCategoryEnum? routeCategory) =>
      _$this._routeCategory = routeCategory;

  String? _startPlaceId;
  String? get startPlaceId => _$this._startPlaceId;
  set startPlaceId(String? startPlaceId) => _$this._startPlaceId = startPlaceId;

  String? _endPlaceId;
  String? get endPlaceId => _$this._endPlaceId;
  set endPlaceId(String? endPlaceId) => _$this._endPlaceId = endPlaceId;

  int? _orderInTrip;
  int? get orderInTrip => _$this._orderInTrip;
  set orderInTrip(int? orderInTrip) => _$this._orderInTrip = orderInTrip;

  JsonObject? _routeGeojson;
  JsonObject? get routeGeojson => _$this._routeGeojson;
  set routeGeojson(JsonObject? routeGeojson) =>
      _$this._routeGeojson = routeGeojson;

  RouteCreateBuilder() {
    RouteCreate._defaults(this);
  }

  RouteCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _transportMode = $v.transportMode;
      _routeCategory = $v.routeCategory;
      _startPlaceId = $v.startPlaceId;
      _endPlaceId = $v.endPlaceId;
      _orderInTrip = $v.orderInTrip;
      _routeGeojson = $v.routeGeojson;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteCreate other) {
    _$v = other as _$RouteCreate;
  }

  @override
  void update(void Function(RouteCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteCreate build() => _build();

  _$RouteCreate _build() {
    final _$result = _$v ??
        _$RouteCreate._(
          name: name,
          description: description,
          transportMode: BuiltValueNullFieldError.checkNotNull(
              transportMode, r'RouteCreate', 'transportMode'),
          routeCategory: BuiltValueNullFieldError.checkNotNull(
              routeCategory, r'RouteCreate', 'routeCategory'),
          startPlaceId: startPlaceId,
          endPlaceId: endPlaceId,
          orderInTrip: orderInTrip,
          routeGeojson: BuiltValueNullFieldError.checkNotNull(
              routeGeojson, r'RouteCreate', 'routeGeojson'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
