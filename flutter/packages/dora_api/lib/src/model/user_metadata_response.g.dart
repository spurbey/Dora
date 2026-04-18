// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_metadata_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserMetadataResponse extends UserMetadataResponse {
  @override
  final String userId;
  @override
  final BuiltList<String> dietaryRestrictions;
  @override
  final String? budgetRange;
  @override
  final BuiltList<String> preferredTravelStyle;
  @override
  final BuiltList<String> dislikes;
  @override
  final bool notificationEnabled;
  @override
  final JsonObject? advisoryQuietHours;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$UserMetadataResponse(
          [void Function(UserMetadataResponseBuilder)? updates]) =>
      (UserMetadataResponseBuilder()..update(updates))._build();

  _$UserMetadataResponse._(
      {required this.userId,
      required this.dietaryRestrictions,
      this.budgetRange,
      required this.preferredTravelStyle,
      required this.dislikes,
      required this.notificationEnabled,
      this.advisoryQuietHours,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  UserMetadataResponse rebuild(
          void Function(UserMetadataResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserMetadataResponseBuilder toBuilder() =>
      UserMetadataResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserMetadataResponse &&
        userId == other.userId &&
        dietaryRestrictions == other.dietaryRestrictions &&
        budgetRange == other.budgetRange &&
        preferredTravelStyle == other.preferredTravelStyle &&
        dislikes == other.dislikes &&
        notificationEnabled == other.notificationEnabled &&
        advisoryQuietHours == other.advisoryQuietHours &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, dietaryRestrictions.hashCode);
    _$hash = $jc(_$hash, budgetRange.hashCode);
    _$hash = $jc(_$hash, preferredTravelStyle.hashCode);
    _$hash = $jc(_$hash, dislikes.hashCode);
    _$hash = $jc(_$hash, notificationEnabled.hashCode);
    _$hash = $jc(_$hash, advisoryQuietHours.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserMetadataResponse')
          ..add('userId', userId)
          ..add('dietaryRestrictions', dietaryRestrictions)
          ..add('budgetRange', budgetRange)
          ..add('preferredTravelStyle', preferredTravelStyle)
          ..add('dislikes', dislikes)
          ..add('notificationEnabled', notificationEnabled)
          ..add('advisoryQuietHours', advisoryQuietHours)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class UserMetadataResponseBuilder
    implements Builder<UserMetadataResponse, UserMetadataResponseBuilder> {
  _$UserMetadataResponse? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  ListBuilder<String>? _dietaryRestrictions;
  ListBuilder<String> get dietaryRestrictions =>
      _$this._dietaryRestrictions ??= ListBuilder<String>();
  set dietaryRestrictions(ListBuilder<String>? dietaryRestrictions) =>
      _$this._dietaryRestrictions = dietaryRestrictions;

  String? _budgetRange;
  String? get budgetRange => _$this._budgetRange;
  set budgetRange(String? budgetRange) => _$this._budgetRange = budgetRange;

  ListBuilder<String>? _preferredTravelStyle;
  ListBuilder<String> get preferredTravelStyle =>
      _$this._preferredTravelStyle ??= ListBuilder<String>();
  set preferredTravelStyle(ListBuilder<String>? preferredTravelStyle) =>
      _$this._preferredTravelStyle = preferredTravelStyle;

  ListBuilder<String>? _dislikes;
  ListBuilder<String> get dislikes =>
      _$this._dislikes ??= ListBuilder<String>();
  set dislikes(ListBuilder<String>? dislikes) => _$this._dislikes = dislikes;

  bool? _notificationEnabled;
  bool? get notificationEnabled => _$this._notificationEnabled;
  set notificationEnabled(bool? notificationEnabled) =>
      _$this._notificationEnabled = notificationEnabled;

  JsonObject? _advisoryQuietHours;
  JsonObject? get advisoryQuietHours => _$this._advisoryQuietHours;
  set advisoryQuietHours(JsonObject? advisoryQuietHours) =>
      _$this._advisoryQuietHours = advisoryQuietHours;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  UserMetadataResponseBuilder() {
    UserMetadataResponse._defaults(this);
  }

  UserMetadataResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _dietaryRestrictions = $v.dietaryRestrictions.toBuilder();
      _budgetRange = $v.budgetRange;
      _preferredTravelStyle = $v.preferredTravelStyle.toBuilder();
      _dislikes = $v.dislikes.toBuilder();
      _notificationEnabled = $v.notificationEnabled;
      _advisoryQuietHours = $v.advisoryQuietHours;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserMetadataResponse other) {
    _$v = other as _$UserMetadataResponse;
  }

  @override
  void update(void Function(UserMetadataResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserMetadataResponse build() => _build();

  _$UserMetadataResponse _build() {
    _$UserMetadataResponse _$result;
    try {
      _$result = _$v ??
          _$UserMetadataResponse._(
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'UserMetadataResponse', 'userId'),
            dietaryRestrictions: dietaryRestrictions.build(),
            budgetRange: budgetRange,
            preferredTravelStyle: preferredTravelStyle.build(),
            dislikes: dislikes.build(),
            notificationEnabled: BuiltValueNullFieldError.checkNotNull(
                notificationEnabled,
                r'UserMetadataResponse',
                'notificationEnabled'),
            advisoryQuietHours: advisoryQuietHours,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'UserMetadataResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'UserMetadataResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dietaryRestrictions';
        dietaryRestrictions.build();

        _$failedField = 'preferredTravelStyle';
        preferredTravelStyle.build();
        _$failedField = 'dislikes';
        dislikes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserMetadataResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
