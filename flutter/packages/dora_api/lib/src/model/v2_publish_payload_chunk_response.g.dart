// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_payload_chunk_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const V2PublishPayloadChunkResponseManifestStatusEnum
    _$v2PublishPayloadChunkResponseManifestStatusEnum_started =
    const V2PublishPayloadChunkResponseManifestStatusEnum._('started');
const V2PublishPayloadChunkResponseManifestStatusEnum
    _$v2PublishPayloadChunkResponseManifestStatusEnum_failedRetryable =
    const V2PublishPayloadChunkResponseManifestStatusEnum._('failedRetryable');
const V2PublishPayloadChunkResponseManifestStatusEnum
    _$v2PublishPayloadChunkResponseManifestStatusEnum_failedTerminal =
    const V2PublishPayloadChunkResponseManifestStatusEnum._('failedTerminal');
const V2PublishPayloadChunkResponseManifestStatusEnum
    _$v2PublishPayloadChunkResponseManifestStatusEnum_idempotencyConflict =
    const V2PublishPayloadChunkResponseManifestStatusEnum._(
        'idempotencyConflict');
const V2PublishPayloadChunkResponseManifestStatusEnum
    _$v2PublishPayloadChunkResponseManifestStatusEnum_committed =
    const V2PublishPayloadChunkResponseManifestStatusEnum._('committed');

V2PublishPayloadChunkResponseManifestStatusEnum
    _$v2PublishPayloadChunkResponseManifestStatusEnumValueOf(String name) {
  switch (name) {
    case 'started':
      return _$v2PublishPayloadChunkResponseManifestStatusEnum_started;
    case 'failedRetryable':
      return _$v2PublishPayloadChunkResponseManifestStatusEnum_failedRetryable;
    case 'failedTerminal':
      return _$v2PublishPayloadChunkResponseManifestStatusEnum_failedTerminal;
    case 'idempotencyConflict':
      return _$v2PublishPayloadChunkResponseManifestStatusEnum_idempotencyConflict;
    case 'committed':
      return _$v2PublishPayloadChunkResponseManifestStatusEnum_committed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishPayloadChunkResponseManifestStatusEnum>
    _$v2PublishPayloadChunkResponseManifestStatusEnumValues = BuiltSet<
        V2PublishPayloadChunkResponseManifestStatusEnum>(const <V2PublishPayloadChunkResponseManifestStatusEnum>[
  _$v2PublishPayloadChunkResponseManifestStatusEnum_started,
  _$v2PublishPayloadChunkResponseManifestStatusEnum_failedRetryable,
  _$v2PublishPayloadChunkResponseManifestStatusEnum_failedTerminal,
  _$v2PublishPayloadChunkResponseManifestStatusEnum_idempotencyConflict,
  _$v2PublishPayloadChunkResponseManifestStatusEnum_committed,
]);

const V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnum_startReceived =
    const V2PublishPayloadChunkResponseManifestPhaseEnum._('startReceived');
const V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnum_mediaVerified =
    const V2PublishPayloadChunkResponseManifestPhaseEnum._('mediaVerified');
const V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnum_chunksComplete =
    const V2PublishPayloadChunkResponseManifestPhaseEnum._('chunksComplete');
const V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnum_rawIngestCompleted =
    const V2PublishPayloadChunkResponseManifestPhaseEnum._(
        'rawIngestCompleted');
const V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnum_projectionCompiled =
    const V2PublishPayloadChunkResponseManifestPhaseEnum._(
        'projectionCompiled');
const V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnum_finalized =
    const V2PublishPayloadChunkResponseManifestPhaseEnum._('finalized');

V2PublishPayloadChunkResponseManifestPhaseEnum
    _$v2PublishPayloadChunkResponseManifestPhaseEnumValueOf(String name) {
  switch (name) {
    case 'startReceived':
      return _$v2PublishPayloadChunkResponseManifestPhaseEnum_startReceived;
    case 'mediaVerified':
      return _$v2PublishPayloadChunkResponseManifestPhaseEnum_mediaVerified;
    case 'chunksComplete':
      return _$v2PublishPayloadChunkResponseManifestPhaseEnum_chunksComplete;
    case 'rawIngestCompleted':
      return _$v2PublishPayloadChunkResponseManifestPhaseEnum_rawIngestCompleted;
    case 'projectionCompiled':
      return _$v2PublishPayloadChunkResponseManifestPhaseEnum_projectionCompiled;
    case 'finalized':
      return _$v2PublishPayloadChunkResponseManifestPhaseEnum_finalized;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishPayloadChunkResponseManifestPhaseEnum>
    _$v2PublishPayloadChunkResponseManifestPhaseEnumValues = BuiltSet<
        V2PublishPayloadChunkResponseManifestPhaseEnum>(const <V2PublishPayloadChunkResponseManifestPhaseEnum>[
  _$v2PublishPayloadChunkResponseManifestPhaseEnum_startReceived,
  _$v2PublishPayloadChunkResponseManifestPhaseEnum_mediaVerified,
  _$v2PublishPayloadChunkResponseManifestPhaseEnum_chunksComplete,
  _$v2PublishPayloadChunkResponseManifestPhaseEnum_rawIngestCompleted,
  _$v2PublishPayloadChunkResponseManifestPhaseEnum_projectionCompiled,
  _$v2PublishPayloadChunkResponseManifestPhaseEnum_finalized,
]);

Serializer<V2PublishPayloadChunkResponseManifestStatusEnum>
    _$v2PublishPayloadChunkResponseManifestStatusEnumSerializer =
    _$V2PublishPayloadChunkResponseManifestStatusEnumSerializer();
Serializer<V2PublishPayloadChunkResponseManifestPhaseEnum>
    _$v2PublishPayloadChunkResponseManifestPhaseEnumSerializer =
    _$V2PublishPayloadChunkResponseManifestPhaseEnumSerializer();

class _$V2PublishPayloadChunkResponseManifestStatusEnumSerializer
    implements
        PrimitiveSerializer<V2PublishPayloadChunkResponseManifestStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'started': 'started',
    'failedRetryable': 'failed_retryable',
    'failedTerminal': 'failed_terminal',
    'idempotencyConflict': 'idempotency_conflict',
    'committed': 'committed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'started': 'started',
    'failed_retryable': 'failedRetryable',
    'failed_terminal': 'failedTerminal',
    'idempotency_conflict': 'idempotencyConflict',
    'committed': 'committed',
  };

  @override
  final Iterable<Type> types = const <Type>[
    V2PublishPayloadChunkResponseManifestStatusEnum
  ];
  @override
  final String wireName = 'V2PublishPayloadChunkResponseManifestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishPayloadChunkResponseManifestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishPayloadChunkResponseManifestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishPayloadChunkResponseManifestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishPayloadChunkResponseManifestPhaseEnumSerializer
    implements
        PrimitiveSerializer<V2PublishPayloadChunkResponseManifestPhaseEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'startReceived': 'start_received',
    'mediaVerified': 'media_verified',
    'chunksComplete': 'chunks_complete',
    'rawIngestCompleted': 'raw_ingest_completed',
    'projectionCompiled': 'projection_compiled',
    'finalized': 'finalized',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'start_received': 'startReceived',
    'media_verified': 'mediaVerified',
    'chunks_complete': 'chunksComplete',
    'raw_ingest_completed': 'rawIngestCompleted',
    'projection_compiled': 'projectionCompiled',
    'finalized': 'finalized',
  };

  @override
  final Iterable<Type> types = const <Type>[
    V2PublishPayloadChunkResponseManifestPhaseEnum
  ];
  @override
  final String wireName = 'V2PublishPayloadChunkResponseManifestPhaseEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishPayloadChunkResponseManifestPhaseEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishPayloadChunkResponseManifestPhaseEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishPayloadChunkResponseManifestPhaseEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishPayloadChunkResponse extends V2PublishPayloadChunkResponse {
  @override
  final String publishToken;
  @override
  final V2PublishPayloadChunkResponseManifestStatusEnum manifestStatus;
  @override
  final V2PublishPayloadChunkResponseManifestPhaseEnum manifestPhase;
  @override
  final int chunkIndex;
  @override
  final int totalChunks;
  @override
  final int acceptedTotalBytes;

  factory _$V2PublishPayloadChunkResponse(
          [void Function(V2PublishPayloadChunkResponseBuilder)? updates]) =>
      (V2PublishPayloadChunkResponseBuilder()..update(updates))._build();

  _$V2PublishPayloadChunkResponse._(
      {required this.publishToken,
      required this.manifestStatus,
      required this.manifestPhase,
      required this.chunkIndex,
      required this.totalChunks,
      required this.acceptedTotalBytes})
      : super._();
  @override
  V2PublishPayloadChunkResponse rebuild(
          void Function(V2PublishPayloadChunkResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishPayloadChunkResponseBuilder toBuilder() =>
      V2PublishPayloadChunkResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishPayloadChunkResponse &&
        publishToken == other.publishToken &&
        manifestStatus == other.manifestStatus &&
        manifestPhase == other.manifestPhase &&
        chunkIndex == other.chunkIndex &&
        totalChunks == other.totalChunks &&
        acceptedTotalBytes == other.acceptedTotalBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, manifestStatus.hashCode);
    _$hash = $jc(_$hash, manifestPhase.hashCode);
    _$hash = $jc(_$hash, chunkIndex.hashCode);
    _$hash = $jc(_$hash, totalChunks.hashCode);
    _$hash = $jc(_$hash, acceptedTotalBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishPayloadChunkResponse')
          ..add('publishToken', publishToken)
          ..add('manifestStatus', manifestStatus)
          ..add('manifestPhase', manifestPhase)
          ..add('chunkIndex', chunkIndex)
          ..add('totalChunks', totalChunks)
          ..add('acceptedTotalBytes', acceptedTotalBytes))
        .toString();
  }
}

class V2PublishPayloadChunkResponseBuilder
    implements
        Builder<V2PublishPayloadChunkResponse,
            V2PublishPayloadChunkResponseBuilder> {
  _$V2PublishPayloadChunkResponse? _$v;

  String? _publishToken;
  String? get publishToken => _$this._publishToken;
  set publishToken(String? publishToken) => _$this._publishToken = publishToken;

  V2PublishPayloadChunkResponseManifestStatusEnum? _manifestStatus;
  V2PublishPayloadChunkResponseManifestStatusEnum? get manifestStatus =>
      _$this._manifestStatus;
  set manifestStatus(
          V2PublishPayloadChunkResponseManifestStatusEnum? manifestStatus) =>
      _$this._manifestStatus = manifestStatus;

  V2PublishPayloadChunkResponseManifestPhaseEnum? _manifestPhase;
  V2PublishPayloadChunkResponseManifestPhaseEnum? get manifestPhase =>
      _$this._manifestPhase;
  set manifestPhase(
          V2PublishPayloadChunkResponseManifestPhaseEnum? manifestPhase) =>
      _$this._manifestPhase = manifestPhase;

  int? _chunkIndex;
  int? get chunkIndex => _$this._chunkIndex;
  set chunkIndex(int? chunkIndex) => _$this._chunkIndex = chunkIndex;

  int? _totalChunks;
  int? get totalChunks => _$this._totalChunks;
  set totalChunks(int? totalChunks) => _$this._totalChunks = totalChunks;

  int? _acceptedTotalBytes;
  int? get acceptedTotalBytes => _$this._acceptedTotalBytes;
  set acceptedTotalBytes(int? acceptedTotalBytes) =>
      _$this._acceptedTotalBytes = acceptedTotalBytes;

  V2PublishPayloadChunkResponseBuilder() {
    V2PublishPayloadChunkResponse._defaults(this);
  }

  V2PublishPayloadChunkResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _manifestStatus = $v.manifestStatus;
      _manifestPhase = $v.manifestPhase;
      _chunkIndex = $v.chunkIndex;
      _totalChunks = $v.totalChunks;
      _acceptedTotalBytes = $v.acceptedTotalBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishPayloadChunkResponse other) {
    _$v = other as _$V2PublishPayloadChunkResponse;
  }

  @override
  void update(void Function(V2PublishPayloadChunkResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishPayloadChunkResponse build() => _build();

  _$V2PublishPayloadChunkResponse _build() {
    final _$result = _$v ??
        _$V2PublishPayloadChunkResponse._(
          publishToken: BuiltValueNullFieldError.checkNotNull(
              publishToken, r'V2PublishPayloadChunkResponse', 'publishToken'),
          manifestStatus: BuiltValueNullFieldError.checkNotNull(manifestStatus,
              r'V2PublishPayloadChunkResponse', 'manifestStatus'),
          manifestPhase: BuiltValueNullFieldError.checkNotNull(
              manifestPhase, r'V2PublishPayloadChunkResponse', 'manifestPhase'),
          chunkIndex: BuiltValueNullFieldError.checkNotNull(
              chunkIndex, r'V2PublishPayloadChunkResponse', 'chunkIndex'),
          totalChunks: BuiltValueNullFieldError.checkNotNull(
              totalChunks, r'V2PublishPayloadChunkResponse', 'totalChunks'),
          acceptedTotalBytes: BuiltValueNullFieldError.checkNotNull(
              acceptedTotalBytes,
              r'V2PublishPayloadChunkResponse',
              'acceptedTotalBytes'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
