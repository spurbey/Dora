// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportJobListResponse extends ExportJobListResponse {
  @override
  final BuiltList<ExportJobSummaryResponse> exports;
  @override
  final int total;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int totalPages;

  factory _$ExportJobListResponse(
          [void Function(ExportJobListResponseBuilder)? updates]) =>
      (ExportJobListResponseBuilder()..update(updates))._build();

  _$ExportJobListResponse._(
      {required this.exports,
      required this.total,
      required this.page,
      required this.pageSize,
      required this.totalPages})
      : super._();
  @override
  ExportJobListResponse rebuild(
          void Function(ExportJobListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportJobListResponseBuilder toBuilder() =>
      ExportJobListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportJobListResponse &&
        exports == other.exports &&
        total == other.total &&
        page == other.page &&
        pageSize == other.pageSize &&
        totalPages == other.totalPages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exports.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, pageSize.hashCode);
    _$hash = $jc(_$hash, totalPages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportJobListResponse')
          ..add('exports', exports)
          ..add('total', total)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('totalPages', totalPages))
        .toString();
  }
}

class ExportJobListResponseBuilder
    implements Builder<ExportJobListResponse, ExportJobListResponseBuilder> {
  _$ExportJobListResponse? _$v;

  ListBuilder<ExportJobSummaryResponse>? _exports;
  ListBuilder<ExportJobSummaryResponse> get exports =>
      _$this._exports ??= ListBuilder<ExportJobSummaryResponse>();
  set exports(ListBuilder<ExportJobSummaryResponse>? exports) =>
      _$this._exports = exports;

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

  ExportJobListResponseBuilder() {
    ExportJobListResponse._defaults(this);
  }

  ExportJobListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exports = $v.exports.toBuilder();
      _total = $v.total;
      _page = $v.page;
      _pageSize = $v.pageSize;
      _totalPages = $v.totalPages;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportJobListResponse other) {
    _$v = other as _$ExportJobListResponse;
  }

  @override
  void update(void Function(ExportJobListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportJobListResponse build() => _build();

  _$ExportJobListResponse _build() {
    _$ExportJobListResponse _$result;
    try {
      _$result = _$v ??
          _$ExportJobListResponse._(
            exports: exports.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'ExportJobListResponse', 'total'),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ExportJobListResponse', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(
                pageSize, r'ExportJobListResponse', 'pageSize'),
            totalPages: BuiltValueNullFieldError.checkNotNull(
                totalPages, r'ExportJobListResponse', 'totalPages'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'exports';
        exports.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ExportJobListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
