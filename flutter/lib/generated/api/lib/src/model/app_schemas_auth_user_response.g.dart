// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_schemas_auth_user_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppSchemasAuthUserResponse extends AppSchemasAuthUserResponse {
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
  final DateTime createdAt;

  factory _$AppSchemasAuthUserResponse(
          [void Function(AppSchemasAuthUserResponseBuilder)? updates]) =>
      (AppSchemasAuthUserResponseBuilder()..update(updates))._build();

  _$AppSchemasAuthUserResponse._(
      {required this.id,
      required this.email,
      required this.username,
      this.fullName,
      this.avatarUrl,
      this.bio,
      required this.isPremium,
      required this.isVerified,
      required this.createdAt})
      : super._();
  @override
  AppSchemasAuthUserResponse rebuild(
          void Function(AppSchemasAuthUserResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppSchemasAuthUserResponseBuilder toBuilder() =>
      AppSchemasAuthUserResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppSchemasAuthUserResponse &&
        id == other.id &&
        email == other.email &&
        username == other.username &&
        fullName == other.fullName &&
        avatarUrl == other.avatarUrl &&
        bio == other.bio &&
        isPremium == other.isPremium &&
        isVerified == other.isVerified &&
        createdAt == other.createdAt;
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
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppSchemasAuthUserResponse')
          ..add('id', id)
          ..add('email', email)
          ..add('username', username)
          ..add('fullName', fullName)
          ..add('avatarUrl', avatarUrl)
          ..add('bio', bio)
          ..add('isPremium', isPremium)
          ..add('isVerified', isVerified)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AppSchemasAuthUserResponseBuilder
    implements
        Builder<AppSchemasAuthUserResponse, AppSchemasAuthUserResponseBuilder> {
  _$AppSchemasAuthUserResponse? _$v;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AppSchemasAuthUserResponseBuilder() {
    AppSchemasAuthUserResponse._defaults(this);
  }

  AppSchemasAuthUserResponseBuilder get _$this {
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
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppSchemasAuthUserResponse other) {
    _$v = other as _$AppSchemasAuthUserResponse;
  }

  @override
  void update(void Function(AppSchemasAuthUserResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppSchemasAuthUserResponse build() => _build();

  _$AppSchemasAuthUserResponse _build() {
    final _$result = _$v ??
        _$AppSchemasAuthUserResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AppSchemasAuthUserResponse', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AppSchemasAuthUserResponse', 'email'),
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'AppSchemasAuthUserResponse', 'username'),
          fullName: fullName,
          avatarUrl: avatarUrl,
          bio: bio,
          isPremium: BuiltValueNullFieldError.checkNotNull(
              isPremium, r'AppSchemasAuthUserResponse', 'isPremium'),
          isVerified: BuiltValueNullFieldError.checkNotNull(
              isVerified, r'AppSchemasAuthUserResponse', 'isVerified'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AppSchemasAuthUserResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
