// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_status_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportStatusResponse extends ExportStatusResponse {
  @override
  final String jobId;
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
  final int? renderDurationMs;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  factory _$ExportStatusResponse(
          [void Function(ExportStatusResponseBuilder)? updates]) =>
      (ExportStatusResponseBuilder()..update(updates))._build();

  _$ExportStatusResponse._(
      {required this.jobId,
      required this.status,
      this.stage,
      required this.progress,
      this.outputUrl,
      this.thumbnailUrl,
      this.errorCode,
      this.errorMessage,
      this.renderDurationMs,
      required this.createdAt,
      this.startedAt,
      this.completedAt})
      : super._();
  @override
  ExportStatusResponse rebuild(
          void Function(ExportStatusResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportStatusResponseBuilder toBuilder() =>
      ExportStatusResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportStatusResponse &&
        jobId == other.jobId &&
        status == other.status &&
        stage == other.stage &&
        progress == other.progress &&
        outputUrl == other.outputUrl &&
        thumbnailUrl == other.thumbnailUrl &&
        errorCode == other.errorCode &&
        errorMessage == other.errorMessage &&
        renderDurationMs == other.renderDurationMs &&
        createdAt == other.createdAt &&
        startedAt == other.startedAt &&
        completedAt == other.completedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jc(_$hash, outputUrl.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, errorCode.hashCode);
    _$hash = $jc(_$hash, errorMessage.hashCode);
    _$hash = $jc(_$hash, renderDurationMs.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportStatusResponse')
          ..add('jobId', jobId)
          ..add('status', status)
          ..add('stage', stage)
          ..add('progress', progress)
          ..add('outputUrl', outputUrl)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('errorCode', errorCode)
          ..add('errorMessage', errorMessage)
          ..add('renderDurationMs', renderDurationMs)
          ..add('createdAt', createdAt)
          ..add('startedAt', startedAt)
          ..add('completedAt', completedAt))
        .toString();
  }
}

class ExportStatusResponseBuilder
    implements Builder<ExportStatusResponse, ExportStatusResponseBuilder> {
  _$ExportStatusResponse? _$v;

  String? _jobId;
  String? get jobId => _$this._jobId;
  set jobId(String? jobId) => _$this._jobId = jobId;

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

  int? _renderDurationMs;
  int? get renderDurationMs => _$this._renderDurationMs;
  set renderDurationMs(int? renderDurationMs) =>
      _$this._renderDurationMs = renderDurationMs;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _completedAt;
  DateTime? get completedAt => _$this._completedAt;
  set completedAt(DateTime? completedAt) => _$this._completedAt = completedAt;

  ExportStatusResponseBuilder() {
    ExportStatusResponse._defaults(this);
  }

  ExportStatusResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobId = $v.jobId;
      _status = $v.status;
      _stage = $v.stage;
      _progress = $v.progress;
      _outputUrl = $v.outputUrl;
      _thumbnailUrl = $v.thumbnailUrl;
      _errorCode = $v.errorCode;
      _errorMessage = $v.errorMessage;
      _renderDurationMs = $v.renderDurationMs;
      _createdAt = $v.createdAt;
      _startedAt = $v.startedAt;
      _completedAt = $v.completedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportStatusResponse other) {
    _$v = other as _$ExportStatusResponse;
  }

  @override
  void update(void Function(ExportStatusResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportStatusResponse build() => _build();

  _$ExportStatusResponse _build() {
    final _$result = _$v ??
        _$ExportStatusResponse._(
          jobId: BuiltValueNullFieldError.checkNotNull(
              jobId, r'ExportStatusResponse', 'jobId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ExportStatusResponse', 'status'),
          stage: stage,
          progress: BuiltValueNullFieldError.checkNotNull(
              progress, r'ExportStatusResponse', 'progress'),
          outputUrl: outputUrl,
          thumbnailUrl: thumbnailUrl,
          errorCode: errorCode,
          errorMessage: errorMessage,
          renderDurationMs: renderDurationMs,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ExportStatusResponse', 'createdAt'),
          startedAt: startedAt,
          completedAt: completedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
