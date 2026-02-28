// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_share_url_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportShareUrlResponse extends ExportShareUrlResponse {
  @override
  final String shareUrl;
  @override
  final DateTime expiresAt;
  @override
  final int ttlSeconds;

  factory _$ExportShareUrlResponse(
          [void Function(ExportShareUrlResponseBuilder)? updates]) =>
      (ExportShareUrlResponseBuilder()..update(updates))._build();

  _$ExportShareUrlResponse._(
      {required this.shareUrl,
      required this.expiresAt,
      required this.ttlSeconds})
      : super._();
  @override
  ExportShareUrlResponse rebuild(
          void Function(ExportShareUrlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportShareUrlResponseBuilder toBuilder() =>
      ExportShareUrlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportShareUrlResponse &&
        shareUrl == other.shareUrl &&
        expiresAt == other.expiresAt &&
        ttlSeconds == other.ttlSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, shareUrl.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, ttlSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportShareUrlResponse')
          ..add('shareUrl', shareUrl)
          ..add('expiresAt', expiresAt)
          ..add('ttlSeconds', ttlSeconds))
        .toString();
  }
}

class ExportShareUrlResponseBuilder
    implements Builder<ExportShareUrlResponse, ExportShareUrlResponseBuilder> {
  _$ExportShareUrlResponse? _$v;

  String? _shareUrl;
  String? get shareUrl => _$this._shareUrl;
  set shareUrl(String? shareUrl) => _$this._shareUrl = shareUrl;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  int? _ttlSeconds;
  int? get ttlSeconds => _$this._ttlSeconds;
  set ttlSeconds(int? ttlSeconds) => _$this._ttlSeconds = ttlSeconds;

  ExportShareUrlResponseBuilder() {
    ExportShareUrlResponse._defaults(this);
  }

  ExportShareUrlResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _shareUrl = $v.shareUrl;
      _expiresAt = $v.expiresAt;
      _ttlSeconds = $v.ttlSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportShareUrlResponse other) {
    _$v = other as _$ExportShareUrlResponse;
  }

  @override
  void update(void Function(ExportShareUrlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportShareUrlResponse build() => _build();

  _$ExportShareUrlResponse _build() {
    final _$result = _$v ??
        _$ExportShareUrlResponse._(
          shareUrl: BuiltValueNullFieldError.checkNotNull(
              shareUrl, r'ExportShareUrlResponse', 'shareUrl'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'ExportShareUrlResponse', 'expiresAt'),
          ttlSeconds: BuiltValueNullFieldError.checkNotNull(
              ttlSeconds, r'ExportShareUrlResponse', 'ttlSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
