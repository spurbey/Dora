// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_confirm_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckinConfirmRequest extends CheckinConfirmRequest {
  @override
  final String clientEventId;
  @override
  final DateTime confirmedAt;
  @override
  final CheckinPlaceOverride? placeOverride;

  factory _$CheckinConfirmRequest(
          [void Function(CheckinConfirmRequestBuilder)? updates]) =>
      (CheckinConfirmRequestBuilder()..update(updates))._build();

  _$CheckinConfirmRequest._(
      {required this.clientEventId,
      required this.confirmedAt,
      this.placeOverride})
      : super._();
  @override
  CheckinConfirmRequest rebuild(
          void Function(CheckinConfirmRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckinConfirmRequestBuilder toBuilder() =>
      CheckinConfirmRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckinConfirmRequest &&
        clientEventId == other.clientEventId &&
        confirmedAt == other.confirmedAt &&
        placeOverride == other.placeOverride;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, confirmedAt.hashCode);
    _$hash = $jc(_$hash, placeOverride.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckinConfirmRequest')
          ..add('clientEventId', clientEventId)
          ..add('confirmedAt', confirmedAt)
          ..add('placeOverride', placeOverride))
        .toString();
  }
}

class CheckinConfirmRequestBuilder
    implements Builder<CheckinConfirmRequest, CheckinConfirmRequestBuilder> {
  _$CheckinConfirmRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  DateTime? _confirmedAt;
  DateTime? get confirmedAt => _$this._confirmedAt;
  set confirmedAt(DateTime? confirmedAt) => _$this._confirmedAt = confirmedAt;

  CheckinPlaceOverrideBuilder? _placeOverride;
  CheckinPlaceOverrideBuilder get placeOverride =>
      _$this._placeOverride ??= CheckinPlaceOverrideBuilder();
  set placeOverride(CheckinPlaceOverrideBuilder? placeOverride) =>
      _$this._placeOverride = placeOverride;

  CheckinConfirmRequestBuilder() {
    CheckinConfirmRequest._defaults(this);
  }

  CheckinConfirmRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _confirmedAt = $v.confirmedAt;
      _placeOverride = $v.placeOverride?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckinConfirmRequest other) {
    _$v = other as _$CheckinConfirmRequest;
  }

  @override
  void update(void Function(CheckinConfirmRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckinConfirmRequest build() => _build();

  _$CheckinConfirmRequest _build() {
    _$CheckinConfirmRequest _$result;
    try {
      _$result = _$v ??
          _$CheckinConfirmRequest._(
            clientEventId: BuiltValueNullFieldError.checkNotNull(
                clientEventId, r'CheckinConfirmRequest', 'clientEventId'),
            confirmedAt: BuiltValueNullFieldError.checkNotNull(
                confirmedAt, r'CheckinConfirmRequest', 'confirmedAt'),
            placeOverride: _placeOverride?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'placeOverride';
        _placeOverride?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CheckinConfirmRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
