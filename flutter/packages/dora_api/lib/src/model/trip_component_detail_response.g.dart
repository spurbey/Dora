// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_component_detail_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TripComponentDetailResponseComponentTypeEnum
    _$tripComponentDetailResponseComponentTypeEnum_place =
    const TripComponentDetailResponseComponentTypeEnum._('place');
const TripComponentDetailResponseComponentTypeEnum
    _$tripComponentDetailResponseComponentTypeEnum_route =
    const TripComponentDetailResponseComponentTypeEnum._('route');

TripComponentDetailResponseComponentTypeEnum
    _$tripComponentDetailResponseComponentTypeEnumValueOf(String name) {
  switch (name) {
    case 'place':
      return _$tripComponentDetailResponseComponentTypeEnum_place;
    case 'route':
      return _$tripComponentDetailResponseComponentTypeEnum_route;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TripComponentDetailResponseComponentTypeEnum>
    _$tripComponentDetailResponseComponentTypeEnumValues = BuiltSet<
        TripComponentDetailResponseComponentTypeEnum>(const <TripComponentDetailResponseComponentTypeEnum>[
  _$tripComponentDetailResponseComponentTypeEnum_place,
  _$tripComponentDetailResponseComponentTypeEnum_route,
]);

Serializer<TripComponentDetailResponseComponentTypeEnum>
    _$tripComponentDetailResponseComponentTypeEnumSerializer =
    _$TripComponentDetailResponseComponentTypeEnumSerializer();

class _$TripComponentDetailResponseComponentTypeEnumSerializer
    implements
        PrimitiveSerializer<TripComponentDetailResponseComponentTypeEnum> {
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
    TripComponentDetailResponseComponentTypeEnum
  ];
  @override
  final String wireName = 'TripComponentDetailResponseComponentTypeEnum';

  @override
  Object serialize(Serializers serializers,
          TripComponentDetailResponseComponentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TripComponentDetailResponseComponentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TripComponentDetailResponseComponentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TripComponentDetailResponse extends TripComponentDetailResponse {
  @override
  final String id;
  @override
  final TripComponentDetailResponseComponentTypeEnum componentType;
  @override
  final int orderInTrip;
  @override
  final PlaceResponse? placeData;
  @override
  final RouteResponse? routeData;

  factory _$TripComponentDetailResponse(
          [void Function(TripComponentDetailResponseBuilder)? updates]) =>
      (TripComponentDetailResponseBuilder()..update(updates))._build();

  _$TripComponentDetailResponse._(
      {required this.id,
      required this.componentType,
      required this.orderInTrip,
      this.placeData,
      this.routeData})
      : super._();
  @override
  TripComponentDetailResponse rebuild(
          void Function(TripComponentDetailResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripComponentDetailResponseBuilder toBuilder() =>
      TripComponentDetailResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripComponentDetailResponse &&
        id == other.id &&
        componentType == other.componentType &&
        orderInTrip == other.orderInTrip &&
        placeData == other.placeData &&
        routeData == other.routeData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, componentType.hashCode);
    _$hash = $jc(_$hash, orderInTrip.hashCode);
    _$hash = $jc(_$hash, placeData.hashCode);
    _$hash = $jc(_$hash, routeData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripComponentDetailResponse')
          ..add('id', id)
          ..add('componentType', componentType)
          ..add('orderInTrip', orderInTrip)
          ..add('placeData', placeData)
          ..add('routeData', routeData))
        .toString();
  }
}

class TripComponentDetailResponseBuilder
    implements
        Builder<TripComponentDetailResponse,
            TripComponentDetailResponseBuilder> {
  _$TripComponentDetailResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  TripComponentDetailResponseComponentTypeEnum? _componentType;
  TripComponentDetailResponseComponentTypeEnum? get componentType =>
      _$this._componentType;
  set componentType(
          TripComponentDetailResponseComponentTypeEnum? componentType) =>
      _$this._componentType = componentType;

  int? _orderInTrip;
  int? get orderInTrip => _$this._orderInTrip;
  set orderInTrip(int? orderInTrip) => _$this._orderInTrip = orderInTrip;

  PlaceResponseBuilder? _placeData;
  PlaceResponseBuilder get placeData =>
      _$this._placeData ??= PlaceResponseBuilder();
  set placeData(PlaceResponseBuilder? placeData) =>
      _$this._placeData = placeData;

  RouteResponseBuilder? _routeData;
  RouteResponseBuilder get routeData =>
      _$this._routeData ??= RouteResponseBuilder();
  set routeData(RouteResponseBuilder? routeData) =>
      _$this._routeData = routeData;

  TripComponentDetailResponseBuilder() {
    TripComponentDetailResponse._defaults(this);
  }

  TripComponentDetailResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _componentType = $v.componentType;
      _orderInTrip = $v.orderInTrip;
      _placeData = $v.placeData?.toBuilder();
      _routeData = $v.routeData?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripComponentDetailResponse other) {
    _$v = other as _$TripComponentDetailResponse;
  }

  @override
  void update(void Function(TripComponentDetailResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripComponentDetailResponse build() => _build();

  _$TripComponentDetailResponse _build() {
    _$TripComponentDetailResponse _$result;
    try {
      _$result = _$v ??
          _$TripComponentDetailResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'TripComponentDetailResponse', 'id'),
            componentType: BuiltValueNullFieldError.checkNotNull(
                componentType, r'TripComponentDetailResponse', 'componentType'),
            orderInTrip: BuiltValueNullFieldError.checkNotNull(
                orderInTrip, r'TripComponentDetailResponse', 'orderInTrip'),
            placeData: _placeData?.build(),
            routeData: _routeData?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'placeData';
        _placeData?.build();
        _$failedField = 'routeData';
        _routeData?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripComponentDetailResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
