// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_component_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripComponentResponseComponentTypeEnum
    _$tripComponentResponseComponentTypeEnum_place =
    const TripComponentResponseComponentTypeEnum._('place');
const TripComponentResponseComponentTypeEnum
    _$tripComponentResponseComponentTypeEnum_route =
    const TripComponentResponseComponentTypeEnum._('route');

TripComponentResponseComponentTypeEnum
    _$tripComponentResponseComponentTypeEnumValueOf(String name) {
  switch (name) {
    case 'place':
      return _$tripComponentResponseComponentTypeEnum_place;
    case 'route':
      return _$tripComponentResponseComponentTypeEnum_route;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripComponentResponseComponentTypeEnum>
    _$tripComponentResponseComponentTypeEnumValues = BuiltSet<
        TripComponentResponseComponentTypeEnum>(const <TripComponentResponseComponentTypeEnum>[
  _$tripComponentResponseComponentTypeEnum_place,
  _$tripComponentResponseComponentTypeEnum_route,
]);

Serializer<TripComponentResponseComponentTypeEnum>
    _$tripComponentResponseComponentTypeEnumSerializer =
    _$TripComponentResponseComponentTypeEnumSerializer();

class _$TripComponentResponseComponentTypeEnumSerializer
    implements PrimitiveSerializer<TripComponentResponseComponentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'place': 'place',
    'route': 'route',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'place': 'place',
    'route': 'route',
  };

  @override
  final Iterable<Type> types = const <Type>[
    TripComponentResponseComponentTypeEnum
  ];
  @override
  final String wireName = 'TripComponentResponseComponentTypeEnum';

  @override
  Object serialize(Serializers serializers,
          TripComponentResponseComponentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripComponentResponseComponentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripComponentResponseComponentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripComponentResponse extends TripComponentResponse {
  @override
  final String id;
  @override
  final String tripId;
  @override
  final TripComponentResponseComponentTypeEnum componentType;
  @override
  final String name;
  @override
  final int orderInTrip;
  @override
  final DateTime createdAt;

  factory _$TripComponentResponse(
          [void Function(TripComponentResponseBuilder)? updates]) =>
      (TripComponentResponseBuilder()..update(updates))._build();

  _$TripComponentResponse._(
      {required this.id,
      required this.tripId,
      required this.componentType,
      required this.name,
      required this.orderInTrip,
      required this.createdAt})
      : super._();
  @override
  TripComponentResponse rebuild(
          void Function(TripComponentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripComponentResponseBuilder toBuilder() =>
      TripComponentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripComponentResponse &&
        id == other.id &&
        tripId == other.tripId &&
        componentType == other.componentType &&
        name == other.name &&
        orderInTrip == other.orderInTrip &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, componentType.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, orderInTrip.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripComponentResponse')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('componentType', componentType)
          ..add('name', name)
          ..add('orderInTrip', orderInTrip)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class TripComponentResponseBuilder
    implements Builder<TripComponentResponse, TripComponentResponseBuilder> {
  _$TripComponentResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  TripComponentResponseComponentTypeEnum? _componentType;
  TripComponentResponseComponentTypeEnum? get componentType =>
      _$this._componentType;
  set componentType(TripComponentResponseComponentTypeEnum? componentType) =>
      _$this._componentType = componentType;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _orderInTrip;
  int? get orderInTrip => _$this._orderInTrip;
  set orderInTrip(int? orderInTrip) => _$this._orderInTrip = orderInTrip;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  TripComponentResponseBuilder() {
    TripComponentResponse._defaults(this);
  }

  TripComponentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _componentType = $v.componentType;
      _name = $v.name;
      _orderInTrip = $v.orderInTrip;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripComponentResponse other) {
    _$v = other as _$TripComponentResponse;
  }

  @override
  void update(void Function(TripComponentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripComponentResponse build() => _build();

  _$TripComponentResponse _build() {
    final _$result = _$v ??
        _$TripComponentResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'TripComponentResponse', 'id'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'TripComponentResponse', 'tripId'),
          componentType: BuiltValueNullFieldError.checkNotNull(
              componentType, r'TripComponentResponse', 'componentType'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TripComponentResponse', 'name'),
          orderInTrip: BuiltValueNullFieldError.checkNotNull(
              orderInTrip, r'TripComponentResponse', 'orderInTrip'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'TripComponentResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
