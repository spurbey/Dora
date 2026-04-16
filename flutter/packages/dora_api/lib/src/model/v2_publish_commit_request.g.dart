// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_commit_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2PublishCommitRequest extends V2PublishCommitRequest {
  @override
  final String publishToken;
  @override
  final String clientJobId;
  @override
  final int schemaVersion;

  factory _$V2PublishCommitRequest(
          [void Function(V2PublishCommitRequestBuilder)? updates]) =>
      (V2PublishCommitRequestBuilder()..update(updates))._build();

  _$V2PublishCommitRequest._(
      {required this.publishToken,
      required this.clientJobId,
      required this.schemaVersion})
      : super._();
  @override
  V2PublishCommitRequest rebuild(
          void Function(V2PublishCommitRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishCommitRequestBuilder toBuilder() =>
      V2PublishCommitRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishCommitRequest &&
        publishToken == other.publishToken &&
        clientJobId == other.clientJobId &&
        schemaVersion == other.schemaVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publishToken.hashCode);
    _$hash = $jc(_$hash, clientJobId.hashCode);
    _$hash = $jc(_$hash, schemaVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishCommitRequest')
          ..add('publishToken', publishToken)
          ..add('clientJobId', clientJobId)
          ..add('schemaVersion', schemaVersion))
        .toString();
  }
}

class V2PublishCommitRequestBuilder
    implements Builder<V2PublishCommitRequest, V2PublishCommitRequestBuilder> {
  _$V2PublishCommitRequest? _$v;

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

  V2PublishCommitRequestBuilder() {
    V2PublishCommitRequest._defaults(this);
  }

  V2PublishCommitRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publishToken = $v.publishToken;
      _clientJobId = $v.clientJobId;
      _schemaVersion = $v.schemaVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishCommitRequest other) {
    _$v = other as _$V2PublishCommitRequest;
  }

  @override
  void update(void Function(V2PublishCommitRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishCommitRequest build() => _build();

  _$V2PublishCommitRequest _build() {
    final _$result = _$v ??
        _$V2PublishCommitRequest._(
          publishToken: BuiltValueNullFieldError.checkNotNull(
              publishToken, r'V2PublishCommitRequest', 'publishToken'),
          clientJobId: BuiltValueNullFieldError.checkNotNull(
              clientJobId, r'V2PublishCommitRequest', 'clientJobId'),
          schemaVersion: BuiltValueNullFieldError.checkNotNull(
              schemaVersion, r'V2PublishCommitRequest', 'schemaVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
