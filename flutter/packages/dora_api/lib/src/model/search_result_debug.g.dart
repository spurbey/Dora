// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_debug.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SearchResultDebug extends SearchResultDebug {
  @override
  final num sourceScore;
  @override
  final num sourceContribution;
  @override
  final num textScore;
  @override
  final num textContribution;
  @override
  final num popularityScore;
  @override
  final num popularityContribution;
  @override
  final num freshnessScore;
  @override
  final num freshnessContribution;
  @override
  final num finalScore;
  @override
  final String breakdown;

  factory _$SearchResultDebug(
          [void Function(SearchResultDebugBuilder)? updates]) =>
      (SearchResultDebugBuilder()..update(updates))._build();

  _$SearchResultDebug._(
      {required this.sourceScore,
      required this.sourceContribution,
      required this.textScore,
      required this.textContribution,
      required this.popularityScore,
      required this.popularityContribution,
      required this.freshnessScore,
      required this.freshnessContribution,
      required this.finalScore,
      required this.breakdown})
      : super._();
  @override
  SearchResultDebug rebuild(void Function(SearchResultDebugBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SearchResultDebugBuilder toBuilder() =>
      SearchResultDebugBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SearchResultDebug &&
        sourceScore == other.sourceScore &&
        sourceContribution == other.sourceContribution &&
        textScore == other.textScore &&
        textContribution == other.textContribution &&
        popularityScore == other.popularityScore &&
        popularityContribution == other.popularityContribution &&
        freshnessScore == other.freshnessScore &&
        freshnessContribution == other.freshnessContribution &&
        finalScore == other.finalScore &&
        breakdown == other.breakdown;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceScore.hashCode);
    _$hash = $jc(_$hash, sourceContribution.hashCode);
    _$hash = $jc(_$hash, textScore.hashCode);
    _$hash = $jc(_$hash, textContribution.hashCode);
    _$hash = $jc(_$hash, popularityScore.hashCode);
    _$hash = $jc(_$hash, popularityContribution.hashCode);
    _$hash = $jc(_$hash, freshnessScore.hashCode);
    _$hash = $jc(_$hash, freshnessContribution.hashCode);
    _$hash = $jc(_$hash, finalScore.hashCode);
    _$hash = $jc(_$hash, breakdown.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SearchResultDebug')
          ..add('sourceScore', sourceScore)
          ..add('sourceContribution', sourceContribution)
          ..add('textScore', textScore)
          ..add('textContribution', textContribution)
          ..add('popularityScore', popularityScore)
          ..add('popularityContribution', popularityContribution)
          ..add('freshnessScore', freshnessScore)
          ..add('freshnessContribution', freshnessContribution)
          ..add('finalScore', finalScore)
          ..add('breakdown', breakdown))
        .toString();
  }
}

class SearchResultDebugBuilder
    implements Builder<SearchResultDebug, SearchResultDebugBuilder> {
  _$SearchResultDebug? _$v;

  num? _sourceScore;
  num? get sourceScore => _$this._sourceScore;
  set sourceScore(num? sourceScore) => _$this._sourceScore = sourceScore;

  num? _sourceContribution;
  num? get sourceContribution => _$this._sourceContribution;
  set sourceContribution(num? sourceContribution) =>
      _$this._sourceContribution = sourceContribution;

  num? _textScore;
  num? get textScore => _$this._textScore;
  set textScore(num? textScore) => _$this._textScore = textScore;

  num? _textContribution;
  num? get textContribution => _$this._textContribution;
  set textContribution(num? textContribution) =>
      _$this._textContribution = textContribution;

  num? _popularityScore;
  num? get popularityScore => _$this._popularityScore;
  set popularityScore(num? popularityScore) =>
      _$this._popularityScore = popularityScore;

  num? _popularityContribution;
  num? get popularityContribution => _$this._popularityContribution;
  set popularityContribution(num? popularityContribution) =>
      _$this._popularityContribution = popularityContribution;

  num? _freshnessScore;
  num? get freshnessScore => _$this._freshnessScore;
  set freshnessScore(num? freshnessScore) =>
      _$this._freshnessScore = freshnessScore;

  num? _freshnessContribution;
  num? get freshnessContribution => _$this._freshnessContribution;
  set freshnessContribution(num? freshnessContribution) =>
      _$this._freshnessContribution = freshnessContribution;

  num? _finalScore;
  num? get finalScore => _$this._finalScore;
  set finalScore(num? finalScore) => _$this._finalScore = finalScore;

  String? _breakdown;
  String? get breakdown => _$this._breakdown;
  set breakdown(String? breakdown) => _$this._breakdown = breakdown;

  SearchResultDebugBuilder() {
    SearchResultDebug._defaults(this);
  }

  SearchResultDebugBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceScore = $v.sourceScore;
      _sourceContribution = $v.sourceContribution;
      _textScore = $v.textScore;
      _textContribution = $v.textContribution;
      _popularityScore = $v.popularityScore;
      _popularityContribution = $v.popularityContribution;
      _freshnessScore = $v.freshnessScore;
      _freshnessContribution = $v.freshnessContribution;
      _finalScore = $v.finalScore;
      _breakdown = $v.breakdown;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SearchResultDebug other) {
    _$v = other as _$SearchResultDebug;
  }

  @override
  void update(void Function(SearchResultDebugBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SearchResultDebug build() => _build();

  _$SearchResultDebug _build() {
    final _$result = _$v ??
        _$SearchResultDebug._(
          sourceScore: BuiltValueNullFieldError.checkNotNull(
              sourceScore, r'SearchResultDebug', 'sourceScore'),
          sourceContribution: BuiltValueNullFieldError.checkNotNull(
              sourceContribution, r'SearchResultDebug', 'sourceContribution'),
          textScore: BuiltValueNullFieldError.checkNotNull(
              textScore, r'SearchResultDebug', 'textScore'),
          textContribution: BuiltValueNullFieldError.checkNotNull(
              textContribution, r'SearchResultDebug', 'textContribution'),
          popularityScore: BuiltValueNullFieldError.checkNotNull(
              popularityScore, r'SearchResultDebug', 'popularityScore'),
          popularityContribution: BuiltValueNullFieldError.checkNotNull(
              popularityContribution,
              r'SearchResultDebug',
              'popularityContribution'),
          freshnessScore: BuiltValueNullFieldError.checkNotNull(
              freshnessScore, r'SearchResultDebug', 'freshnessScore'),
          freshnessContribution: BuiltValueNullFieldError.checkNotNull(
              freshnessContribution,
              r'SearchResultDebug',
              'freshnessContribution'),
          finalScore: BuiltValueNullFieldError.checkNotNull(
              finalScore, r'SearchResultDebug', 'finalScore'),
          breakdown: BuiltValueNullFieldError.checkNotNull(
              breakdown, r'SearchResultDebug', 'breakdown'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
