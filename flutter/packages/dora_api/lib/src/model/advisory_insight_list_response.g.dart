// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_insight_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryInsightListResponse extends AdvisoryInsightListResponse {
  @override
  final BuiltList<AdvisoryInsightResponse> insights;
  @override
  final int total;

  factory _$AdvisoryInsightListResponse(
          [void Function(AdvisoryInsightListResponseBuilder)? updates]) =>
      (AdvisoryInsightListResponseBuilder()..update(updates))._build();

  _$AdvisoryInsightListResponse._({required this.insights, required this.total})
      : super._();
  @override
  AdvisoryInsightListResponse rebuild(
          void Function(AdvisoryInsightListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryInsightListResponseBuilder toBuilder() =>
      AdvisoryInsightListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryInsightListResponse &&
        insights == other.insights &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, insights.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryInsightListResponse')
          ..add('insights', insights)
          ..add('total', total))
        .toString();
  }
}

class AdvisoryInsightListResponseBuilder
    implements
        Builder<AdvisoryInsightListResponse,
            AdvisoryInsightListResponseBuilder> {
  _$AdvisoryInsightListResponse? _$v;

  ListBuilder<AdvisoryInsightResponse>? _insights;
  ListBuilder<AdvisoryInsightResponse> get insights =>
      _$this._insights ??= ListBuilder<AdvisoryInsightResponse>();
  set insights(ListBuilder<AdvisoryInsightResponse>? insights) =>
      _$this._insights = insights;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  AdvisoryInsightListResponseBuilder() {
    AdvisoryInsightListResponse._defaults(this);
  }

  AdvisoryInsightListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _insights = $v.insights.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryInsightListResponse other) {
    _$v = other as _$AdvisoryInsightListResponse;
  }

  @override
  void update(void Function(AdvisoryInsightListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryInsightListResponse build() => _build();

  _$AdvisoryInsightListResponse _build() {
    _$AdvisoryInsightListResponse _$result;
    try {
      _$result = _$v ??
          _$AdvisoryInsightListResponse._(
            insights: insights.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'AdvisoryInsightListResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'insights';
        insights.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdvisoryInsightListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
