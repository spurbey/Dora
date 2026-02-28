// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_create_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportCreateResponse extends ExportCreateResponse {
  @override
  final String jobId;
  @override
  final ExportStatus status;
  @override
  final ExportStage? stage;
  @override
  final num progress;

  factory _$ExportCreateResponse(
          [void Function(ExportCreateResponseBuilder)? updates]) =>
      (ExportCreateResponseBuilder()..update(updates))._build();

  _$ExportCreateResponse._(
      {required this.jobId,
      required this.status,
      this.stage,
      required this.progress})
      : super._();
  @override
  ExportCreateResponse rebuild(
          void Function(ExportCreateResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportCreateResponseBuilder toBuilder() =>
      ExportCreateResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportCreateResponse &&
        jobId == other.jobId &&
        status == other.status &&
        stage == other.stage &&
        progress == other.progress;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, jobId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, stage.hashCode);
    _$hash = $jc(_$hash, progress.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportCreateResponse')
          ..add('jobId', jobId)
          ..add('status', status)
          ..add('stage', stage)
          ..add('progress', progress))
        .toString();
  }
}

class ExportCreateResponseBuilder
    implements Builder<ExportCreateResponse, ExportCreateResponseBuilder> {
  _$ExportCreateResponse? _$v;

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

  ExportCreateResponseBuilder() {
    ExportCreateResponse._defaults(this);
  }

  ExportCreateResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _jobId = $v.jobId;
      _status = $v.status;
      _stage = $v.stage;
      _progress = $v.progress;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportCreateResponse other) {
    _$v = other as _$ExportCreateResponse;
  }

  @override
  void update(void Function(ExportCreateResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportCreateResponse build() => _build();

  _$ExportCreateResponse _build() {
    final _$result = _$v ??
        _$ExportCreateResponse._(
          jobId: BuiltValueNullFieldError.checkNotNull(
              jobId, r'ExportCreateResponse', 'jobId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ExportCreateResponse', 'status'),
          stage: stage,
          progress: BuiltValueNullFieldError.checkNotNull(
              progress, r'ExportCreateResponse', 'progress'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
