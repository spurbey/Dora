// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_start_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const V2PublishStartResponseManifestStatusEnum
    _$v2PublishStartResponseManifestStatusEnum_started =
    const V2PublishStartResponseManifestStatusEnum._('started');
const V2PublishStartResponseManifestStatusEnum
    _$v2PublishStartResponseManifestStatusEnum_failedRetryable =
    const V2PublishStartResponseManifestStatusEnum._('failedRetryable');
const V2PublishStartResponseManifestStatusEnum
    _$v2PublishStartResponseManifestStatusEnum_failedTerminal =
    const V2PublishStartResponseManifestStatusEnum._('failedTerminal');
const V2PublishStartResponseManifestStatusEnum
    _$v2PublishStartResponseManifestStatusEnum_idempotencyConflict =
    const V2PublishStartResponseManifestStatusEnum._('idempotencyConflict');
const V2PublishStartResponseManifestStatusEnum
    _$v2PublishStartResponseManifestStatusEnum_committed =
    const V2PublishStartResponseManifestStatusEnum._('committed');

V2PublishStartResponseManifestStatusEnum
    _$v2PublishStartResponseManifestStatusEnumValueOf(String name) {
  switch (name) {
    case 'started':
      return _$v2PublishStartResponseManifestStatusEnum_started;
    case 'failedRetryable':
      return _$v2PublishStartResponseManifestStatusEnum_failedRetryable;
    case 'failedTerminal':
      return _$v2PublishStartResponseManifestStatusEnum_failedTerminal;
    case 'idempotencyConflict':
      return _$v2PublishStartResponseManifestStatusEnum_idempotencyConflict;
    case 'committed':
      return _$v2PublishStartResponseManifestStatusEnum_committed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishStartResponseManifestStatusEnum>
    _$v2PublishStartResponseManifestStatusEnumValues = BuiltSet<
        V2PublishStartResponseManifestStatusEnum>(const <V2PublishStartResponseManifestStatusEnum>[
  _$v2PublishStartResponseManifestStatusEnum_started,
  _$v2PublishStartResponseManifestStatusEnum_failedRetryable,
  _$v2PublishStartResponseManifestStatusEnum_failedTerminal,
  _$v2PublishStartResponseManifestStatusEnum_idempotencyConflict,
  _$v2PublishStartResponseManifestStatusEnum_committed,
]);

const V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnum_startReceived =
    const V2PublishStartResponseManifestPhaseEnum._('startReceived');
const V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnum_mediaVerified =
    const V2PublishStartResponseManifestPhaseEnum._('mediaVerified');
const V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnum_chunksComplete =
    const V2PublishStartResponseManifestPhaseEnum._('chunksComplete');
const V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnum_rawIngestCompleted =
    const V2PublishStartResponseManifestPhaseEnum._('rawIngestCompleted');
const V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnum_projectionCompiled =
    const V2PublishStartResponseManifestPhaseEnum._('projectionCompiled');
const V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnum_finalized =
    const V2PublishStartResponseManifestPhaseEnum._('finalized');

V2PublishStartResponseManifestPhaseEnum
    _$v2PublishStartResponseManifestPhaseEnumValueOf(String name) {
  switch (name) {
    case 'startReceived':
      return _$v2PublishStartResponseManifestPhaseEnum_startReceived;
    case 'mediaVerified':
      return _$v2PublishStartResponseManifestPhaseEnum_mediaVerified;
    case 'chunksComplete':
      return _$v2PublishStartResponseManifestPhaseEnum_chunksComplete;
    case 'rawIngestCompleted':
      return _$v2PublishStartResponseManifestPhaseEnum_rawIngestCompleted;
    case 'projectionCompiled':
      return _$v2PublishStartResponseManifestPhaseEnum_projectionCompiled;
    case 'finalized':
      return _$v2PublishStartResponseManifestPhaseEnum_finalized;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<V2PublishStartResponseManifestPhaseEnum>
    _$v2PublishStartResponseManifestPhaseEnumValues = BuiltSet<
        V2PublishStartResponseManifestPhaseEnum>(const <V2PublishStartResponseManifestPhaseEnum>[
  _$v2PublishStartResponseManifestPhaseEnum_startReceived,
  _$v2PublishStartResponseManifestPhaseEnum_mediaVerified,
  _$v2PublishStartResponseManifestPhaseEnum_chunksComplete,
  _$v2PublishStartResponseManifestPhaseEnum_rawIngestCompleted,
  _$v2PublishStartResponseManifestPhaseEnum_projectionCompiled,
  _$v2PublishStartResponseManifestPhaseEnum_finalized,
]);

Serializer<V2PublishStartResponseManifestStatusEnum>
    _$v2PublishStartResponseManifestStatusEnumSerializer =
    _$V2PublishStartResponseManifestStatusEnumSerializer();
Serializer<V2PublishStartResponseManifestPhaseEnum>
    _$v2PublishStartResponseManifestPhaseEnumSerializer =
    _$V2PublishStartResponseManifestPhaseEnumSerializer();

class _$V2PublishStartResponseManifestStatusEnumSerializer
    implements PrimitiveSerializer<V2PublishStartResponseManifestStatusEnum> {
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
    V2PublishStartResponseManifestStatusEnum
  ];
  @override
  final String wireName = 'V2PublishStartResponseManifestStatusEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishStartResponseManifestStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishStartResponseManifestStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishStartResponseManifestStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishStartResponseManifestPhaseEnumSerializer
    implements PrimitiveSerializer<V2PublishStartResponseManifestPhaseEnum> {
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
    V2PublishStartResponseManifestPhaseEnum
  ];
  @override
  final String wireName = 'V2PublishStartResponseManifestPhaseEnum';

  @override
  Object serialize(Serializers serializers,
          V2PublishStartResponseManifestPhaseEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  V2PublishStartResponseManifestPhaseEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      V2PublishStartResponseManifestPhaseEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$V2PublishStartResponse extends V2PublishStartResponse {
  @override
  final String publishToken;
  @override
  final V2PublishStartResponseManifestStatusEnum manifestStatus;
  @override
  final V2PublishStartResponseManifestPhaseEnum manifestPhase;
  @override
  final int acceptedMediaCount;
  @override
  final BuiltList<V2UploadTarget>? uploadTargets;

  factory _$V2PublishStartResponse(
          [void Function(V2PublishStartResponseBuilder)? updates]) =>
      (V2PublishStartResponseBuilder()..update(updates))._build();

  _$V2PublishStartResponse._(
      {required this.publishToken,
      required this.manifestStatus,
      required this.manifestPhase,
      required this.acceptedMediaCount,
      this.uploadTargets})
      : super._();
  @override
  V2PublishStartResponse rebuild(
          void Function(V2PublishStartResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishStartResponseBuilder toBuilder() =>
      V2PublishStartResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishStartResponse &&
        publishToken == other.publishToken &&
        manifestStatus == other.manifestStatus &&
        manifestPhase == other.manifestPhase &&
        acceptedMediaCount == other.acceptedMediaCount &&
        uploadTargets == other.uploadTargets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, manifestStatus.hashCode);
    _$hash = $jc(_$hash, manifestPhase.hashCode);
    _$hash = $jc(_$hash, acceptedMediaCount.hashCode);
    _$hash = $jc(_$hash, uploadTargets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishStartResponse')
          ..add('publishToken', publishToken)
          ..add('manifestStatus', manifestStatus)
          ..add('manifestPhase', manifestPhase)
          ..add('acceptedMediaCount', acceptedMediaCount)
          ..add('uploadTargets', uploadTargets))
        .toString();
  }
}

class V2PublishStartResponseBuilder
    implements Builder<V2PublishStartResponse, V2PublishStartResponseBuilder> {
  _$V2PublishStartResponse? _$v;

  String? _publishToken;
  String? get publishToken => _$this._publishToken;
  set publishToken(String? publishToken) => _$this._publishToken = publishToken;

  V2PublishStartResponseManifestStatusEnum? _manifestStatus;
  V2PublishStartResponseManifestStatusEnum? get manifestStatus =>
      _$this._manifestStatus;
  set manifestStatus(
          V2PublishStartResponseManifestStatusEnum? manifestStatus) =>
      _$this._manifestStatus = manifestStatus;

  V2PublishStartResponseManifestPhaseEnum? _manifestPhase;
  V2PublishStartResponseManifestPhaseEnum? get manifestPhase =>
      _$this._manifestPhase;
  set manifestPhase(V2PublishStartResponseManifestPhaseEnum? manifestPhase) =>
      _$this._manifestPhase = manifestPhase;

  int? _acceptedMediaCount;
  int? get acceptedMediaCount => _$this._acceptedMediaCount;
  set acceptedMediaCount(int? acceptedMediaCount) =>
      _$this._acceptedMediaCount = acceptedMediaCount;

  ListBuilder<V2UploadTarget>? _uploadTargets;
  ListBuilder<V2UploadTarget> get uploadTargets =>
      _$this._uploadTargets ??= ListBuilder<V2UploadTarget>();
  set uploadTargets(ListBuilder<V2UploadTarget>? uploadTargets) =>
      _$this._uploadTargets = uploadTargets;

  V2PublishStartResponseBuilder() {
    V2PublishStartResponse._defaults(this);
  }

  V2PublishStartResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _manifestStatus = $v.manifestStatus;
      _manifestPhase = $v.manifestPhase;
      _acceptedMediaCount = $v.acceptedMediaCount;
      _uploadTargets = $v.uploadTargets?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishStartResponse other) {
    _$v = other as _$V2PublishStartResponse;
  }

  @override
  void update(void Function(V2PublishStartResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishStartResponse build() => _build();

  _$V2PublishStartResponse _build() {
    _$V2PublishStartResponse _$result;
    try {
      _$result = _$v ??
          _$V2PublishStartResponse._(
            publishToken: BuiltValueNullFieldError.checkNotNull(
                publishToken, r'V2PublishStartResponse', 'publishToken'),
            manifestStatus: BuiltValueNullFieldError.checkNotNull(
                manifestStatus, r'V2PublishStartResponse', 'manifestStatus'),
            manifestPhase: BuiltValueNullFieldError.checkNotNull(
                manifestPhase, r'V2PublishStartResponse', 'manifestPhase'),
            acceptedMediaCount: BuiltValueNullFieldError.checkNotNull(
                acceptedMediaCount,
                r'V2PublishStartResponse',
                'acceptedMediaCount'),
            uploadTargets: _uploadTargets?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'uploadTargets';
        _uploadTargets?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'V2PublishStartResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
