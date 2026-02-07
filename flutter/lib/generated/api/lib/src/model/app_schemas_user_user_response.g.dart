// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_schemas_user_user_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppSchemasUserUserResponse extends AppSchemasUserUserResponse {
  @override
  final String id;
  @override
  final String email;
  @override
  final String username;
  @override
  final String? fullName;
  @override
  final String? avatarUrl;
  @override
  final String? bio;
  @override
  final bool isPremium;
  @override
  final bool isVerified;
  @override
  final DateTime? subscriptionEndsAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastLogin;

  factory _$AppSchemasUserUserResponse(
          [void Function(AppSchemasUserUserResponseBuilder)? updates]) =>
      (AppSchemasUserUserResponseBuilder()..update(updates))._build();

  _$AppSchemasUserUserResponse._(
      {required this.id,
      required this.email,
      required this.username,
      this.fullName,
      this.avatarUrl,
      this.bio,
      required this.isPremium,
      required this.isVerified,
      this.subscriptionEndsAt,
      required this.createdAt,
      this.lastLogin})
      : super._();
  @override
  AppSchemasUserUserResponse rebuild(
          void Function(AppSchemasUserUserResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppSchemasUserUserResponseBuilder toBuilder() =>
      AppSchemasUserUserResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppSchemasUserUserResponse &&
        id == other.id &&
        email == other.email &&
        username == other.username &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl &&
        bio == other.bio &&
        isPremium == other.isPremium &&
        isVerified == other.isVerified &&
        subscriptionEndsAt == other.subscriptionEndsAt &&
        createdAt == other.createdAt &&
        lastLogin == other.lastLogin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, isPremium.hashCode);
    _$hash = $jc(_$hash, isVerified.hashCode);
    _$hash = $jc(_$hash, subscriptionEndsAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, lastLogin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppSchemasUserUserResponse')
          ..add('id', id)
          ..add('email', email)
          ..add('username', username)
          ..add('fullName', fullName)
          ..add('avatarUrl', avatarUrl)
          ..add('bio', bio)
          ..add('isPremium', isPremium)
          ..add('isVerified', isVerified)
          ..add('subscriptionEndsAt', subscriptionEndsAt)
          ..add('createdAt', createdAt)
          ..add('lastLogin', lastLogin))
        .toString();
  }
}

class AppSchemasUserUserResponseBuilder
    implements
        Builder<AppSchemasUserUserResponse, AppSchemasUserUserResponseBuilder> {
  _$AppSchemasUserUserResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  bool? _isPremium;
  bool? get isPremium => _$this._isPremium;
  set isPremium(bool? isPremium) => _$this._isPremium = isPremium;

  bool? _isVerified;
  bool? get isVerified => _$this._isVerified;
  set isVerified(bool? isVerified) => _$this._isVerified = isVerified;

  DateTime? _subscriptionEndsAt;
  DateTime? get subscriptionEndsAt => _$this._subscriptionEndsAt;
  set subscriptionEndsAt(DateTime? subscriptionEndsAt) =>
      _$this._subscriptionEndsAt = subscriptionEndsAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _lastLogin;
  DateTime? get lastLogin => _$this._lastLogin;
  set lastLogin(DateTime? lastLogin) => _$this._lastLogin = lastLogin;

  AppSchemasUserUserResponseBuilder() {
    AppSchemasUserUserResponse._defaults(this);
  }

  AppSchemasUserUserResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _username = $v.username;
      _fullName = $v.fullName;
      _avatarUrl = $v.avatarUrl;
      _bio = $v.bio;
      _isPremium = $v.isPremium;
      _isVerified = $v.isVerified;
      _subscriptionEndsAt = $v.subscriptionEndsAt;
      _createdAt = $v.createdAt;
      _lastLogin = $v.lastLogin;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppSchemasUserUserResponse other) {
    _$v = other as _$AppSchemasUserUserResponse;
  }

  @override
  void update(void Function(AppSchemasUserUserResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppSchemasUserUserResponse build() => _build();

  _$AppSchemasUserUserResponse _build() {
    final _$result = _$v ??
        _$AppSchemasUserUserResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AppSchemasUserUserResponse', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AppSchemasUserUserResponse', 'email'),
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'AppSchemasUserUserResponse', 'username'),
          fullName: fullName,
          avatarUrl: avatarUrl,
          bio: bio,
          isPremium: BuiltValueNullFieldError.checkNotNull(
              isPremium, r'AppSchemasUserUserResponse', 'isPremium'),
          isVerified: BuiltValueNullFieldError.checkNotNull(
              isVerified, r'AppSchemasUserUserResponse', 'isVerified'),
          subscriptionEndsAt: subscriptionEndsAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AppSchemasUserUserResponse', 'createdAt'),
          lastLogin: lastLogin,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
