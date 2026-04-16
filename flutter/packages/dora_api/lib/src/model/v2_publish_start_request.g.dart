// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_start_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2PublishStartRequest extends V2PublishStartRequest {
  @override
  final String clientJobId;
  @override
  final int schemaVersion;
  @override
  final V2PublishSummary publishSummary;
  @override
  final BuiltList<V2MediaManifestItem>? mediaManifest;
  @override
  final String mediaManifestDigest;

  factory _$V2PublishStartRequest(
          [void Function(V2PublishStartRequestBuilder)? updates]) =>
      (V2PublishStartRequestBuilder()..update(updates))._build();

  _$V2PublishStartRequest._(
      {required this.clientJobId,
      required this.schemaVersion,
      required this.publishSummary,
      this.mediaManifest,
      required this.mediaManifestDigest})
      : super._();
  @override
  V2PublishStartRequest rebuild(
          void Function(V2PublishStartRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishStartRequestBuilder toBuilder() =>
      V2PublishStartRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishStartRequest &&
        clientJobId == other.clientJobId &&
        schemaVersion == other.schemaVersion &&
        publishSummary == other.publishSummary &&
        mediaManifest == other.mediaManifest &&
        mediaManifestDigest == other.mediaManifestDigest;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientJobId.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, publishSummary.hashCode);
    _$hash = $jc(_$hash, mediaManifest.hashCode);
    _$hash = $jc(_$hash, mediaManifestDigest.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishStartRequest')
          ..add('clientJobId', clientJobId)
          ..add('schemaVersion', schemaVersion)
          ..add('publishSummary', publishSummary)
          ..add('mediaManifest', mediaManifest)
          ..add('mediaManifestDigest', mediaManifestDigest))
        .toString();
  }
}

class V2PublishStartRequestBuilder
    implements Builder<V2PublishStartRequest, V2PublishStartRequestBuilder> {
  _$V2PublishStartRequest? _$v;

  String? _clientJobId;
  String? get clientJobId => _$this._clientJobId;
  set clientJobId(String? clientJobId) => _$this._clientJobId = clientJobId;

  int? _schemaVersion;
  int? get schemaVersion => _$this._schemaVersion;
  set schemaVersion(int? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  V2PublishSummaryBuilder? _publishSummary;
  V2PublishSummaryBuilder get publishSummary =>
      _$this._publishSummary ??= V2PublishSummaryBuilder();
  set publishSummary(V2PublishSummaryBuilder? publishSummary) =>
      _$this._publishSummary = publishSummary;

  ListBuilder<V2MediaManifestItem>? _mediaManifest;
  ListBuilder<V2MediaManifestItem> get mediaManifest =>
      _$this._mediaManifest ??= ListBuilder<V2MediaManifestItem>();
  set mediaManifest(ListBuilder<V2MediaManifestItem>? mediaManifest) =>
      _$this._mediaManifest = mediaManifest;

  String? _mediaManifestDigest;
  String? get mediaManifestDigest => _$this._mediaManifestDigest;
  set mediaManifestDigest(String? mediaManifestDigest) =>
      _$this._mediaManifestDigest = mediaManifestDigest;

  V2PublishStartRequestBuilder() {
    V2PublishStartRequest._defaults(this);
  }

  V2PublishStartRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientJobId = $v.clientJobId;
      _schemaVersion = $v.schemaVersion;
      _publishSummary = $v.publishSummary.toBuilder();
      _mediaManifest = $v.mediaManifest?.toBuilder();
      _mediaManifestDigest = $v.mediaManifestDigest;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishStartRequest other) {
    _$v = other as _$V2PublishStartRequest;
  }

  @override
  void update(void Function(V2PublishStartRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishStartRequest build() => _build();

  _$V2PublishStartRequest _build() {
    _$V2PublishStartRequest _$result;
    try {
      _$result = _$v ??
          _$V2PublishStartRequest._(
            clientJobId: BuiltValueNullFieldError.checkNotNull(
                clientJobId, r'V2PublishStartRequest', 'clientJobId'),
            schemaVersion: BuiltValueNullFieldError.checkNotNull(
                schemaVersion, r'V2PublishStartRequest', 'schemaVersion'),
            publishSummary: publishSummary.build(),
            mediaManifest: _mediaManifest?.build(),
            mediaManifestDigest: BuiltValueNullFieldError.checkNotNull(
                mediaManifestDigest,
                r'V2PublishStartRequest',
                'mediaManifestDigest'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'publishSummary';
        publishSummary.build();
        _$failedField = 'mediaManifest';
        _mediaManifest?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'V2PublishStartRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
