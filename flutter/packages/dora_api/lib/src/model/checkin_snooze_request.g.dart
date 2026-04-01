// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_snooze_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckinSnoozeRequest extends CheckinSnoozeRequest {
  @override
  final String clientEventId;
  @override
  final DateTime snoozedUntil;

  factory _$CheckinSnoozeRequest(
          [void Function(CheckinSnoozeRequestBuilder)? updates]) =>
      (CheckinSnoozeRequestBuilder()..update(updates))._build();

  _$CheckinSnoozeRequest._(
      {required this.clientEventId, required this.snoozedUntil})
      : super._();
  @override
  CheckinSnoozeRequest rebuild(
          void Function(CheckinSnoozeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckinSnoozeRequestBuilder toBuilder() =>
      CheckinSnoozeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckinSnoozeRequest &&
        clientEventId == other.clientEventId &&
        snoozedUntil == other.snoozedUntil;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, snoozedUntil.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckinSnoozeRequest')
          ..add('clientEventId', clientEventId)
          ..add('snoozedUntil', snoozedUntil))
        .toString();
  }
}

class CheckinSnoozeRequestBuilder
    implements Builder<CheckinSnoozeRequest, CheckinSnoozeRequestBuilder> {
  _$CheckinSnoozeRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  DateTime? _snoozedUntil;
  DateTime? get snoozedUntil => _$this._snoozedUntil;
  set snoozedUntil(DateTime? snoozedUntil) =>
      _$this._snoozedUntil = snoozedUntil;

  CheckinSnoozeRequestBuilder() {
    CheckinSnoozeRequest._defaults(this);
  }

  CheckinSnoozeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _snoozedUntil = $v.snoozedUntil;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckinSnoozeRequest other) {
    _$v = other as _$CheckinSnoozeRequest;
  }

  @override
  void update(void Function(CheckinSnoozeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckinSnoozeRequest build() => _build();

  _$CheckinSnoozeRequest _build() {
    final _$result = _$v ??
        _$CheckinSnoozeRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'CheckinSnoozeRequest', 'clientEventId'),
          snoozedUntil: BuiltValueNullFieldError.checkNotNull(
              snoozedUntil, r'CheckinSnoozeRequest', 'snoozedUntil'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
