// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RouteResponseTransportModeEnum _$routeResponseTransportModeEnum_car =
    const RouteResponseTransportModeEnum._('car');
const RouteResponseTransportModeEnum _$routeResponseTransportModeEnum_bike =
    const RouteResponseTransportModeEnum._('bike');
const RouteResponseTransportModeEnum _$routeResponseTransportModeEnum_foot =
    const RouteResponseTransportModeEnum._('foot');
const RouteResponseTransportModeEnum _$routeResponseTransportModeEnum_air =
    const RouteResponseTransportModeEnum._('air');
const RouteResponseTransportModeEnum _$routeResponseTransportModeEnum_bus =
    const RouteResponseTransportModeEnum._('bus');
const RouteResponseTransportModeEnum _$routeResponseTransportModeEnum_train =
    const RouteResponseTransportModeEnum._('train');

RouteResponseTransportModeEnum _$routeResponseTransportModeEnumValueOf(
    String name) {
  switch (name) {
    case 'car':
      return _$routeResponseTransportModeEnum_car;
    case 'bike':
      return _$routeResponseTransportModeEnum_bike;
    case 'foot':
      return _$routeResponseTransportModeEnum_foot;
    case 'air':
      return _$routeResponseTransportModeEnum_air;
    case 'bus':
      return _$routeResponseTransportModeEnum_bus;
    case 'train':
      return _$routeResponseTransportModeEnum_train;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteResponseTransportModeEnum>
    _$routeResponseTransportModeEnumValues = BuiltSet<
        RouteResponseTransportModeEnum>(const <RouteResponseTransportModeEnum>[
  _$routeResponseTransportModeEnum_car,
  _$routeResponseTransportModeEnum_bike,
  _$routeResponseTransportModeEnum_foot,
  _$routeResponseTransportModeEnum_air,
  _$routeResponseTransportModeEnum_bus,
  _$routeResponseTransportModeEnum_train,
]);

const RouteResponseRouteCategoryEnum _$routeResponseRouteCategoryEnum_ground =
    const RouteResponseRouteCategoryEnum._('ground');
const RouteResponseRouteCategoryEnum _$routeResponseRouteCategoryEnum_air =
    const RouteResponseRouteCategoryEnum._('air');

RouteResponseRouteCategoryEnum _$routeResponseRouteCategoryEnumValueOf(
    String name) {
  switch (name) {
    case 'ground':
      return _$routeResponseRouteCategoryEnum_ground;
    case 'air':
      return _$routeResponseRouteCategoryEnum_air;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteResponseRouteCategoryEnum>
    _$routeResponseRouteCategoryEnumValues = BuiltSet<
        RouteResponseRouteCategoryEnum>(const <RouteResponseRouteCategoryEnum>[
  _$routeResponseRouteCategoryEnum_ground,
  _$routeResponseRouteCategoryEnum_air,
]);

Serializer<RouteResponseTransportModeEnum>
    _$routeResponseTransportModeEnumSerializer =
    _$RouteResponseTransportModeEnumSerializer();
Serializer<RouteResponseRouteCategoryEnum>
    _$routeResponseRouteCategoryEnumSerializer =
    _$RouteResponseRouteCategoryEnumSerializer();

class _$RouteResponseTransportModeEnumSerializer
    implements PrimitiveSerializer<RouteResponseTransportModeEnum> {
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
  final Iterable<Type> types = const <Type>[RouteResponseTransportModeEnum];
  @override
  final String wireName = 'RouteResponseTransportModeEnum';

  @override
  Object serialize(
          Serializers serializers, RouteResponseTransportModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteResponseTransportModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteResponseTransportModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteResponseRouteCategoryEnumSerializer
    implements PrimitiveSerializer<RouteResponseRouteCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ground': 'ground',
    'air': 'air',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ground': 'ground',
    'air': 'air',
  };

  @override
  final Iterable<Type> types = const <Type>[RouteResponseRouteCategoryEnum];
  @override
  final String wireName = 'RouteResponseRouteCategoryEnum';

  @override
  Object serialize(
          Serializers serializers, RouteResponseRouteCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteResponseRouteCategoryEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteResponseRouteCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteResponse extends RouteResponse {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final RouteResponseTransportModeEnum transportMode;
  @override
  final RouteResponseRouteCategoryEnum routeCategory;
  @override
  final String? startPlaceId;
  @override
  final String? endPlaceId;
  @override
  final int? orderInTrip;
  @override
  final String id;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final JsonObject routeGeojson;
  @override
  final String? polylineEncoded;
  @override
  final num? distanceKm;
  @override
  final int? durationMins;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$RouteResponse([void Function(RouteResponseBuilder)? updates]) =>
      (RouteResponseBuilder()..update(updates))._build();

  _$RouteResponse._(
      {this.name,
      this.description,
      required this.transportMode,
      required this.routeCategory,
      this.startPlaceId,
      this.endPlaceId,
      this.orderInTrip,
      required this.id,
      required this.tripId,
      required this.userId,
      required this.routeGeojson,
      this.polylineEncoded,
      this.distanceKm,
      this.durationMins,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  RouteResponse rebuild(void Function(RouteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteResponseBuilder toBuilder() => RouteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteResponse &&
        name == other.name &&
        description == other.description &&
        transportMode == other.transportMode &&
        routeCategory == other.routeCategory &&
        startPlaceId == other.startPlaceId &&
        endPlaceId == other.endPlaceId &&
        orderInTrip == other.orderInTrip &&
        id == other.id &&
        tripId == other.tripId &&
        userId == other.userId &&
        routeGeojson == other.routeGeojson &&
        polylineEncoded == other.polylineEncoded &&
        distanceKm == other.distanceKm &&
        durationMins == other.durationMins &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, routeGeojson.hashCode);
    _$hash = $jc(_$hash, polylineEncoded.hashCode);
    _$hash = $jc(_$hash, distanceKm.hashCode);
    _$hash = $jc(_$hash, durationMins.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteResponse')
          ..add('name', name)
          ..add('description', description)
          ..add('transportMode', transportMode)
          ..add('routeCategory', routeCategory)
          ..add('startPlaceId', startPlaceId)
          ..add('endPlaceId', endPlaceId)
          ..add('orderInTrip', orderInTrip)
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('routeGeojson', routeGeojson)
          ..add('polylineEncoded', polylineEncoded)
          ..add('distanceKm', distanceKm)
          ..add('durationMins', durationMins)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RouteResponseBuilder
    implements Builder<RouteResponse, RouteResponseBuilder> {
  _$RouteResponse? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  RouteResponseTransportModeEnum? _transportMode;
  RouteResponseTransportModeEnum? get transportMode => _$this._transportMode;
  set transportMode(RouteResponseTransportModeEnum? transportMode) =>
      _$this._transportMode = transportMode;

  RouteResponseRouteCategoryEnum? _routeCategory;
  RouteResponseRouteCategoryEnum? get routeCategory => _$this._routeCategory;
  set routeCategory(RouteResponseRouteCategoryEnum? routeCategory) =>
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

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  JsonObject? _routeGeojson;
  JsonObject? get routeGeojson => _$this._routeGeojson;
  set routeGeojson(JsonObject? routeGeojson) =>
      _$this._routeGeojson = routeGeojson;

  String? _polylineEncoded;
  String? get polylineEncoded => _$this._polylineEncoded;
  set polylineEncoded(String? polylineEncoded) =>
      _$this._polylineEncoded = polylineEncoded;

  num? _distanceKm;
  num? get distanceKm => _$this._distanceKm;
  set distanceKm(num? distanceKm) => _$this._distanceKm = distanceKm;

  int? _durationMins;
  int? get durationMins => _$this._durationMins;
  set durationMins(int? durationMins) => _$this._durationMins = durationMins;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RouteResponseBuilder() {
    RouteResponse._defaults(this);
  }

  RouteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _transportMode = $v.transportMode;
      _routeCategory = $v.routeCategory;
      _startPlaceId = $v.startPlaceId;
      _endPlaceId = $v.endPlaceId;
      _orderInTrip = $v.orderInTrip;
      _id = $v.id;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _routeGeojson = $v.routeGeojson;
      _polylineEncoded = $v.polylineEncoded;
      _distanceKm = $v.distanceKm;
      _durationMins = $v.durationMins;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteResponse other) {
    _$v = other as _$RouteResponse;
  }

  @override
  void update(void Function(RouteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteResponse build() => _build();

  _$RouteResponse _build() {
    final _$result = _$v ??
        _$RouteResponse._(
          name: name,
          description: description,
          transportMode: BuiltValueNullFieldError.checkNotNull(
              transportMode, r'RouteResponse', 'transportMode'),
          routeCategory: BuiltValueNullFieldError.checkNotNull(
              routeCategory, r'RouteResponse', 'routeCategory'),
          startPlaceId: startPlaceId,
          endPlaceId: endPlaceId,
          orderInTrip: orderInTrip,
          id: BuiltValueNullFieldError.checkNotNull(id, r'RouteResponse', 'id'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'RouteResponse', 'tripId'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'RouteResponse', 'userId'),
          routeGeojson: BuiltValueNullFieldError.checkNotNull(
              routeGeojson, r'RouteResponse', 'routeGeojson'),
          polylineEncoded: polylineEncoded,
          distanceKm: distanceKm,
          durationMins: durationMins,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RouteResponse', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'RouteResponse', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
