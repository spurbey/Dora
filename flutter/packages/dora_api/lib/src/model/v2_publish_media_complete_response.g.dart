// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_media_complete_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const V2PublishMediaCompleteResponseManifestStatusEnum
    _$v2PublishMediaCompleteResponseManifestStatusEnum_started =
    const V2PublishMediaCompleteResponseManifestStatusEnum._('started');
const V2PublishMediaCompleteResponseManifestStatusEnum
    _$v2PublishMediaCompleteResponseManifestStatusEnum_failedRetryable =
    const V2PublishMediaCompleteResponseManifestStatusEnum._('failedRetryable');
const V2PublishMediaCompleteResponseManifestStatusEnum
    _$v2PublishMediaCompleteResponseManifestStatusEnum_failedTerminal =
    const V2PublishMediaCompleteResponseManifestStatusEnum._('failedTerminal');
const V2PublishMediaCompleteResponseManifestStatusEnum
    _$v2PublishMediaCompleteResponseManifestStatusEnum_idempotencyConflict =
    const V2PublishMediaCompleteResponseManifestStatusEnum._(
        'idempotencyConflict');
const V2PublishMediaCompleteResponseManifestStatusEnum
    _$v2PublishMediaCompleteResponseManifestStatusEnum_committed =
    const V2PublishMediaCompleteResponseManifestStatusEnum._('committed');

V2PublishMediaCompleteResponseManifestStatusEnum
    _$v2PublishMediaCompleteResponseManifestStatusEnumValueOf(String name) {
  switch (name) {
    case 'started':
      return _$v2PublishMediaCompleteResponseManifestStatusEnum_started;
    case 'failedRetryable':
      return _$v2PublishMediaCompleteResponseManifestStatusEnum_failedRetryable;
    case 'failedTerminal':
      return _$v2PublishMediaCompleteResponseManifestStatusEnum_failedTerminal;
    case 'idempotencyConflict':
      return _$v2PublishMediaCompleteResponseManifestStatusEnum_idempotencyConflict;
    case 'committed':
      return _$v2PublishMediaCompleteResponseManifestStatusEnum_committed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishMediaCompleteResponseManifestStatusEnum>
    _$v2PublishMediaCompleteResponseManifestStatusEnumValues = BuiltSet<
        V2PublishMediaCompleteResponseManifestStatusEnum>(const <V2PublishMediaCompleteResponseManifestStatusEnum>[
  _$v2PublishMediaCompleteResponseManifestStatusEnum_started,
  _$v2PublishMediaCompleteResponseManifestStatusEnum_failedRetryable,
  _$v2PublishMediaCompleteResponseManifestStatusEnum_failedTerminal,
  _$v2PublishMediaCompleteResponseManifestStatusEnum_idempotencyConflict,
  _$v2PublishMediaCompleteResponseManifestStatusEnum_committed,
]);

const V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnum_startReceived =
    const V2PublishMediaCompleteResponseManifestPhaseEnum._('startReceived');
const V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnum_mediaVerified =
    const V2PublishMediaCompleteResponseManifestPhaseEnum._('mediaVerified');
const V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnum_chunksComplete =
    const V2PublishMediaCompleteResponseManifestPhaseEnum._('chunksComplete');
const V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnum_rawIngestCompleted =
    const V2PublishMediaCompleteResponseManifestPhaseEnum._(
        'rawIngestCompleted');
const V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnum_projectionCompiled =
    const V2PublishMediaCompleteResponseManifestPhaseEnum._(
        'projectionCompiled');
const V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnum_finalized =
    const V2PublishMediaCompleteResponseManifestPhaseEnum._('finalized');

V2PublishMediaCompleteResponseManifestPhaseEnum
    _$v2PublishMediaCompleteResponseManifestPhaseEnumValueOf(String name) {
  switch (name) {
    case 'startReceived':
      return _$v2PublishMediaCompleteResponseManifestPhaseEnum_startReceived;
    case 'mediaVerified':
      return _$v2PublishMediaCompleteResponseManifestPhaseEnum_mediaVerified;
    case 'chunksComplete':
      return _$v2PublishMediaCompleteResponseManifestPhaseEnum_chunksComplete;
    case 'rawIngestCompleted':
      return _$v2PublishMediaCompleteResponseManifestPhaseEnum_rawIngestCompleted;
    case 'projectionCompiled':
      return _$v2PublishMediaCompleteResponseManifestPhaseEnum_projectionCompiled;
    case 'finalized':
      return _$v2PublishMediaCompleteResponseManifestPhaseEnum_finalized;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishMediaCompleteResponseManifestPhaseEnum>
    _$v2PublishMediaCompleteResponseManifestPhaseEnumValues = BuiltSet<
        V2PublishMediaCompleteResponseManifestPhaseEnum>(const <V2PublishMediaCompleteResponseManifestPhaseEnum>[
  _$v2PublishMediaCompleteResponseManifestPhaseEnum_startReceived,
  _$v2PublishMediaCompleteResponseManifestPhaseEnum_mediaVerified,
  _$v2PublishMediaCompleteResponseManifestPhaseEnum_chunksComplete,
  _$v2PublishMediaCompleteResponseManifestPhaseEnum_rawIngestCompleted,
  _$v2PublishMediaCompleteResponseManifestPhaseEnum_projectionCompiled,
  _$v2PublishMediaCompleteResponseManifestPhaseEnum_finalized,
]);

Serializer<V2PublishMediaCompleteResponseManifestStatusEnum>
    _$v2PublishMediaCompleteResponseManifestStatusEnumSerializer =
    _$V2PublishMediaCompleteResponseManifestStatusEnumSerializer();
Serializer<V2PublishMediaCompleteResponseManifestPhaseEnum>
    _$v2PublishMediaCompleteResponseManifestPhaseEnumSerializer =
    _$V2PublishMediaCompleteResponseManifestPhaseEnumSerializer();

class _$V2PublishMediaCompleteResponseManifestStatusEnumSerializer
    implements
        PrimitiveSerializer<V2PublishMediaCompleteResponseManifestStatusEnum> {
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
    V2PublishMediaCompleteResponseManifestStatusEnum
  ];
  @override
  final String wireName = 'V2PublishMediaCompleteResponseManifestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishMediaCompleteResponseManifestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishMediaCompleteResponseManifestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishMediaCompleteResponseManifestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishMediaCompleteResponseManifestPhaseEnumSerializer
    implements
        PrimitiveSerializer<V2PublishMediaCompleteResponseManifestPhaseEnum> {
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
    V2PublishMediaCompleteResponseManifestPhaseEnum
  ];
  @override
  final String wireName = 'V2PublishMediaCompleteResponseManifestPhaseEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishMediaCompleteResponseManifestPhaseEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishMediaCompleteResponseManifestPhaseEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishMediaCompleteResponseManifestPhaseEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishMediaCompleteResponse extends V2PublishMediaCompleteResponse {
  @override
  final String publishToken;
  @override
  final V2PublishMediaCompleteResponseManifestStatusEnum manifestStatus;
  @override
  final V2PublishMediaCompleteResponseManifestPhaseEnum manifestPhase;
  @override
  final int acceptedMediaCount;

  factory _$V2PublishMediaCompleteResponse(
          [void Function(V2PublishMediaCompleteResponseBuilder)? updates]) =>
      (V2PublishMediaCompleteResponseBuilder()..update(updates))._build();

  _$V2PublishMediaCompleteResponse._(
      {required this.publishToken,
      required this.manifestStatus,
      required this.manifestPhase,
      required this.acceptedMediaCount})
      : super._();
  @override
  V2PublishMediaCompleteResponse rebuild(
          void Function(V2PublishMediaCompleteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishMediaCompleteResponseBuilder toBuilder() =>
      V2PublishMediaCompleteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishMediaCompleteResponse &&
        publishToken == other.publishToken &&
        manifestStatus == other.manifestStatus &&
        manifestPhase == other.manifestPhase &&
        acceptedMediaCount == other.acceptedMediaCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, manifestStatus.hashCode);
    _$hash = $jc(_$hash, manifestPhase.hashCode);
    _$hash = $jc(_$hash, acceptedMediaCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishMediaCompleteResponse')
          ..add('publishToken', publishToken)
          ..add('manifestStatus', manifestStatus)
          ..add('manifestPhase', manifestPhase)
          ..add('acceptedMediaCount', acceptedMediaCount))
        .toString();
  }
}

class V2PublishMediaCompleteResponseBuilder
    implements
        Builder<V2PublishMediaCompleteResponse,
            V2PublishMediaCompleteResponseBuilder> {
  _$V2PublishMediaCompleteResponse? _$v;

  String? _publishToken;
  String? get publishToken => _$this._publishToken;
  set publishToken(String? publishToken) => _$this._publishToken = publishToken;

  V2PublishMediaCompleteResponseManifestStatusEnum? _manifestStatus;
  V2PublishMediaCompleteResponseManifestStatusEnum? get manifestStatus =>
      _$this._manifestStatus;
  set manifestStatus(
          V2PublishMediaCompleteResponseManifestStatusEnum? manifestStatus) =>
      _$this._manifestStatus = manifestStatus;

  V2PublishMediaCompleteResponseManifestPhaseEnum? _manifestPhase;
  V2PublishMediaCompleteResponseManifestPhaseEnum? get manifestPhase =>
      _$this._manifestPhase;
  set manifestPhase(
          V2PublishMediaCompleteResponseManifestPhaseEnum? manifestPhase) =>
      _$this._manifestPhase = manifestPhase;

  int? _acceptedMediaCount;
  int? get acceptedMediaCount => _$this._acceptedMediaCount;
  set acceptedMediaCount(int? acceptedMediaCount) =>
      _$this._acceptedMediaCount = acceptedMediaCount;

  V2PublishMediaCompleteResponseBuilder() {
    V2PublishMediaCompleteResponse._defaults(this);
  }

  V2PublishMediaCompleteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _manifestStatus = $v.manifestStatus;
      _manifestPhase = $v.manifestPhase;
      _acceptedMediaCount = $v.acceptedMediaCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishMediaCompleteResponse other) {
    _$v = other as _$V2PublishMediaCompleteResponse;
  }

  @override
  void update(void Function(V2PublishMediaCompleteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishMediaCompleteResponse build() => _build();

  _$V2PublishMediaCompleteResponse _build() {
    final _$result = _$v ??
        _$V2PublishMediaCompleteResponse._(
          publishToken: BuiltValueNullFieldError.checkNotNull(
              publishToken, r'V2PublishMediaCompleteResponse', 'publishToken'),
          manifestStatus: BuiltValueNullFieldError.checkNotNull(manifestStatus,
              r'V2PublishMediaCompleteResponse', 'manifestStatus'),
          manifestPhase: BuiltValueNullFieldError.checkNotNull(manifestPhase,
              r'V2PublishMediaCompleteResponse', 'manifestPhase'),
          acceptedMediaCount: BuiltValueNullFieldError.checkNotNull(
              acceptedMediaCount,
              r'V2PublishMediaCompleteResponse',
              'acceptedMediaCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
