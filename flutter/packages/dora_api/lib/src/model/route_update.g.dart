// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RouteUpdate extends RouteUpdate {
  @override
  final String? name;
  @override
  final String? description;
  @override
  final JsonObject? routeGeojson;
  @override
  final int? orderInTrip;

  factory _$RouteUpdate([void Function(RouteUpdateBuilder)? updates]) =>
      (RouteUpdateBuilder()..update(updates))._build();

  _$RouteUpdate._(
      {this.name, this.description, this.routeGeojson, this.orderInTrip})
      : super._();
  @override
  RouteUpdate rebuild(void Function(RouteUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteUpdateBuilder toBuilder() => RouteUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteUpdate &&
        name == other.name &&
        description == other.description &&
        routeGeojson == other.routeGeojson &&
        orderInTrip == other.orderInTrip;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, routeGeojson.hashCode);
    _$hash = $jc(_$hash, orderInTrip.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteUpdate')
          ..add('name', name)
          ..add('description', description)
          ..add('routeGeojson', routeGeojson)
          ..add('orderInTrip', orderInTrip))
        .toString();
  }
}

class RouteUpdateBuilder implements Builder<RouteUpdate, RouteUpdateBuilder> {
  _$RouteUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  JsonObject? _routeGeojson;
  JsonObject? get routeGeojson => _$this._routeGeojson;
  set routeGeojson(JsonObject? routeGeojson) =>
      _$this._routeGeojson = routeGeojson;

  int? _orderInTrip;
  int? get orderInTrip => _$this._orderInTrip;
  set orderInTrip(int? orderInTrip) => _$this._orderInTrip = orderInTrip;

  RouteUpdateBuilder() {
    RouteUpdate._defaults(this);
  }

  RouteUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _routeGeojson = $v.routeGeojson;
      _orderInTrip = $v.orderInTrip;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteUpdate other) {
    _$v = other as _$RouteUpdate;
  }

  @override
  void update(void Function(RouteUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteUpdate build() => _build();

  _$RouteUpdate _build() {
    final _$result = _$v ??
        _$RouteUpdate._(
          name: name,
          description: description,
          routeGeojson: routeGeojson,
          orderInTrip: orderInTrip,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
