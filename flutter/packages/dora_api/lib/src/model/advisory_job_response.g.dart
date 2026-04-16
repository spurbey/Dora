// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_job_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryJobResponse extends AdvisoryJobResponse {
  @override
  final String jobId;
  @override
  final AdvisoryJobStatus status;
  @override
  final AdvisoryJobStage? stage;
  @override
  final num progress;
  @override
  final AdvisoryJobType jobType;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final String? errorCode;
  @override
  final String? errorMessage;

  factory _$AdvisoryJobResponse(
          [void Function(AdvisoryJobResponseBuilder)? updates]) =>
      (AdvisoryJobResponseBuilder()..update(updates))._build();

  _$AdvisoryJobResponse._(
      {required this.jobId,
      required this.status,
      this.stage,
      required this.progress,
      required this.jobType,
      required this.createdAt,
      this.startedAt,
      this.completedAt,
      this.errorCode,
      this.errorMessage})
      : super._();
  @override
  AdvisoryJobResponse rebuild(
          void Function(AdvisoryJobResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryJobResponseBuilder toBuilder() =>
      AdvisoryJobResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryJobResponse &&
        jobId == other.jobId &&
        status == other.status &&
        stage == other.stage &&
        progress == other.progress &&
        jobType == other.jobType &&
        createdAt == other.createdAt &&
        startedAt == other.startedAt &&
        completedAt == other.completedAt &&
        errorCode == other.errorCode &&
        errorMessage == other.errorMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, jobType.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jc(_$hash, errorMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryJobResponse')
          ..add('jobId', jobId)
          ..add('status', status)
          ..add('stage', stage)
          ..add('progress', progress)
          ..add('jobType', jobType)
          ..add('createdAt', createdAt)
          ..add('startedAt', startedAt)
          ..add('completedAt', completedAt)
          ..add('errorCode', errorCode)
          ..add('errorMessage', errorMessage))
        .toString();
  }
}

class AdvisoryJobResponseBuilder
    implements Builder<AdvisoryJobResponse, AdvisoryJobResponseBuilder> {
  _$AdvisoryJobResponse? _$v;

  String? _jobId;
  String? get jobId => _$this._jobId;
  set jobId(String? jobId) => _$this._jobId = jobId;

  AdvisoryJobStatus? _status;
  AdvisoryJobStatus? get status => _$this._status;
  set status(AdvisoryJobStatus? status) => _$this._status = status;

  AdvisoryJobStage? _stage;
  AdvisoryJobStage? get stage => _$this._stage;
  set stage(AdvisoryJobStage? stage) => _$this._stage = stage;

  num? _progress;
  num? get progress => _$this._progress;
  set progress(num? progress) => _$this._progress = progress;

  AdvisoryJobType? _jobType;
  AdvisoryJobType? get jobType => _$this._jobType;
  set jobType(AdvisoryJobType? jobType) => _$this._jobType = jobType;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  String? _errorCode;
  String? get errorCode => _$this._errorCode;
  set errorCode(String? errorCode) => _$this._errorCode = errorCode;

  String? _errorMessage;
  String? get errorMessage => _$this._errorMessage;
  set errorMessage(String? errorMessage) => _$this._errorMessage = errorMessage;

  AdvisoryJobResponseBuilder() {
    AdvisoryJobResponse._defaults(this);
  }

  AdvisoryJobResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobId = $v.jobId;
      _status = $v.status;
      _stage = $v.stage;
      _progress = $v.progress;
      _jobType = $v.jobType;
      _createdAt = $v.createdAt;
      _startedAt = $v.startedAt;
      _completedAt = $v.completedAt;
      _errorCode = $v.errorCode;
      _errorMessage = $v.errorMessage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryJobResponse other) {
    _$v = other as _$AdvisoryJobResponse;
  }

  @override
  void update(void Function(AdvisoryJobResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryJobResponse build() => _build();

  _$AdvisoryJobResponse _build() {
    final _$result = _$v ??
        _$AdvisoryJobResponse._(
          jobId: BuiltValueNullFieldError.checkNotNull(
              jobId, r'AdvisoryJobResponse', 'jobId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AdvisoryJobResponse', 'status'),
          stage: stage,
          progress: BuiltValueNullFieldError.checkNotNull(
              progress, r'AdvisoryJobResponse', 'progress'),
          jobType: BuiltValueNullFieldError.checkNotNull(
              jobType, r'AdvisoryJobResponse', 'jobType'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdvisoryJobResponse', 'createdAt'),
          startedAt: startedAt,
          completedAt: completedAt,
          errorCode: errorCode,
          errorMessage: errorMessage,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
