// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job_summary_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportJobSummaryResponse extends ExportJobSummaryResponse {
  @override
  final String jobId;
  @override
  final String tripId;
  @override
  final String? tripTitle;
  @override
  final String template;
  @override
  final ExportStatus status;
  @override
  final ExportStage? stage;
  @override
  final num progress;
  @override
  final String? outputUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String? errorCode;
  @override
  final String? errorMessage;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;

  factory _$ExportJobSummaryResponse(
          [void Function(ExportJobSummaryResponseBuilder)? updates]) =>
      (ExportJobSummaryResponseBuilder()..update(updates))._build();

  _$ExportJobSummaryResponse._(
      {required this.jobId,
      required this.tripId,
      this.tripTitle,
      required this.template,
      required this.status,
      this.stage,
      required this.progress,
      this.outputUrl,
      this.thumbnailUrl,
      this.errorCode,
      this.errorMessage,
      required this.createdAt,
      this.completedAt})
      : super._();
  @override
  ExportJobSummaryResponse rebuild(
          void Function(ExportJobSummaryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportJobSummaryResponseBuilder toBuilder() =>
      ExportJobSummaryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportJobSummaryResponse &&
        jobId == other.jobId &&
        tripId == other.tripId &&
        tripTitle == other.tripTitle &&
        template == other.template &&
        status == other.status &&
        stage == other.stage &&
        progress == other.progress &&
        outputUrl == other.outputUrl &&
        thumbnailUrl == other.thumbnailUrl &&
        errorCode == other.errorCode &&
        errorMessage == other.errorMessage &&
        createdAt == other.createdAt &&
        completedAt == other.completedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, tripTitle.hashCode);
    _$hash = $jc(_$hash, template.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, outputUrl.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jc(_$hash, errorMessage.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportJobSummaryResponse')
          ..add('jobId', jobId)
          ..add('tripId', tripId)
          ..add('tripTitle', tripTitle)
          ..add('template', template)
          ..add('status', status)
          ..add('stage', stage)
          ..add('progress', progress)
          ..add('outputUrl', outputUrl)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('errorCode', errorCode)
          ..add('errorMessage', errorMessage)
          ..add('createdAt', createdAt)
          ..add('completedAt', completedAt))
        .toString();
  }
}

class ExportJobSummaryResponseBuilder
    implements
        Builder<ExportJobSummaryResponse, ExportJobSummaryResponseBuilder> {
  _$ExportJobSummaryResponse? _$v;

  String? _jobId;
  String? get jobId => _$this._jobId;
  set jobId(String? jobId) => _$this._jobId = jobId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _tripTitle;
  String? get tripTitle => _$this._tripTitle;
  set tripTitle(String? tripTitle) => _$this._tripTitle = tripTitle;

  String? _template;
  String? get template => _$this._template;
  set template(String? template) => _$this._template = template;

  ExportStatus? _status;
  ExportStatus? get status => _$this._status;
  set status(ExportStatus? status) => _$this._status = status;

  ExportStage? _stage;
  ExportStage? get stage => _$this._stage;
  set stage(ExportStage? stage) => _$this._stage = stage;

  num? _progress;
  num? get progress => _$this._progress;
  set progress(num? progress) => _$this._progress = progress;

  String? _outputUrl;
  String? get outputUrl => _$this._outputUrl;
  set outputUrl(String? outputUrl) => _$this._outputUrl = outputUrl;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  String? _errorCode;
  String? get errorCode => _$this._errorCode;
  set errorCode(String? errorCode) => _$this._errorCode = errorCode;

  String? _errorMessage;
  String? get errorMessage => _$this._errorMessage;
  set errorMessage(String? errorMessage) => _$this._errorMessage = errorMessage;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  ExportJobSummaryResponseBuilder() {
    ExportJobSummaryResponse._defaults(this);
  }

  ExportJobSummaryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobId = $v.jobId;
      _tripId = $v.tripId;
      _tripTitle = $v.tripTitle;
      _template = $v.template;
      _status = $v.status;
      _stage = $v.stage;
      _progress = $v.progress;
      _outputUrl = $v.outputUrl;
      _thumbnailUrl = $v.thumbnailUrl;
      _errorCode = $v.errorCode;
      _errorMessage = $v.errorMessage;
      _createdAt = $v.createdAt;
      _completedAt = $v.completedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportJobSummaryResponse other) {
    _$v = other as _$ExportJobSummaryResponse;
  }

  @override
  void update(void Function(ExportJobSummaryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportJobSummaryResponse build() => _build();

  _$ExportJobSummaryResponse _build() {
    final _$result = _$v ??
        _$ExportJobSummaryResponse._(
          jobId: BuiltValueNullFieldError.checkNotNull(
              jobId, r'ExportJobSummaryResponse', 'jobId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'ExportJobSummaryResponse', 'tripId'),
          tripTitle: tripTitle,
          template: BuiltValueNullFieldError.checkNotNull(
              template, r'ExportJobSummaryResponse', 'template'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ExportJobSummaryResponse', 'status'),
          stage: stage,
          progress: BuiltValueNullFieldError.checkNotNull(
              progress, r'ExportJobSummaryResponse', 'progress'),
          outputUrl: outputUrl,
          thumbnailUrl: thumbnailUrl,
          errorCode: errorCode,
          errorMessage: errorMessage,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ExportJobSummaryResponse', 'createdAt'),
          completedAt: completedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
