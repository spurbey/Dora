// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripListResponse extends TripListResponse {
  @override
  final BuiltList<TripResponse> trips;
  @override
  final int total;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int totalPages;

  factory _$TripListResponse(
          [void Function(TripListResponseBuilder)? updates]) =>
      (TripListResponseBuilder()..update(updates))._build();

  _$TripListResponse._(
      {required this.trips,
      required this.total,
      required this.page,
      required this.pageSize,
      required this.totalPages})
      : super._();
  @override
  TripListResponse rebuild(void Function(TripListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripListResponseBuilder toBuilder() =>
      TripListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripListResponse &&
        trips == other.trips &&
        total == other.total &&
        page == other.page &&
        pageSize == other.pageSize &&
        totalPages == other.totalPages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, trips.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, pageSize.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripListResponse')
          ..add('trips', trips)
          ..add('total', total)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class TripListResponseBuilder
    implements Builder<TripListResponse, TripListResponseBuilder> {
  _$TripListResponse? _$v;

  ListBuilder<TripResponse>? _trips;
  ListBuilder<TripResponse> get trips =>
      _$this._trips ??= ListBuilder<TripResponse>();
  set trips(ListBuilder<TripResponse>? trips) => _$this._trips = trips;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _pageSize;
  int? get pageSize => _$this._pageSize;
  set pageSize(int? pageSize) => _$this._pageSize = pageSize;

  int? _totalPages;
  int? get totalPages => _$this._totalPages;
  set totalPages(int? totalPages) => _$this._totalPages = totalPages;

  TripListResponseBuilder() {
    TripListResponse._defaults(this);
  }

  TripListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _trips = $v.trips.toBuilder();
      _total = $v.total;
      _page = $v.page;
      _pageSize = $v.pageSize;
      _totalPages = $v.totalPages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripListResponse other) {
    _$v = other as _$TripListResponse;
  }

  @override
  void update(void Function(TripListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripListResponse build() => _build();

  _$TripListResponse _build() {
    _$TripListResponse _$result;
    try {
      _$result = _$v ??
          _$TripListResponse._(
            trips: trips.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'TripListResponse', 'total'),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'TripListResponse', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(
                pageSize, r'TripListResponse', 'pageSize'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'TripListResponse', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'trips';
        trips.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
