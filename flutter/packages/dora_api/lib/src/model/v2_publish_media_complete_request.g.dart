// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_media_complete_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2PublishMediaCompleteRequest extends V2PublishMediaCompleteRequest {
  @override
  final String publishToken;
  @override
  final String clientJobId;
  @override
  final int schemaVersion;
  @override
  final BuiltList<V2UploadedMediaRef>? uploadedMedia;

  factory _$V2PublishMediaCompleteRequest(
          [void Function(V2PublishMediaCompleteRequestBuilder)? updates]) =>
      (V2PublishMediaCompleteRequestBuilder()..update(updates))._build();

  _$V2PublishMediaCompleteRequest._(
      {required this.publishToken,
      required this.clientJobId,
      required this.schemaVersion,
      this.uploadedMedia})
      : super._();
  @override
  V2PublishMediaCompleteRequest rebuild(
          void Function(V2PublishMediaCompleteRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishMediaCompleteRequestBuilder toBuilder() =>
      V2PublishMediaCompleteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishMediaCompleteRequest &&
        publishToken == other.publishToken &&
        clientJobId == other.clientJobId &&
        schemaVersion == other.schemaVersion &&
        uploadedMedia == other.uploadedMedia;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, clientJobId.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, uploadedMedia.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishMediaCompleteRequest')
          ..add('publishToken', publishToken)
          ..add('clientJobId', clientJobId)
          ..add('schemaVersion', schemaVersion)
          ..add('uploadedMedia', uploadedMedia))
        .toString();
  }
}

class V2PublishMediaCompleteRequestBuilder
    implements
        Builder<V2PublishMediaCompleteRequest,
            V2PublishMediaCompleteRequestBuilder> {
  _$V2PublishMediaCompleteRequest? _$v;

  String? _publishToken;
  String? get publishToken => _$this._publishToken;
  set publishToken(String? publishToken) => _$this._publishToken = publishToken;

  String? _clientJobId;
  String? get clientJobId => _$this._clientJobId;
  set clientJobId(String? clientJobId) => _$this._clientJobId = clientJobId;

  int? _schemaVersion;
  int? get schemaVersion => _$this._schemaVersion;
  set schemaVersion(int? schemaVersion) =>
      _$this._schemaVersion = schemaVersion;

  ListBuilder<V2UploadedMediaRef>? _uploadedMedia;
  ListBuilder<V2UploadedMediaRef> get uploadedMedia =>
      _$this._uploadedMedia ??= ListBuilder<V2UploadedMediaRef>();
  set uploadedMedia(ListBuilder<V2UploadedMediaRef>? uploadedMedia) =>
      _$this._uploadedMedia = uploadedMedia;

  V2PublishMediaCompleteRequestBuilder() {
    V2PublishMediaCompleteRequest._defaults(this);
  }

  V2PublishMediaCompleteRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _clientJobId = $v.clientJobId;
      _schemaVersion = $v.schemaVersion;
      _uploadedMedia = $v.uploadedMedia?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishMediaCompleteRequest other) {
    _$v = other as _$V2PublishMediaCompleteRequest;
  }

  @override
  void update(void Function(V2PublishMediaCompleteRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishMediaCompleteRequest build() => _build();

  _$V2PublishMediaCompleteRequest _build() {
    _$V2PublishMediaCompleteRequest _$result;
    try {
      _$result = _$v ??
          _$V2PublishMediaCompleteRequest._(
            publishToken: BuiltValueNullFieldError.checkNotNull(
                publishToken, r'V2PublishMediaCompleteRequest', 'publishToken'),
            clientJobId: BuiltValueNullFieldError.checkNotNull(
                clientJobId, r'V2PublishMediaCompleteRequest', 'clientJobId'),
            schemaVersion: BuiltValueNullFieldError.checkNotNull(schemaVersion,
                r'V2PublishMediaCompleteRequest', 'schemaVersion'),
            uploadedMedia: _uploadedMedia?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'uploadedMedia';
        _uploadedMedia?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'V2PublishMediaCompleteRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
