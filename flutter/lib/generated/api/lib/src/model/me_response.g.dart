// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MeResponse extends MeResponse {
  @override
  final AppSchemasAuthUserResponse user;
  @override
  final int? tripCount;
  @override
  final int? placeCount;

  factory _$MeResponse([void Function(MeResponseBuilder)? updates]) =>
      (MeResponseBuilder()..update(updates))._build();

  _$MeResponse._({required this.user, this.tripCount, this.placeCount})
      : super._();
  @override
  MeResponse rebuild(void Function(MeResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MeResponseBuilder toBuilder() => MeResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MeResponse &&
        user == other.user &&
        tripCount == other.tripCount &&
        placeCount == other.placeCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, tripCount.hashCode);
    _$hash = $jc(_$hash, placeCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MeResponse')
          ..add('user', user)
          ..add('tripCount', tripCount)
          ..add('placeCount', placeCount))
        .toString();
  }
}

class MeResponseBuilder implements Builder<MeResponse, MeResponseBuilder> {
  _$MeResponse? _$v;

  AppSchemasAuthUserResponseBuilder? _user;
  AppSchemasAuthUserResponseBuilder get user =>
      _$this._user ??= AppSchemasAuthUserResponseBuilder();
  set user(AppSchemasAuthUserResponseBuilder? user) => _$this._user = user;

  int? _tripCount;
  int? get tripCount => _$this._tripCount;
  set tripCount(int? tripCount) => _$this._tripCount = tripCount;

  int? _placeCount;
  int? get placeCount => _$this._placeCount;
  set placeCount(int? placeCount) => _$this._placeCount = placeCount;

  MeResponseBuilder() {
    MeResponse._defaults(this);
  }

  MeResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _tripCount = $v.tripCount;
      _placeCount = $v.placeCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MeResponse other) {
    _$v = other as _$MeResponse;
  }

  @override
  void update(void Function(MeResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MeResponse build() => _build();

  _$MeResponse _build() {
    _$MeResponse _$result;
    try {
      _$result = _$v ??
          _$MeResponse._(
            user: user.build(),
            tripCount: tripCount,
            placeCount: placeCount,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MeResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
