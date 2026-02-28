// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportCreateRequest extends ExportCreateRequest {
  @override
  final ExportTemplate? template;
  @override
  final ExportAspectRatio? aspectRatio;
  @override
  final int? durationSec;
  @override
  final ExportQuality? quality;
  @override
  final int? fps;

  factory _$ExportCreateRequest(
          [void Function(ExportCreateRequestBuilder)? updates]) =>
      (ExportCreateRequestBuilder()..update(updates))._build();

  _$ExportCreateRequest._(
      {this.template,
      this.aspectRatio,
      this.durationSec,
      this.quality,
      this.fps})
      : super._();
  @override
  ExportCreateRequest rebuild(
          void Function(ExportCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportCreateRequestBuilder toBuilder() =>
      ExportCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportCreateRequest &&
        template == other.template &&
        aspectRatio == other.aspectRatio &&
        durationSec == other.durationSec &&
        quality == other.quality &&
        fps == other.fps;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, template.hashCode);
    _$hash = $jc(_$hash, aspectRatio.hashCode);
    _$hash = $jc(_$hash, durationSec.hashCode);
    _$hash = $jc(_$hash, quality.hashCode);
    _$hash = $jc(_$hash, fps.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportCreateRequest')
          ..add('template', template)
          ..add('aspectRatio', aspectRatio)
          ..add('durationSec', durationSec)
          ..add('quality', quality)
          ..add('fps', fps))
        .toString();
  }
}

class ExportCreateRequestBuilder
    implements Builder<ExportCreateRequest, ExportCreateRequestBuilder> {
  _$ExportCreateRequest? _$v;

  ExportTemplate? _template;
  ExportTemplate? get template => _$this._template;
  set template(ExportTemplate? template) => _$this._template = template;

  ExportAspectRatio? _aspectRatio;
  ExportAspectRatio? get aspectRatio => _$this._aspectRatio;
  set aspectRatio(ExportAspectRatio? aspectRatio) =>
      _$this._aspectRatio = aspectRatio;

  int? _durationSec;
  int? get durationSec => _$this._durationSec;
  set durationSec(int? durationSec) => _$this._durationSec = durationSec;

  ExportQuality? _quality;
  ExportQuality? get quality => _$this._quality;
  set quality(ExportQuality? quality) => _$this._quality = quality;

  int? _fps;
  int? get fps => _$this._fps;
  set fps(int? fps) => _$this._fps = fps;

  ExportCreateRequestBuilder() {
    ExportCreateRequest._defaults(this);
  }

  ExportCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _template = $v.template;
      _aspectRatio = $v.aspectRatio;
      _durationSec = $v.durationSec;
      _quality = $v.quality;
      _fps = $v.fps;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportCreateRequest other) {
    _$v = other as _$ExportCreateRequest;
  }

  @override
  void update(void Function(ExportCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportCreateRequest build() => _build();

  _$ExportCreateRequest _build() {
    final _$result = _$v ??
        _$ExportCreateRequest._(
          template: template,
          aspectRatio: aspectRatio,
          durationSec: durationSec,
          quality: quality,
          fps: fps,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
