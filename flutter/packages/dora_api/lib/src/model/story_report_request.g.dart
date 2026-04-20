// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_report_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StoryReportRequest extends StoryReportRequest {
  @override
  final String reason;
  @override
  final String? details;

  factory _$StoryReportRequest(
          [void Function(StoryReportRequestBuilder)? updates]) =>
      (StoryReportRequestBuilder()..update(updates))._build();

  _$StoryReportRequest._({required this.reason, this.details}) : super._();
  @override
  StoryReportRequest rebuild(
          void Function(StoryReportRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StoryReportRequestBuilder toBuilder() =>
      StoryReportRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StoryReportRequest &&
        reason == other.reason &&
        details == other.details;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StoryReportRequest')
          ..add('reason', reason)
          ..add('details', details))
        .toString();
  }
}

class StoryReportRequestBuilder
    implements Builder<StoryReportRequest, StoryReportRequestBuilder> {
  _$StoryReportRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  String? _details;
  String? get details => _$this._details;
  set details(String? details) => _$this._details = details;

  StoryReportRequestBuilder() {
    StoryReportRequest._defaults(this);
  }

  StoryReportRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _details = $v.details;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StoryReportRequest other) {
    _$v = other as _$StoryReportRequest;
  }

  @override
  void update(void Function(StoryReportRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StoryReportRequest build() => _build();

  _$StoryReportRequest _build() {
    final _$result = _$v ??
        _$StoryReportRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'StoryReportRequest', 'reason'),
          details: details,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
