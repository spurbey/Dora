// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_checkins_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PendingCheckinsResponse extends PendingCheckinsResponse {
  @override
  final BuiltList<CheckinCandidateResponse> candidates;
  @override
  final int total;

  factory _$PendingCheckinsResponse(
          [void Function(PendingCheckinsResponseBuilder)? updates]) =>
      (PendingCheckinsResponseBuilder()..update(updates))._build();

  _$PendingCheckinsResponse._({required this.candidates, required this.total})
      : super._();
  @override
  PendingCheckinsResponse rebuild(
          void Function(PendingCheckinsResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PendingCheckinsResponseBuilder toBuilder() =>
      PendingCheckinsResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PendingCheckinsResponse &&
        candidates == other.candidates &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, candidates.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PendingCheckinsResponse')
          ..add('candidates', candidates)
          ..add('total', total))
        .toString();
  }
}

class PendingCheckinsResponseBuilder
    implements
        Builder<PendingCheckinsResponse, PendingCheckinsResponseBuilder> {
  _$PendingCheckinsResponse? _$v;

  ListBuilder<CheckinCandidateResponse>? _candidates;
  ListBuilder<CheckinCandidateResponse> get candidates =>
      _$this._candidates ??= ListBuilder<CheckinCandidateResponse>();
  set candidates(ListBuilder<CheckinCandidateResponse>? candidates) =>
      _$this._candidates = candidates;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  PendingCheckinsResponseBuilder() {
    PendingCheckinsResponse._defaults(this);
  }

  PendingCheckinsResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _candidates = $v.candidates.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PendingCheckinsResponse other) {
    _$v = other as _$PendingCheckinsResponse;
  }

  @override
  void update(void Function(PendingCheckinsResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PendingCheckinsResponse build() => _build();

  _$PendingCheckinsResponse _build() {
    _$PendingCheckinsResponse _$result;
    try {
      _$result = _$v ??
          _$PendingCheckinsResponse._(
            candidates: candidates.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'PendingCheckinsResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'candidates';
        candidates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PendingCheckinsResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
