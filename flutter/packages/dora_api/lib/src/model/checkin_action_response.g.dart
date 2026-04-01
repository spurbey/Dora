// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_action_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckinActionResponse extends CheckinActionResponse {
  @override
  final CheckinCandidateResponse candidate;
  @override
  final bool idempotencyReplayed;

  factory _$CheckinActionResponse(
          [void Function(CheckinActionResponseBuilder)? updates]) =>
      (CheckinActionResponseBuilder()..update(updates))._build();

  _$CheckinActionResponse._(
      {required this.candidate, required this.idempotencyReplayed})
      : super._();
  @override
  CheckinActionResponse rebuild(
          void Function(CheckinActionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckinActionResponseBuilder toBuilder() =>
      CheckinActionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckinActionResponse &&
        candidate == other.candidate &&
        idempotencyReplayed == other.idempotencyReplayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, candidate.hashCode);
    _$hash = $jc(_$hash, idempotencyReplayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckinActionResponse')
          ..add('candidate', candidate)
          ..add('idempotencyReplayed', idempotencyReplayed))
        .toString();
  }
}

class CheckinActionResponseBuilder
    implements Builder<CheckinActionResponse, CheckinActionResponseBuilder> {
  _$CheckinActionResponse? _$v;

  CheckinCandidateResponseBuilder? _candidate;
  CheckinCandidateResponseBuilder get candidate =>
      _$this._candidate ??= CheckinCandidateResponseBuilder();
  set candidate(CheckinCandidateResponseBuilder? candidate) =>
      _$this._candidate = candidate;

  bool? _idempotencyReplayed;
  bool? get idempotencyReplayed => _$this._idempotencyReplayed;
  set idempotencyReplayed(bool? idempotencyReplayed) =>
      _$this._idempotencyReplayed = idempotencyReplayed;

  CheckinActionResponseBuilder() {
    CheckinActionResponse._defaults(this);
  }

  CheckinActionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _candidate = $v.candidate.toBuilder();
      _idempotencyReplayed = $v.idempotencyReplayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckinActionResponse other) {
    _$v = other as _$CheckinActionResponse;
  }

  @override
  void update(void Function(CheckinActionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckinActionResponse build() => _build();

  _$CheckinActionResponse _build() {
    _$CheckinActionResponse _$result;
    try {
      _$result = _$v ??
          _$CheckinActionResponse._(
            candidate: candidate.build(),
            idempotencyReplayed: BuiltValueNullFieldError.checkNotNull(
                idempotencyReplayed,
                r'CheckinActionResponse',
                'idempotencyReplayed'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'candidate';
        candidate.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CheckinActionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
