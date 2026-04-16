// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_job_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryJobListResponse extends AdvisoryJobListResponse {
  @override
  final BuiltList<AdvisoryJobResponse> jobs;
  @override
  final int total;

  factory _$AdvisoryJobListResponse(
          [void Function(AdvisoryJobListResponseBuilder)? updates]) =>
      (AdvisoryJobListResponseBuilder()..update(updates))._build();

  _$AdvisoryJobListResponse._({required this.jobs, required this.total})
      : super._();
  @override
  AdvisoryJobListResponse rebuild(
          void Function(AdvisoryJobListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryJobListResponseBuilder toBuilder() =>
      AdvisoryJobListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryJobListResponse &&
        jobs == other.jobs &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobs.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryJobListResponse')
          ..add('jobs', jobs)
          ..add('total', total))
        .toString();
  }
}

class AdvisoryJobListResponseBuilder
    implements
        Builder<AdvisoryJobListResponse, AdvisoryJobListResponseBuilder> {
  _$AdvisoryJobListResponse? _$v;

  ListBuilder<AdvisoryJobResponse>? _jobs;
  ListBuilder<AdvisoryJobResponse> get jobs =>
      _$this._jobs ??= ListBuilder<AdvisoryJobResponse>();
  set jobs(ListBuilder<AdvisoryJobResponse>? jobs) => _$this._jobs = jobs;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  AdvisoryJobListResponseBuilder() {
    AdvisoryJobListResponse._defaults(this);
  }

  AdvisoryJobListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobs = $v.jobs.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryJobListResponse other) {
    _$v = other as _$AdvisoryJobListResponse;
  }

  @override
  void update(void Function(AdvisoryJobListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryJobListResponse build() => _build();

  _$AdvisoryJobListResponse _build() {
    _$AdvisoryJobListResponse _$result;
    try {
      _$result = _$v ??
          _$AdvisoryJobListResponse._(
            jobs: jobs.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'AdvisoryJobListResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'jobs';
        jobs.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdvisoryJobListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
