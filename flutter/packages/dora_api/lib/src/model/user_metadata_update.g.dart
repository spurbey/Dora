// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_metadata_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserMetadataUpdate extends UserMetadataUpdate {
  @override
  final BuiltList<String>? dietaryRestrictions;
  @override
  final BuiltList<String>? dislikes;
  @override
  final BuiltList<String>? preferredTravelStyle;
  @override
  final String? budgetRange;
  @override
  final bool? notificationEnabled;

  factory _$UserMetadataUpdate(
          [void Function(UserMetadataUpdateBuilder)? updates]) =>
      (UserMetadataUpdateBuilder()..update(updates))._build();

  _$UserMetadataUpdate._(
      {this.dietaryRestrictions,
      this.dislikes,
      this.preferredTravelStyle,
      this.budgetRange,
      this.notificationEnabled})
      : super._();
  @override
  UserMetadataUpdate rebuild(
          void Function(UserMetadataUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserMetadataUpdateBuilder toBuilder() =>
      UserMetadataUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserMetadataUpdate &&
        dietaryRestrictions == other.dietaryRestrictions &&
        dislikes == other.dislikes &&
        preferredTravelStyle == other.preferredTravelStyle &&
        budgetRange == other.budgetRange &&
        notificationEnabled == other.notificationEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dietaryRestrictions.hashCode);
    _$hash = $jc(_$hash, dislikes.hashCode);
    _$hash = $jc(_$hash, preferredTravelStyle.hashCode);
    _$hash = $jc(_$hash, budgetRange.hashCode);
    _$hash = $jc(_$hash, notificationEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserMetadataUpdate')
          ..add('dietaryRestrictions', dietaryRestrictions)
          ..add('dislikes', dislikes)
          ..add('preferredTravelStyle', preferredTravelStyle)
          ..add('budgetRange', budgetRange)
          ..add('notificationEnabled', notificationEnabled))
        .toString();
  }
}

class UserMetadataUpdateBuilder
    implements Builder<UserMetadataUpdate, UserMetadataUpdateBuilder> {
  _$UserMetadataUpdate? _$v;

  ListBuilder<String>? _dietaryRestrictions;
  ListBuilder<String> get dietaryRestrictions =>
      _$this._dietaryRestrictions ??= ListBuilder<String>();
  set dietaryRestrictions(ListBuilder<String>? dietaryRestrictions) =>
      _$this._dietaryRestrictions = dietaryRestrictions;

  ListBuilder<String>? _dislikes;
  ListBuilder<String> get dislikes =>
      _$this._dislikes ??= ListBuilder<String>();
  set dislikes(ListBuilder<String>? dislikes) => _$this._dislikes = dislikes;

  ListBuilder<String>? _preferredTravelStyle;
  ListBuilder<String> get preferredTravelStyle =>
      _$this._preferredTravelStyle ??= ListBuilder<String>();
  set preferredTravelStyle(ListBuilder<String>? preferredTravelStyle) =>
      _$this._preferredTravelStyle = preferredTravelStyle;

  String? _budgetRange;
  String? get budgetRange => _$this._budgetRange;
  set budgetRange(String? budgetRange) => _$this._budgetRange = budgetRange;

  bool? _notificationEnabled;
  bool? get notificationEnabled => _$this._notificationEnabled;
  set notificationEnabled(bool? notificationEnabled) =>
      _$this._notificationEnabled = notificationEnabled;

  UserMetadataUpdateBuilder() {
    UserMetadataUpdate._defaults(this);
  }

  UserMetadataUpdateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dietaryRestrictions = $v.dietaryRestrictions?.toBuilder();
      _dislikes = $v.dislikes?.toBuilder();
      _preferredTravelStyle = $v.preferredTravelStyle?.toBuilder();
      _budgetRange = $v.budgetRange;
      _notificationEnabled = $v.notificationEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserMetadataUpdate other) {
    _$v = other as _$UserMetadataUpdate;
  }

  @override
  void update(void Function(UserMetadataUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserMetadataUpdate build() => _build();

  _$UserMetadataUpdate _build() {
    _$UserMetadataUpdate _$result;
    try {
      _$result = _$v ??
          _$UserMetadataUpdate._(
            dietaryRestrictions: _dietaryRestrictions?.build(),
            dislikes: _dislikes?.build(),
            preferredTravelStyle: _preferredTravelStyle?.build(),
            budgetRange: budgetRange,
            notificationEnabled: notificationEnabled,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dietaryRestrictions';
        _dietaryRestrictions?.build();
        _$failedField = 'dislikes';
        _dislikes?.build();
        _$failedField = 'preferredTravelStyle';
        _preferredTravelStyle?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserMetadataUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
