// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlaceUpdate extends PlaceUpdate {
  @override
  final String? name;
  @override
  final String? placeType;
  @override
  final num? lat;
  @override
  final num? lng;
  @override
  final String? userNotes;
  @override
  final int? userRating;
  @override
  final Date? visitDate;
  @override
  final int? orderInTrip;

  factory _$PlaceUpdate([void Function(PlaceUpdateBuilder)? updates]) =>
      (PlaceUpdateBuilder()..update(updates))._build();

  _$PlaceUpdate._(
      {this.name,
      this.placeType,
      this.lat,
      this.lng,
      this.userNotes,
      this.userRating,
      this.visitDate,
      this.orderInTrip})
      : super._();
  @override
  PlaceUpdate rebuild(void Function(PlaceUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlaceUpdateBuilder toBuilder() => PlaceUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlaceUpdate &&
        name == other.name &&
        placeType == other.placeType &&
        lat == other.lat &&
        lng == other.lng &&
        userNotes == other.userNotes &&
        userRating == other.userRating &&
        visitDate == other.visitDate &&
        orderInTrip == other.orderInTrip;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, placeType.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, userNotes.hashCode);
    _$hash = $jc(_$hash, userRating.hashCode);
    _$hash = $jc(_$hash, visitDate.hashCode);
    _$hash = $jc(_$hash, orderInTrip.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlaceUpdate')
          ..add('name', name)
          ..add('placeType', placeType)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('userNotes', userNotes)
          ..add('userRating', userRating)
          ..add('visitDate', visitDate)
          ..add('orderInTrip', orderInTrip))
        .toString();
  }
}

class PlaceUpdateBuilder implements Builder<PlaceUpdate, PlaceUpdateBuilder> {
  _$PlaceUpdate? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _placeType;
  String? get placeType => _$this._placeType;
  set placeType(String? placeType) => _$this._placeType = placeType;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _userNotes;
  String? get userNotes => _$this._userNotes;
  set userNotes(String? userNotes) => _$this._userNotes = userNotes;

  int? _userRating;
  int? get userRating => _$this._userRating;
  set userRating(int? userRating) => _$this._userRating = userRating;

  Date? _visitDate;
  Date? get visitDate => _$this._visitDate;
  set visitDate(Date? visitDate) => _$this._visitDate = visitDate;

  int? _orderInTrip;
  int? get orderInTrip => _$this._orderInTrip;
  set orderInTrip(int? orderInTrip) => _$this._orderInTrip = orderInTrip;

  PlaceUpdateBuilder() {
    PlaceUpdate._defaults(this);
  }

  PlaceUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _placeType = $v.placeType;
      _lat = $v.lat;
      _lng = $v.lng;
      _userNotes = $v.userNotes;
      _userRating = $v.userRating;
      _visitDate = $v.visitDate;
      _orderInTrip = $v.orderInTrip;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlaceUpdate other) {
    _$v = other as _$PlaceUpdate;
  }

  @override
  void update(void Function(PlaceUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlaceUpdate build() => _build();

  _$PlaceUpdate _build() {
    final _$result = _$v ??
        _$PlaceUpdate._(
          name: name,
          placeType: placeType,
          lat: lat,
          lng: lng,
          userNotes: userNotes,
          userRating: userRating,
          visitDate: visitDate,
          orderInTrip: orderInTrip,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
