// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_insight_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryInsightResponse extends AdvisoryInsightResponse {
  @override
  final String id;
  @override
  final AdvisoryCategory category;
  @override
  final AdvisorySource source_;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? placeName;
  @override
  final num? placeLat;
  @override
  final num? placeLng;
  @override
  final num confidenceScore;
  @override
  final String? contextSignal;
  @override
  final String? bestFor;
  @override
  final BuiltList<String>? sourceUrls;
  @override
  final int? sourceCount;
  @override
  final AdvisoryDeliveryStatus status;
  @override
  final DateTime? observedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime createdAt;

  factory _$AdvisoryInsightResponse(
          [void Function(AdvisoryInsightResponseBuilder)? updates]) =>
      (AdvisoryInsightResponseBuilder()..update(updates))._build();

  _$AdvisoryInsightResponse._(
      {required this.id,
      required this.category,
      required this.source_,
      required this.title,
      required this.body,
      this.placeName,
      this.placeLat,
      this.placeLng,
      required this.confidenceScore,
      this.contextSignal,
      this.bestFor,
      this.sourceUrls,
      this.sourceCount,
      required this.status,
      this.observedAt,
      this.deliveredAt,
      required this.createdAt})
      : super._();
  @override
  AdvisoryInsightResponse rebuild(
          void Function(AdvisoryInsightResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryInsightResponseBuilder toBuilder() =>
      AdvisoryInsightResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryInsightResponse &&
        id == other.id &&
        category == other.category &&
        source_ == other.source_ &&
        title == other.title &&
        body == other.body &&
        placeName == other.placeName &&
        placeLat == other.placeLat &&
        placeLng == other.placeLng &&
        confidenceScore == other.confidenceScore &&
        contextSignal == other.contextSignal &&
        bestFor == other.bestFor &&
        sourceUrls == other.sourceUrls &&
        sourceCount == other.sourceCount &&
        status == other.status &&
        observedAt == other.observedAt &&
        deliveredAt == other.deliveredAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, placeName.hashCode);
    _$hash = $jc(_$hash, placeLat.hashCode);
    _$hash = $jc(_$hash, placeLng.hashCode);
    _$hash = $jc(_$hash, confidenceScore.hashCode);
    _$hash = $jc(_$hash, contextSignal.hashCode);
    _$hash = $jc(_$hash, bestFor.hashCode);
    _$hash = $jc(_$hash, sourceUrls.hashCode);
    _$hash = $jc(_$hash, sourceCount.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, observedAt.hashCode);
    _$hash = $jc(_$hash, deliveredAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryInsightResponse')
          ..add('id', id)
          ..add('category', category)
          ..add('source_', source_)
          ..add('title', title)
          ..add('body', body)
          ..add('placeName', placeName)
          ..add('placeLat', placeLat)
          ..add('placeLng', placeLng)
          ..add('confidenceScore', confidenceScore)
          ..add('contextSignal', contextSignal)
          ..add('bestFor', bestFor)
          ..add('sourceUrls', sourceUrls)
          ..add('sourceCount', sourceCount)
          ..add('status', status)
          ..add('observedAt', observedAt)
          ..add('deliveredAt', deliveredAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdvisoryInsightResponseBuilder
    implements
        Builder<AdvisoryInsightResponse, AdvisoryInsightResponseBuilder> {
  _$AdvisoryInsightResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  AdvisoryCategory? _category;
  AdvisoryCategory? get category => _$this._category;
  set category(AdvisoryCategory? category) => _$this._category = category;

  AdvisorySource? _source_;
  AdvisorySource? get source_ => _$this._source_;
  set source_(AdvisorySource? source_) => _$this._source_ = source_;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _placeName;
  String? get placeName => _$this._placeName;
  set placeName(String? placeName) => _$this._placeName = placeName;

  num? _placeLat;
  num? get placeLat => _$this._placeLat;
  set placeLat(num? placeLat) => _$this._placeLat = placeLat;

  num? _placeLng;
  num? get placeLng => _$this._placeLng;
  set placeLng(num? placeLng) => _$this._placeLng = placeLng;

  num? _confidenceScore;
  num? get confidenceScore => _$this._confidenceScore;
  set confidenceScore(num? confidenceScore) =>
      _$this._confidenceScore = confidenceScore;

  String? _contextSignal;
  String? get contextSignal => _$this._contextSignal;
  set contextSignal(String? contextSignal) =>
      _$this._contextSignal = contextSignal;

  String? _bestFor;
  String? get bestFor => _$this._bestFor;
  set bestFor(String? bestFor) => _$this._bestFor = bestFor;

  ListBuilder<String>? _sourceUrls;
  ListBuilder<String> get sourceUrls =>
      _$this._sourceUrls ??= ListBuilder<String>();
  set sourceUrls(ListBuilder<String>? sourceUrls) =>
      _$this._sourceUrls = sourceUrls;

  int? _sourceCount;
  int? get sourceCount => _$this._sourceCount;
  set sourceCount(int? sourceCount) => _$this._sourceCount = sourceCount;

  AdvisoryDeliveryStatus? _status;
  AdvisoryDeliveryStatus? get status => _$this._status;
  set status(AdvisoryDeliveryStatus? status) => _$this._status = status;

  DateTime? _observedAt;
  DateTime? get observedAt => _$this._observedAt;
  set observedAt(DateTime? observedAt) => _$this._observedAt = observedAt;

  DateTime? _deliveredAt;
  DateTime? get deliveredAt => _$this._deliveredAt;
  set deliveredAt(DateTime? deliveredAt) => _$this._deliveredAt = deliveredAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdvisoryInsightResponseBuilder() {
    AdvisoryInsightResponse._defaults(this);
  }

  AdvisoryInsightResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _category = $v.category;
      _source_ = $v.source_;
      _title = $v.title;
      _body = $v.body;
      _placeName = $v.placeName;
      _placeLat = $v.placeLat;
      _placeLng = $v.placeLng;
      _confidenceScore = $v.confidenceScore;
      _contextSignal = $v.contextSignal;
      _bestFor = $v.bestFor;
      _sourceUrls = $v.sourceUrls?.toBuilder();
      _sourceCount = $v.sourceCount;
      _status = $v.status;
      _observedAt = $v.observedAt;
      _deliveredAt = $v.deliveredAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryInsightResponse other) {
    _$v = other as _$AdvisoryInsightResponse;
  }

  @override
  void update(void Function(AdvisoryInsightResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryInsightResponse build() => _build();

  _$AdvisoryInsightResponse _build() {
    _$AdvisoryInsightResponse _$result;
    try {
      _$result = _$v ??
          _$AdvisoryInsightResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'AdvisoryInsightResponse', 'id'),
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'AdvisoryInsightResponse', 'category'),
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'AdvisoryInsightResponse', 'source_'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'AdvisoryInsightResponse', 'title'),
            body: BuiltValueNullFieldError.checkNotNull(
                body, r'AdvisoryInsightResponse', 'body'),
            placeName: placeName,
            placeLat: placeLat,
            placeLng: placeLng,
            confidenceScore: BuiltValueNullFieldError.checkNotNull(
                confidenceScore, r'AdvisoryInsightResponse', 'confidenceScore'),
            contextSignal: contextSignal,
            bestFor: bestFor,
            sourceUrls: _sourceUrls?.build(),
            sourceCount: sourceCount,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'AdvisoryInsightResponse', 'status'),
            observedAt: observedAt,
            deliveredAt: deliveredAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'AdvisoryInsightResponse', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sourceUrls';
        _sourceUrls?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdvisoryInsightResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
