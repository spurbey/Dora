// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_metadata_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripMetadataCreate extends TripMetadataCreate {
  @override
  final BuiltList<String>? travelerType;
  @override
  final String? ageGroup;
  @override
  final BuiltList<String>? travelStyle;
  @override
  final String? difficultyLevel;
  @override
  final String? budgetCategory;
  @override
  final BuiltList<String>? activityFocus;
  @override
  final bool? isDiscoverable;
  @override
  final BuiltList<String>? tags;

  factory _$TripMetadataCreate(
          [void Function(TripMetadataCreateBuilder)? updates]) =>
      (TripMetadataCreateBuilder()..update(updates))._build();

  _$TripMetadataCreate._(
      {this.travelerType,
      this.ageGroup,
      this.travelStyle,
      this.difficultyLevel,
      this.budgetCategory,
      this.activityFocus,
      this.isDiscoverable,
      this.tags})
      : super._();
  @override
  TripMetadataCreate rebuild(
          void Function(TripMetadataCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripMetadataCreateBuilder toBuilder() =>
      TripMetadataCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripMetadataCreate &&
        travelerType == other.travelerType &&
        ageGroup == other.ageGroup &&
        travelStyle == other.travelStyle &&
        difficultyLevel == other.difficultyLevel &&
        budgetCategory == other.budgetCategory &&
        activityFocus == other.activityFocus &&
        isDiscoverable == other.isDiscoverable &&
        tags == other.tags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, travelerType.hashCode);
    _$hash = $jc(_$hash, ageGroup.hashCode);
    _$hash = $jc(_$hash, travelStyle.hashCode);
    _$hash = $jc(_$hash, difficultyLevel.hashCode);
    _$hash = $jc(_$hash, budgetCategory.hashCode);
    _$hash = $jc(_$hash, activityFocus.hashCode);
    _$hash = $jc(_$hash, isDiscoverable.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripMetadataCreate')
          ..add('travelerType', travelerType)
          ..add('ageGroup', ageGroup)
          ..add('travelStyle', travelStyle)
          ..add('difficultyLevel', difficultyLevel)
          ..add('budgetCategory', budgetCategory)
          ..add('activityFocus', activityFocus)
          ..add('isDiscoverable', isDiscoverable)
          ..add('tags', tags))
        .toString();
  }
}

class TripMetadataCreateBuilder
    implements Builder<TripMetadataCreate, TripMetadataCreateBuilder> {
  _$TripMetadataCreate? _$v;

  ListBuilder<String>? _travelerType;
  ListBuilder<String> get travelerType =>
      _$this._travelerType ??= ListBuilder<String>();
  set travelerType(ListBuilder<String>? travelerType) =>
      _$this._travelerType = travelerType;

  String? _ageGroup;
  String? get ageGroup => _$this._ageGroup;
  set ageGroup(String? ageGroup) => _$this._ageGroup = ageGroup;

  ListBuilder<String>? _travelStyle;
  ListBuilder<String> get travelStyle =>
      _$this._travelStyle ??= ListBuilder<String>();
  set travelStyle(ListBuilder<String>? travelStyle) =>
      _$this._travelStyle = travelStyle;

  String? _difficultyLevel;
  String? get difficultyLevel => _$this._difficultyLevel;
  set difficultyLevel(String? difficultyLevel) =>
      _$this._difficultyLevel = difficultyLevel;

  String? _budgetCategory;
  String? get budgetCategory => _$this._budgetCategory;
  set budgetCategory(String? budgetCategory) =>
      _$this._budgetCategory = budgetCategory;

  ListBuilder<String>? _activityFocus;
  ListBuilder<String> get activityFocus =>
      _$this._activityFocus ??= ListBuilder<String>();
  set activityFocus(ListBuilder<String>? activityFocus) =>
      _$this._activityFocus = activityFocus;

  bool? _isDiscoverable;
  bool? get isDiscoverable => _$this._isDiscoverable;
  set isDiscoverable(bool? isDiscoverable) =>
      _$this._isDiscoverable = isDiscoverable;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  TripMetadataCreateBuilder() {
    TripMetadataCreate._defaults(this);
  }

  TripMetadataCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _travelerType = $v.travelerType?.toBuilder();
      _ageGroup = $v.ageGroup;
      _travelStyle = $v.travelStyle?.toBuilder();
      _difficultyLevel = $v.difficultyLevel;
      _budgetCategory = $v.budgetCategory;
      _activityFocus = $v.activityFocus?.toBuilder();
      _isDiscoverable = $v.isDiscoverable;
      _tags = $v.tags?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripMetadataCreate other) {
    _$v = other as _$TripMetadataCreate;
  }

  @override
  void update(void Function(TripMetadataCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripMetadataCreate build() => _build();

  _$TripMetadataCreate _build() {
    _$TripMetadataCreate _$result;
    try {
      _$result = _$v ??
          _$TripMetadataCreate._(
            travelerType: _travelerType?.build(),
            ageGroup: ageGroup,
            travelStyle: _travelStyle?.build(),
            difficultyLevel: difficultyLevel,
            budgetCategory: budgetCategory,
            activityFocus: _activityFocus?.build(),
            isDiscoverable: isDiscoverable,
            tags: _tags?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'travelerType';
        _travelerType?.build();

        _$failedField = 'travelStyle';
        _travelStyle?.build();

        _$failedField = 'activityFocus';
        _activityFocus?.build();

        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripMetadataCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
