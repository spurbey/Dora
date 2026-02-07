// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchResult extends SearchResult {
  @override
  final String? id;
  @override
  final String name;
  @override
  final num lat;
  @override
  final num lng;
  @override
  final String? address;
  @override
  final String source_;
  @override
  final num distanceM;
  @override
  final num? rating;
  @override
  final int? popularity;
  @override
  final bool hasUserContent;
  @override
  final num? score;
  @override
  final SearchResultDebug? debug;

  factory _$SearchResult([void Function(SearchResultBuilder)? updates]) =>
      (SearchResultBuilder()..update(updates))._build();

  _$SearchResult._(
      {this.id,
      required this.name,
      required this.lat,
      required this.lng,
      this.address,
      required this.source_,
      required this.distanceM,
      this.rating,
      this.popularity,
      required this.hasUserContent,
      this.score,
      this.debug})
      : super._();
  @override
  SearchResult rebuild(void Function(SearchResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchResultBuilder toBuilder() => SearchResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchResult &&
        id == other.id &&
        name == other.name &&
        lat == other.lat &&
        lng == other.lng &&
        address == other.address &&
        source_ == other.source_ &&
        distanceM == other.distanceM &&
        rating == other.rating &&
        popularity == other.popularity &&
        hasUserContent == other.hasUserContent &&
        score == other.score &&
        debug == other.debug;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, address.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, distanceM.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, popularity.hashCode);
    _$hash = $jc(_$hash, hasUserContent.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jc(_$hash, debug.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchResult')
          ..add('id', id)
          ..add('name', name)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('address', address)
          ..add('source_', source_)
          ..add('distanceM', distanceM)
          ..add('rating', rating)
          ..add('popularity', popularity)
          ..add('hasUserContent', hasUserContent)
          ..add('score', score)
          ..add('debug', debug))
        .toString();
  }
}

class SearchResultBuilder
    implements Builder<SearchResult, SearchResultBuilder> {
  _$SearchResult? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _address;
  String? get address => _$this._address;
  set address(String? address) => _$this._address = address;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  num? _distanceM;
  num? get distanceM => _$this._distanceM;
  set distanceM(num? distanceM) => _$this._distanceM = distanceM;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  int? _popularity;
  int? get popularity => _$this._popularity;
  set popularity(int? popularity) => _$this._popularity = popularity;

  bool? _hasUserContent;
  bool? get hasUserContent => _$this._hasUserContent;
  set hasUserContent(bool? hasUserContent) =>
      _$this._hasUserContent = hasUserContent;

  num? _score;
  num? get score => _$this._score;
  set score(num? score) => _$this._score = score;

  SearchResultDebugBuilder? _debug;
  SearchResultDebugBuilder get debug =>
      _$this._debug ??= SearchResultDebugBuilder();
  set debug(SearchResultDebugBuilder? debug) => _$this._debug = debug;

  SearchResultBuilder() {
    SearchResult._defaults(this);
  }

  SearchResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _lat = $v.lat;
      _lng = $v.lng;
      _address = $v.address;
      _source_ = $v.source_;
      _distanceM = $v.distanceM;
      _rating = $v.rating;
      _popularity = $v.popularity;
      _hasUserContent = $v.hasUserContent;
      _score = $v.score;
      _debug = $v.debug?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchResult other) {
    _$v = other as _$SearchResult;
  }

  @override
  void update(void Function(SearchResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchResult build() => _build();

  _$SearchResult _build() {
    _$SearchResult _$result;
    try {
      _$result = _$v ??
          _$SearchResult._(
            id: id,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'SearchResult', 'name'),
            lat: BuiltValueNullFieldError.checkNotNull(
                lat, r'SearchResult', 'lat'),
            lng: BuiltValueNullFieldError.checkNotNull(
                lng, r'SearchResult', 'lng'),
            address: address,
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'SearchResult', 'source_'),
            distanceM: BuiltValueNullFieldError.checkNotNull(
                distanceM, r'SearchResult', 'distanceM'),
            rating: rating,
            popularity: popularity,
            hasUserContent: BuiltValueNullFieldError.checkNotNull(
                hasUserContent, r'SearchResult', 'hasUserContent'),
            score: score,
            debug: _debug?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'debug';
        _debug?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SearchResult', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
