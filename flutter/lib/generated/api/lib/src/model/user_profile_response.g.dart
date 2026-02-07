// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserProfileResponse extends UserProfileResponse {
  @override
  final AppSchemasUserUserResponse user;
  @override
  final UserStats stats;

  factory _$UserProfileResponse(
          [void Function(UserProfileResponseBuilder)? updates]) =>
      (UserProfileResponseBuilder()..update(updates))._build();

  _$UserProfileResponse._({required this.user, required this.stats})
      : super._();
  @override
  UserProfileResponse rebuild(
          void Function(UserProfileResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserProfileResponseBuilder toBuilder() =>
      UserProfileResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserProfileResponse &&
        user == other.user &&
        stats == other.stats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, stats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserProfileResponse')
          ..add('user', user)
          ..add('stats', stats))
        .toString();
  }
}

class UserProfileResponseBuilder
    implements Builder<UserProfileResponse, UserProfileResponseBuilder> {
  _$UserProfileResponse? _$v;

  AppSchemasUserUserResponseBuilder? _user;
  AppSchemasUserUserResponseBuilder get user =>
      _$this._user ??= AppSchemasUserUserResponseBuilder();
  set user(AppSchemasUserUserResponseBuilder? user) => _$this._user = user;

  UserStatsBuilder? _stats;
  UserStatsBuilder get stats => _$this._stats ??= UserStatsBuilder();
  set stats(UserStatsBuilder? stats) => _$this._stats = stats;

  UserProfileResponseBuilder() {
    UserProfileResponse._defaults(this);
  }

  UserProfileResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _user = $v.user.toBuilder();
      _stats = $v.stats.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserProfileResponse other) {
    _$v = other as _$UserProfileResponse;
  }

  @override
  void update(void Function(UserProfileResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserProfileResponse build() => _build();

  _$UserProfileResponse _build() {
    _$UserProfileResponse _$result;
    try {
      _$result = _$v ??
          _$UserProfileResponse._(
            user: user.build(),
            stats: stats.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
        _$failedField = 'stats';
        stats.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserProfileResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
