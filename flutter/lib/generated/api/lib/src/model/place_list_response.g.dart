// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlaceListResponse extends PlaceListResponse {
  @override
  final BuiltList<PlaceResponse> places;
  @override
  final int total;
  @override
  final String? tripId;

  factory _$PlaceListResponse(
          [void Function(PlaceListResponseBuilder)? updates]) =>
      (PlaceListResponseBuilder()..update(updates))._build();

  _$PlaceListResponse._(
      {required this.places, required this.total, this.tripId})
      : super._();
  @override
  PlaceListResponse rebuild(void Function(PlaceListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlaceListResponseBuilder toBuilder() =>
      PlaceListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlaceListResponse &&
        places == other.places &&
        total == other.total &&
        tripId == other.tripId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, places.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlaceListResponse')
          ..add('places', places)
          ..add('total', total)
          ..add('tripId', tripId))
        .toString();
  }
}

class PlaceListResponseBuilder
    implements Builder<PlaceListResponse, PlaceListResponseBuilder> {
  _$PlaceListResponse? _$v;

  ListBuilder<PlaceResponse>? _places;
  ListBuilder<PlaceResponse> get places =>
      _$this._places ??= ListBuilder<PlaceResponse>();
  set places(ListBuilder<PlaceResponse>? places) => _$this._places = places;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  PlaceListResponseBuilder() {
    PlaceListResponse._defaults(this);
  }

  PlaceListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _places = $v.places.toBuilder();
      _total = $v.total;
      _tripId = $v.tripId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlaceListResponse other) {
    _$v = other as _$PlaceListResponse;
  }

  @override
  void update(void Function(PlaceListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlaceListResponse build() => _build();

  _$PlaceListResponse _build() {
    _$PlaceListResponse _$result;
    try {
      _$result = _$v ??
          _$PlaceListResponse._(
            places: places.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'PlaceListResponse', 'total'),
            tripId: tripId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'places';
        places.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlaceListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
