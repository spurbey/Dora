// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_start_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryStartRequest extends AdvisoryStartRequest {
  @override
  final AdvisoryJobType? jobType;
  @override
  final JsonObject? triggerPayload;

  factory _$AdvisoryStartRequest(
          [void Function(AdvisoryStartRequestBuilder)? updates]) =>
      (AdvisoryStartRequestBuilder()..update(updates))._build();

  _$AdvisoryStartRequest._({this.jobType, this.triggerPayload}) : super._();
  @override
  AdvisoryStartRequest rebuild(
          void Function(AdvisoryStartRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryStartRequestBuilder toBuilder() =>
      AdvisoryStartRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryStartRequest &&
        jobType == other.jobType &&
        triggerPayload == other.triggerPayload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobType.hashCode);
    _$hash = $jc(_$hash, triggerPayload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryStartRequest')
          ..add('jobType', jobType)
          ..add('triggerPayload', triggerPayload))
        .toString();
  }
}

class AdvisoryStartRequestBuilder
    implements Builder<AdvisoryStartRequest, AdvisoryStartRequestBuilder> {
  _$AdvisoryStartRequest? _$v;

  AdvisoryJobType? _jobType;
  AdvisoryJobType? get jobType => _$this._jobType;
  set jobType(AdvisoryJobType? jobType) => _$this._jobType = jobType;

  JsonObject? _triggerPayload;
  JsonObject? get triggerPayload => _$this._triggerPayload;
  set triggerPayload(JsonObject? triggerPayload) =>
      _$this._triggerPayload = triggerPayload;

  AdvisoryStartRequestBuilder() {
    AdvisoryStartRequest._defaults(this);
  }

  AdvisoryStartRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobType = $v.jobType;
      _triggerPayload = $v.triggerPayload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryStartRequest other) {
    _$v = other as _$AdvisoryStartRequest;
  }

  @override
  void update(void Function(AdvisoryStartRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryStartRequest build() => _build();

  _$AdvisoryStartRequest _build() {
    final _$result = _$v ??
        _$AdvisoryStartRequest._(
          jobType: jobType,
          triggerPayload: triggerPayload,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
