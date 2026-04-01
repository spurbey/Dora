// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_reject_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckinRejectRequest extends CheckinRejectRequest {
  @override
  final String clientEventId;
  @override
  final DateTime rejectedAt;
  @override
  final String? reason;

  factory _$CheckinRejectRequest(
          [void Function(CheckinRejectRequestBuilder)? updates]) =>
      (CheckinRejectRequestBuilder()..update(updates))._build();

  _$CheckinRejectRequest._(
      {required this.clientEventId, required this.rejectedAt, this.reason})
      : super._();
  @override
  CheckinRejectRequest rebuild(
          void Function(CheckinRejectRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckinRejectRequestBuilder toBuilder() =>
      CheckinRejectRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckinRejectRequest &&
        clientEventId == other.clientEventId &&
        rejectedAt == other.rejectedAt &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, rejectedAt.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckinRejectRequest')
          ..add('clientEventId', clientEventId)
          ..add('rejectedAt', rejectedAt)
          ..add('reason', reason))
        .toString();
  }
}

class CheckinRejectRequestBuilder
    implements Builder<CheckinRejectRequest, CheckinRejectRequestBuilder> {
  _$CheckinRejectRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  DateTime? _rejectedAt;
  DateTime? get rejectedAt => _$this._rejectedAt;
  set rejectedAt(DateTime? rejectedAt) => _$this._rejectedAt = rejectedAt;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  CheckinRejectRequestBuilder() {
    CheckinRejectRequest._defaults(this);
  }

  CheckinRejectRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _rejectedAt = $v.rejectedAt;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckinRejectRequest other) {
    _$v = other as _$CheckinRejectRequest;
  }

  @override
  void update(void Function(CheckinRejectRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckinRejectRequest build() => _build();

  _$CheckinRejectRequest _build() {
    final _$result = _$v ??
        _$CheckinRejectRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'CheckinRejectRequest', 'clientEventId'),
          rejectedAt: BuiltValueNullFieldError.checkNotNull(
              rejectedAt, r'CheckinRejectRequest', 'rejectedAt'),
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
