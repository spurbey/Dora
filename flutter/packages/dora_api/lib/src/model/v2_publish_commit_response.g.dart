// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_commit_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const V2PublishCommitResponseManifestStatusEnum
    _$v2PublishCommitResponseManifestStatusEnum_started =
    const V2PublishCommitResponseManifestStatusEnum._('started');
const V2PublishCommitResponseManifestStatusEnum
    _$v2PublishCommitResponseManifestStatusEnum_failedRetryable =
    const V2PublishCommitResponseManifestStatusEnum._('failedRetryable');
const V2PublishCommitResponseManifestStatusEnum
    _$v2PublishCommitResponseManifestStatusEnum_failedTerminal =
    const V2PublishCommitResponseManifestStatusEnum._('failedTerminal');
const V2PublishCommitResponseManifestStatusEnum
    _$v2PublishCommitResponseManifestStatusEnum_idempotencyConflict =
    const V2PublishCommitResponseManifestStatusEnum._('idempotencyConflict');
const V2PublishCommitResponseManifestStatusEnum
    _$v2PublishCommitResponseManifestStatusEnum_committed =
    const V2PublishCommitResponseManifestStatusEnum._('committed');

V2PublishCommitResponseManifestStatusEnum
    _$v2PublishCommitResponseManifestStatusEnumValueOf(String name) {
  switch (name) {
    case 'started':
      return _$v2PublishCommitResponseManifestStatusEnum_started;
    case 'failedRetryable':
      return _$v2PublishCommitResponseManifestStatusEnum_failedRetryable;
    case 'failedTerminal':
      return _$v2PublishCommitResponseManifestStatusEnum_failedTerminal;
    case 'idempotencyConflict':
      return _$v2PublishCommitResponseManifestStatusEnum_idempotencyConflict;
    case 'committed':
      return _$v2PublishCommitResponseManifestStatusEnum_committed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishCommitResponseManifestStatusEnum>
    _$v2PublishCommitResponseManifestStatusEnumValues = BuiltSet<
        V2PublishCommitResponseManifestStatusEnum>(const <V2PublishCommitResponseManifestStatusEnum>[
  _$v2PublishCommitResponseManifestStatusEnum_started,
  _$v2PublishCommitResponseManifestStatusEnum_failedRetryable,
  _$v2PublishCommitResponseManifestStatusEnum_failedTerminal,
  _$v2PublishCommitResponseManifestStatusEnum_idempotencyConflict,
  _$v2PublishCommitResponseManifestStatusEnum_committed,
]);

const V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnum_startReceived =
    const V2PublishCommitResponseManifestPhaseEnum._('startReceived');
const V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnum_mediaVerified =
    const V2PublishCommitResponseManifestPhaseEnum._('mediaVerified');
const V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnum_chunksComplete =
    const V2PublishCommitResponseManifestPhaseEnum._('chunksComplete');
const V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnum_rawIngestCompleted =
    const V2PublishCommitResponseManifestPhaseEnum._('rawIngestCompleted');
const V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnum_projectionCompiled =
    const V2PublishCommitResponseManifestPhaseEnum._('projectionCompiled');
const V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnum_finalized =
    const V2PublishCommitResponseManifestPhaseEnum._('finalized');

V2PublishCommitResponseManifestPhaseEnum
    _$v2PublishCommitResponseManifestPhaseEnumValueOf(String name) {
  switch (name) {
    case 'startReceived':
      return _$v2PublishCommitResponseManifestPhaseEnum_startReceived;
    case 'mediaVerified':
      return _$v2PublishCommitResponseManifestPhaseEnum_mediaVerified;
    case 'chunksComplete':
      return _$v2PublishCommitResponseManifestPhaseEnum_chunksComplete;
    case 'rawIngestCompleted':
      return _$v2PublishCommitResponseManifestPhaseEnum_rawIngestCompleted;
    case 'projectionCompiled':
      return _$v2PublishCommitResponseManifestPhaseEnum_projectionCompiled;
    case 'finalized':
      return _$v2PublishCommitResponseManifestPhaseEnum_finalized;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishCommitResponseManifestPhaseEnum>
    _$v2PublishCommitResponseManifestPhaseEnumValues = BuiltSet<
        V2PublishCommitResponseManifestPhaseEnum>(const <V2PublishCommitResponseManifestPhaseEnum>[
  _$v2PublishCommitResponseManifestPhaseEnum_startReceived,
  _$v2PublishCommitResponseManifestPhaseEnum_mediaVerified,
  _$v2PublishCommitResponseManifestPhaseEnum_chunksComplete,
  _$v2PublishCommitResponseManifestPhaseEnum_rawIngestCompleted,
  _$v2PublishCommitResponseManifestPhaseEnum_projectionCompiled,
  _$v2PublishCommitResponseManifestPhaseEnum_finalized,
]);

Serializer<V2PublishCommitResponseManifestStatusEnum>
    _$v2PublishCommitResponseManifestStatusEnumSerializer =
    _$V2PublishCommitResponseManifestStatusEnumSerializer();
Serializer<V2PublishCommitResponseManifestPhaseEnum>
    _$v2PublishCommitResponseManifestPhaseEnumSerializer =
    _$V2PublishCommitResponseManifestPhaseEnumSerializer();

class _$V2PublishCommitResponseManifestStatusEnumSerializer
    implements PrimitiveSerializer<V2PublishCommitResponseManifestStatusEnum> {
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
    V2PublishCommitResponseManifestStatusEnum
  ];
  @override
  final String wireName = 'V2PublishCommitResponseManifestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishCommitResponseManifestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishCommitResponseManifestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishCommitResponseManifestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishCommitResponseManifestPhaseEnumSerializer
    implements PrimitiveSerializer<V2PublishCommitResponseManifestPhaseEnum> {
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
    V2PublishCommitResponseManifestPhaseEnum
  ];
  @override
  final String wireName = 'V2PublishCommitResponseManifestPhaseEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishCommitResponseManifestPhaseEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishCommitResponseManifestPhaseEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishCommitResponseManifestPhaseEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishCommitResponse extends V2PublishCommitResponse {
  @override
  final String publishToken;
  @override
  final V2PublishCommitResponseManifestStatusEnum manifestStatus;
  @override
  final V2PublishCommitResponseManifestPhaseEnum manifestPhase;
  @override
  final int acceptedSessionCount;
  @override
  final int acceptedEventCount;
  @override
  final int acceptedMediaCount;
  @override
  final int acceptedPointCount;
  @override
  final DateTime compiledAt;

  factory _$V2PublishCommitResponse(
          [void Function(V2PublishCommitResponseBuilder)? updates]) =>
      (V2PublishCommitResponseBuilder()..update(updates))._build();

  _$V2PublishCommitResponse._(
      {required this.publishToken,
      required this.manifestStatus,
      required this.manifestPhase,
      required this.acceptedSessionCount,
      required this.acceptedEventCount,
      required this.acceptedMediaCount,
      required this.acceptedPointCount,
      required this.compiledAt})
      : super._();
  @override
  V2PublishCommitResponse rebuild(
          void Function(V2PublishCommitResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishCommitResponseBuilder toBuilder() =>
      V2PublishCommitResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishCommitResponse &&
        publishToken == other.publishToken &&
        manifestStatus == other.manifestStatus &&
        manifestPhase == other.manifestPhase &&
        acceptedSessionCount == other.acceptedSessionCount &&
        acceptedEventCount == other.acceptedEventCount &&
        acceptedMediaCount == other.acceptedMediaCount &&
        acceptedPointCount == other.acceptedPointCount &&
        compiledAt == other.compiledAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, manifestStatus.hashCode);
    _$hash = $jc(_$hash, manifestPhase.hashCode);
    _$hash = $jc(_$hash, acceptedSessionCount.hashCode);
    _$hash = $jc(_$hash, acceptedEventCount.hashCode);
    _$hash = $jc(_$hash, acceptedMediaCount.hashCode);
    _$hash = $jc(_$hash, acceptedPointCount.hashCode);
    _$hash = $jc(_$hash, compiledAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishCommitResponse')
          ..add('publishToken', publishToken)
          ..add('manifestStatus', manifestStatus)
          ..add('manifestPhase', manifestPhase)
          ..add('acceptedSessionCount', acceptedSessionCount)
          ..add('acceptedEventCount', acceptedEventCount)
          ..add('acceptedMediaCount', acceptedMediaCount)
          ..add('acceptedPointCount', acceptedPointCount)
          ..add('compiledAt', compiledAt))
        .toString();
  }
}

class V2PublishCommitResponseBuilder
    implements
        Builder<V2PublishCommitResponse, V2PublishCommitResponseBuilder> {
  _$V2PublishCommitResponse? _$v;

  String? _publishToken;
  String? get publishToken => _$this._publishToken;
  set publishToken(String? publishToken) => _$this._publishToken = publishToken;

  V2PublishCommitResponseManifestStatusEnum? _manifestStatus;
  V2PublishCommitResponseManifestStatusEnum? get manifestStatus =>
      _$this._manifestStatus;
  set manifestStatus(
          V2PublishCommitResponseManifestStatusEnum? manifestStatus) =>
      _$this._manifestStatus = manifestStatus;

  V2PublishCommitResponseManifestPhaseEnum? _manifestPhase;
  V2PublishCommitResponseManifestPhaseEnum? get manifestPhase =>
      _$this._manifestPhase;
  set manifestPhase(V2PublishCommitResponseManifestPhaseEnum? manifestPhase) =>
      _$this._manifestPhase = manifestPhase;

  int? _acceptedSessionCount;
  int? get acceptedSessionCount => _$this._acceptedSessionCount;
  set acceptedSessionCount(int? acceptedSessionCount) =>
      _$this._acceptedSessionCount = acceptedSessionCount;

  int? _acceptedEventCount;
  int? get acceptedEventCount => _$this._acceptedEventCount;
  set acceptedEventCount(int? acceptedEventCount) =>
      _$this._acceptedEventCount = acceptedEventCount;

  int? _acceptedMediaCount;
  int? get acceptedMediaCount => _$this._acceptedMediaCount;
  set acceptedMediaCount(int? acceptedMediaCount) =>
      _$this._acceptedMediaCount = acceptedMediaCount;

  int? _acceptedPointCount;
  int? get acceptedPointCount => _$this._acceptedPointCount;
  set acceptedPointCount(int? acceptedPointCount) =>
      _$this._acceptedPointCount = acceptedPointCount;

  DateTime? _compiledAt;
  DateTime? get compiledAt => _$this._compiledAt;
  set compiledAt(DateTime? compiledAt) => _$this._compiledAt = compiledAt;

  V2PublishCommitResponseBuilder() {
    V2PublishCommitResponse._defaults(this);
  }

  V2PublishCommitResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _manifestStatus = $v.manifestStatus;
      _manifestPhase = $v.manifestPhase;
      _acceptedSessionCount = $v.acceptedSessionCount;
      _acceptedEventCount = $v.acceptedEventCount;
      _acceptedMediaCount = $v.acceptedMediaCount;
      _acceptedPointCount = $v.acceptedPointCount;
      _compiledAt = $v.compiledAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishCommitResponse other) {
    _$v = other as _$V2PublishCommitResponse;
  }

  @override
  void update(void Function(V2PublishCommitResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishCommitResponse build() => _build();

  _$V2PublishCommitResponse _build() {
    final _$result = _$v ??
        _$V2PublishCommitResponse._(
          publishToken: BuiltValueNullFieldError.checkNotNull(
              publishToken, r'V2PublishCommitResponse', 'publishToken'),
          manifestStatus: BuiltValueNullFieldError.checkNotNull(
              manifestStatus, r'V2PublishCommitResponse', 'manifestStatus'),
          manifestPhase: BuiltValueNullFieldError.checkNotNull(
              manifestPhase, r'V2PublishCommitResponse', 'manifestPhase'),
          acceptedSessionCount: BuiltValueNullFieldError.checkNotNull(
              acceptedSessionCount,
              r'V2PublishCommitResponse',
              'acceptedSessionCount'),
          acceptedEventCount: BuiltValueNullFieldError.checkNotNull(
              acceptedEventCount,
              r'V2PublishCommitResponse',
              'acceptedEventCount'),
          acceptedMediaCount: BuiltValueNullFieldError.checkNotNull(
              acceptedMediaCount,
              r'V2PublishCommitResponse',
              'acceptedMediaCount'),
          acceptedPointCount: BuiltValueNullFieldError.checkNotNull(
              acceptedPointCount,
              r'V2PublishCommitResponse',
              'acceptedPointCount'),
          compiledAt: BuiltValueNullFieldError.checkNotNull(
              compiledAt, r'V2PublishCommitResponse', 'compiledAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
