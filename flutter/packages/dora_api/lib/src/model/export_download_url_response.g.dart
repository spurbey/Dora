// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_download_url_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportDownloadUrlResponse extends ExportDownloadUrlResponse {
  @override
  final String downloadUrl;
  @override
  final DateTime expiresAt;
  @override
  final int ttlSeconds;

  factory _$ExportDownloadUrlResponse(
          [void Function(ExportDownloadUrlResponseBuilder)? updates]) =>
      (ExportDownloadUrlResponseBuilder()..update(updates))._build();

  _$ExportDownloadUrlResponse._(
      {required this.downloadUrl,
      required this.expiresAt,
      required this.ttlSeconds})
      : super._();
  @override
  ExportDownloadUrlResponse rebuild(
          void Function(ExportDownloadUrlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportDownloadUrlResponseBuilder toBuilder() =>
      ExportDownloadUrlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportDownloadUrlResponse &&
        downloadUrl == other.downloadUrl &&
        expiresAt == other.expiresAt &&
        ttlSeconds == other.ttlSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, downloadUrl.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, ttlSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportDownloadUrlResponse')
          ..add('downloadUrl', downloadUrl)
          ..add('expiresAt', expiresAt)
          ..add('ttlSeconds', ttlSeconds))
        .toString();
  }
}

class ExportDownloadUrlResponseBuilder
    implements
        Builder<ExportDownloadUrlResponse, ExportDownloadUrlResponseBuilder> {
  _$ExportDownloadUrlResponse? _$v;

  String? _downloadUrl;
  String? get downloadUrl => _$this._downloadUrl;
  set downloadUrl(String? downloadUrl) => _$this._downloadUrl = downloadUrl;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  int? _ttlSeconds;
  int? get ttlSeconds => _$this._ttlSeconds;
  set ttlSeconds(int? ttlSeconds) => _$this._ttlSeconds = ttlSeconds;

  ExportDownloadUrlResponseBuilder() {
    ExportDownloadUrlResponse._defaults(this);
  }

  ExportDownloadUrlResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _downloadUrl = $v.downloadUrl;
      _expiresAt = $v.expiresAt;
      _ttlSeconds = $v.ttlSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportDownloadUrlResponse other) {
    _$v = other as _$ExportDownloadUrlResponse;
  }

  @override
  void update(void Function(ExportDownloadUrlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportDownloadUrlResponse build() => _build();

  _$ExportDownloadUrlResponse _build() {
    final _$result = _$v ??
        _$ExportDownloadUrlResponse._(
          downloadUrl: BuiltValueNullFieldError.checkNotNull(
              downloadUrl, r'ExportDownloadUrlResponse', 'downloadUrl'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'ExportDownloadUrlResponse', 'expiresAt'),
          ttlSeconds: BuiltValueNullFieldError.checkNotNull(
              ttlSeconds, r'ExportDownloadUrlResponse', 'ttlSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
