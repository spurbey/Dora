// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_query_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryQueryRequest extends AdvisoryQueryRequest {
  @override
  final String queryText;

  factory _$AdvisoryQueryRequest(
          [void Function(AdvisoryQueryRequestBuilder)? updates]) =>
      (AdvisoryQueryRequestBuilder()..update(updates))._build();

  _$AdvisoryQueryRequest._({required this.queryText}) : super._();
  @override
  AdvisoryQueryRequest rebuild(
          void Function(AdvisoryQueryRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryQueryRequestBuilder toBuilder() =>
      AdvisoryQueryRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryQueryRequest && queryText == other.queryText;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, queryText.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryQueryRequest')
          ..add('queryText', queryText))
        .toString();
  }
}

class AdvisoryQueryRequestBuilder
    implements Builder<AdvisoryQueryRequest, AdvisoryQueryRequestBuilder> {
  _$AdvisoryQueryRequest? _$v;

  String? _queryText;
  String? get queryText => _$this._queryText;
  set queryText(String? queryText) => _$this._queryText = queryText;

  AdvisoryQueryRequestBuilder() {
    AdvisoryQueryRequest._defaults(this);
  }

  AdvisoryQueryRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _queryText = $v.queryText;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryQueryRequest other) {
    _$v = other as _$AdvisoryQueryRequest;
  }

  @override
  void update(void Function(AdvisoryQueryRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryQueryRequest build() => _build();

  _$AdvisoryQueryRequest _build() {
    final _$result = _$v ??
        _$AdvisoryQueryRequest._(
          queryText: BuiltValueNullFieldError.checkNotNull(
              queryText, r'AdvisoryQueryRequest', 'queryText'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
