// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_component_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripComponentListResponse extends TripComponentListResponse {
  @override
  final BuiltList<TripComponentResponse> components;
  @override
  final int total;
  @override
  final String tripId;

  factory _$TripComponentListResponse(
          [void Function(TripComponentListResponseBuilder)? updates]) =>
      (TripComponentListResponseBuilder()..update(updates))._build();

  _$TripComponentListResponse._(
      {required this.components, required this.total, required this.tripId})
      : super._();
  @override
  TripComponentListResponse rebuild(
          void Function(TripComponentListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripComponentListResponseBuilder toBuilder() =>
      TripComponentListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripComponentListResponse &&
        components == other.components &&
        total == other.total &&
        tripId == other.tripId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, components.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripComponentListResponse')
          ..add('components', components)
          ..add('total', total)
          ..add('tripId', tripId))
        .toString();
  }
}

class TripComponentListResponseBuilder
    implements
        Builder<TripComponentListResponse, TripComponentListResponseBuilder> {
  _$TripComponentListResponse? _$v;

  ListBuilder<TripComponentResponse>? _components;
  ListBuilder<TripComponentResponse> get components =>
      _$this._components ??= ListBuilder<TripComponentResponse>();
  set components(ListBuilder<TripComponentResponse>? components) =>
      _$this._components = components;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  TripComponentListResponseBuilder() {
    TripComponentListResponse._defaults(this);
  }

  TripComponentListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _components = $v.components.toBuilder();
      _total = $v.total;
      _tripId = $v.tripId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripComponentListResponse other) {
    _$v = other as _$TripComponentListResponse;
  }

  @override
  void update(void Function(TripComponentListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripComponentListResponse build() => _build();

  _$TripComponentListResponse _build() {
    _$TripComponentListResponse _$result;
    try {
      _$result = _$v ??
          _$TripComponentListResponse._(
            components: components.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'TripComponentListResponse', 'total'),
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TripComponentListResponse', 'tripId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'components';
        components.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripComponentListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
