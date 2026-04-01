// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_finalize_commit_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AutoFinalizeCommitRequest extends AutoFinalizeCommitRequest {
  @override
  final String clientEventId;
  @override
  final DateTime committedAt;

  factory _$AutoFinalizeCommitRequest(
          [void Function(AutoFinalizeCommitRequestBuilder)? updates]) =>
      (AutoFinalizeCommitRequestBuilder()..update(updates))._build();

  _$AutoFinalizeCommitRequest._(
      {required this.clientEventId, required this.committedAt})
      : super._();
  @override
  AutoFinalizeCommitRequest rebuild(
          void Function(AutoFinalizeCommitRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoFinalizeCommitRequestBuilder toBuilder() =>
      AutoFinalizeCommitRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoFinalizeCommitRequest &&
        clientEventId == other.clientEventId &&
        committedAt == other.committedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, committedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoFinalizeCommitRequest')
          ..add('clientEventId', clientEventId)
          ..add('committedAt', committedAt))
        .toString();
  }
}

class AutoFinalizeCommitRequestBuilder
    implements
        Builder<AutoFinalizeCommitRequest, AutoFinalizeCommitRequestBuilder> {
  _$AutoFinalizeCommitRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  DateTime? _committedAt;
  DateTime? get committedAt => _$this._committedAt;
  set committedAt(DateTime? committedAt) => _$this._committedAt = committedAt;

  AutoFinalizeCommitRequestBuilder() {
    AutoFinalizeCommitRequest._defaults(this);
  }

  AutoFinalizeCommitRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _committedAt = $v.committedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoFinalizeCommitRequest other) {
    _$v = other as _$AutoFinalizeCommitRequest;
  }

  @override
  void update(void Function(AutoFinalizeCommitRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoFinalizeCommitRequest build() => _build();

  _$AutoFinalizeCommitRequest _build() {
    final _$result = _$v ??
        _$AutoFinalizeCommitRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'AutoFinalizeCommitRequest', 'clientEventId'),
          committedAt: BuiltValueNullFieldError.checkNotNull(
              committedAt, r'AutoFinalizeCommitRequest', 'committedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
