// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchResponse extends SearchResponse {
  @override
  final BuiltList<SearchResult> results;
  @override
  final int count;
  @override
  final String query;

  factory _$SearchResponse([void Function(SearchResponseBuilder)? updates]) =>
      (SearchResponseBuilder()..update(updates))._build();

  _$SearchResponse._(
      {required this.results, required this.count, required this.query})
      : super._();
  @override
  SearchResponse rebuild(void Function(SearchResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchResponseBuilder toBuilder() => SearchResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchResponse &&
        results == other.results &&
        count == other.count &&
        query == other.query;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, query.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchResponse')
          ..add('results', results)
          ..add('count', count)
          ..add('query', query))
        .toString();
  }
}

class SearchResponseBuilder
    implements Builder<SearchResponse, SearchResponseBuilder> {
  _$SearchResponse? _$v;

  ListBuilder<SearchResult>? _results;
  ListBuilder<SearchResult> get results =>
      _$this._results ??= ListBuilder<SearchResult>();
  set results(ListBuilder<SearchResult>? results) => _$this._results = results;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  String? _query;
  String? get query => _$this._query;
  set query(String? query) => _$this._query = query;

  SearchResponseBuilder() {
    SearchResponse._defaults(this);
  }

  SearchResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _results = $v.results.toBuilder();
      _count = $v.count;
      _query = $v.query;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchResponse other) {
    _$v = other as _$SearchResponse;
  }

  @override
  void update(void Function(SearchResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchResponse build() => _build();

  _$SearchResponse _build() {
    _$SearchResponse _$result;
    try {
      _$result = _$v ??
          _$SearchResponse._(
            results: results.build(),
            count: BuiltValueNullFieldError.checkNotNull(
                count, r'SearchResponse', 'count'),
            query: BuiltValueNullFieldError.checkNotNull(
                query, r'SearchResponse', 'query'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'results';
        results.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SearchResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
