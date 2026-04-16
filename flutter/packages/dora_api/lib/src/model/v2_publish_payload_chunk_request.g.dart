// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_payload_chunk_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2PublishPayloadChunkRequest extends V2PublishPayloadChunkRequest {
  @override
  final String publishToken;
  @override
  final String clientJobId;
  @override
  final int schemaVersion;
  @override
  final int chunkIndex;
  @override
  final int totalChunks;
  @override
  final String chunkContentHash;
  @override
  final String chunkJson;

  factory _$V2PublishPayloadChunkRequest(
          [void Function(V2PublishPayloadChunkRequestBuilder)? updates]) =>
      (V2PublishPayloadChunkRequestBuilder()..update(updates))._build();

  _$V2PublishPayloadChunkRequest._(
      {required this.publishToken,
      required this.clientJobId,
      required this.schemaVersion,
      required this.chunkIndex,
      required this.totalChunks,
      required this.chunkContentHash,
      required this.chunkJson})
      : super._();
  @override
  V2PublishPayloadChunkRequest rebuild(
          void Function(V2PublishPayloadChunkRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishPayloadChunkRequestBuilder toBuilder() =>
      V2PublishPayloadChunkRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishPayloadChunkRequest &&
        publishToken == other.publishToken &&
        clientJobId == other.clientJobId &&
        schemaVersion == other.schemaVersion &&
        chunkIndex == other.chunkIndex &&
        totalChunks == other.totalChunks &&
        chunkContentHash == other.chunkContentHash &&
        chunkJson == other.chunkJson;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, clientJobId.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jc(_$hash, chunkIndex.hashCode);
    _$hash = $jc(_$hash, totalChunks.hashCode);
    _$hash = $jc(_$hash, chunkContentHash.hashCode);
    _$hash = $jc(_$hash, chunkJson.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishPayloadChunkRequest')
          ..add('publishToken', publishToken)
          ..add('clientJobId', clientJobId)
          ..add('schemaVersion', schemaVersion)
          ..add('chunkIndex', chunkIndex)
          ..add('totalChunks', totalChunks)
          ..add('chunkContentHash', chunkContentHash)
          ..add('chunkJson', chunkJson))
        .toString();
  }
}

class V2PublishPayloadChunkRequestBuilder
    implements
        Builder<V2PublishPayloadChunkRequest,
            V2PublishPayloadChunkRequestBuilder> {
  _$V2PublishPayloadChunkRequest? _$v;

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

  int? _chunkIndex;
  int? get chunkIndex => _$this._chunkIndex;
  set chunkIndex(int? chunkIndex) => _$this._chunkIndex = chunkIndex;

  int? _totalChunks;
  int? get totalChunks => _$this._totalChunks;
  set totalChunks(int? totalChunks) => _$this._totalChunks = totalChunks;

  String? _chunkContentHash;
  String? get chunkContentHash => _$this._chunkContentHash;
  set chunkContentHash(String? chunkContentHash) =>
      _$this._chunkContentHash = chunkContentHash;

  String? _chunkJson;
  String? get chunkJson => _$this._chunkJson;
  set chunkJson(String? chunkJson) => _$this._chunkJson = chunkJson;

  V2PublishPayloadChunkRequestBuilder() {
    V2PublishPayloadChunkRequest._defaults(this);
  }

  V2PublishPayloadChunkRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _clientJobId = $v.clientJobId;
      _schemaVersion = $v.schemaVersion;
      _chunkIndex = $v.chunkIndex;
      _totalChunks = $v.totalChunks;
      _chunkContentHash = $v.chunkContentHash;
      _chunkJson = $v.chunkJson;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishPayloadChunkRequest other) {
    _$v = other as _$V2PublishPayloadChunkRequest;
  }

  @override
  void update(void Function(V2PublishPayloadChunkRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishPayloadChunkRequest build() => _build();

  _$V2PublishPayloadChunkRequest _build() {
    final _$result = _$v ??
        _$V2PublishPayloadChunkRequest._(
          publishToken: BuiltValueNullFieldError.checkNotNull(
              publishToken, r'V2PublishPayloadChunkRequest', 'publishToken'),
          clientJobId: BuiltValueNullFieldError.checkNotNull(
              clientJobId, r'V2PublishPayloadChunkRequest', 'clientJobId'),
          schemaVersion: BuiltValueNullFieldError.checkNotNull(
              schemaVersion, r'V2PublishPayloadChunkRequest', 'schemaVersion'),
          chunkIndex: BuiltValueNullFieldError.checkNotNull(
              chunkIndex, r'V2PublishPayloadChunkRequest', 'chunkIndex'),
          totalChunks: BuiltValueNullFieldError.checkNotNull(
              totalChunks, r'V2PublishPayloadChunkRequest', 'totalChunks'),
          chunkContentHash: BuiltValueNullFieldError.checkNotNull(
              chunkContentHash,
              r'V2PublishPayloadChunkRequest',
              'chunkContentHash'),
          chunkJson: BuiltValueNullFieldError.checkNotNull(
              chunkJson, r'V2PublishPayloadChunkRequest', 'chunkJson'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
