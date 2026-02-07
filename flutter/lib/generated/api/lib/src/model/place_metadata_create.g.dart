// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_metadata_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlaceMetadataCreate extends PlaceMetadataCreate {
  @override
  final String? componentType;
  @override
  final BuiltList<String>? experienceTags;
  @override
  final BuiltList<String>? bestFor;
  @override
  final BudgetPerPerson? budgetPerPerson;
  @override
  final num? durationHours;
  @override
  final int? difficultyRating;
  @override
  final String? physicalDemand;
  @override
  final String? bestTime;
  @override
  final bool? isPublic;

  factory _$PlaceMetadataCreate(
          [void Function(PlaceMetadataCreateBuilder)? updates]) =>
      (PlaceMetadataCreateBuilder()..update(updates))._build();

  _$PlaceMetadataCreate._(
      {this.componentType,
      this.experienceTags,
      this.bestFor,
      this.budgetPerPerson,
      this.durationHours,
      this.difficultyRating,
      this.physicalDemand,
      this.bestTime,
      this.isPublic})
      : super._();
  @override
  PlaceMetadataCreate rebuild(
          void Function(PlaceMetadataCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlaceMetadataCreateBuilder toBuilder() =>
      PlaceMetadataCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlaceMetadataCreate &&
        componentType == other.componentType &&
        experienceTags == other.experienceTags &&
        bestFor == other.bestFor &&
        budgetPerPerson == other.budgetPerPerson &&
        durationHours == other.durationHours &&
        difficultyRating == other.difficultyRating &&
        physicalDemand == other.physicalDemand &&
        bestTime == other.bestTime &&
        isPublic == other.isPublic;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, componentType.hashCode);
    _$hash = $jc(_$hash, experienceTags.hashCode);
    _$hash = $jc(_$hash, bestFor.hashCode);
    _$hash = $jc(_$hash, budgetPerPerson.hashCode);
    _$hash = $jc(_$hash, durationHours.hashCode);
    _$hash = $jc(_$hash, difficultyRating.hashCode);
    _$hash = $jc(_$hash, physicalDemand.hashCode);
    _$hash = $jc(_$hash, bestTime.hashCode);
    _$hash = $jc(_$hash, isPublic.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlaceMetadataCreate')
          ..add('componentType', componentType)
          ..add('experienceTags', experienceTags)
          ..add('bestFor', bestFor)
          ..add('budgetPerPerson', budgetPerPerson)
          ..add('durationHours', durationHours)
          ..add('difficultyRating', difficultyRating)
          ..add('physicalDemand', physicalDemand)
          ..add('bestTime', bestTime)
          ..add('isPublic', isPublic))
        .toString();
  }
}

class PlaceMetadataCreateBuilder
    implements Builder<PlaceMetadataCreate, PlaceMetadataCreateBuilder> {
  _$PlaceMetadataCreate? _$v;

  String? _componentType;
  String? get componentType => _$this._componentType;
  set componentType(String? componentType) =>
      _$this._componentType = componentType;

  ListBuilder<String>? _experienceTags;
  ListBuilder<String> get experienceTags =>
      _$this._experienceTags ??= ListBuilder<String>();
  set experienceTags(ListBuilder<String>? experienceTags) =>
      _$this._experienceTags = experienceTags;

  ListBuilder<String>? _bestFor;
  ListBuilder<String> get bestFor => _$this._bestFor ??= ListBuilder<String>();
  set bestFor(ListBuilder<String>? bestFor) => _$this._bestFor = bestFor;

  BudgetPerPersonBuilder? _budgetPerPerson;
  BudgetPerPersonBuilder get budgetPerPerson =>
      _$this._budgetPerPerson ??= BudgetPerPersonBuilder();
  set budgetPerPerson(BudgetPerPersonBuilder? budgetPerPerson) =>
      _$this._budgetPerPerson = budgetPerPerson;

  num? _durationHours;
  num? get durationHours => _$this._durationHours;
  set durationHours(num? durationHours) =>
      _$this._durationHours = durationHours;

  int? _difficultyRating;
  int? get difficultyRating => _$this._difficultyRating;
  set difficultyRating(int? difficultyRating) =>
      _$this._difficultyRating = difficultyRating;

  String? _physicalDemand;
  String? get physicalDemand => _$this._physicalDemand;
  set physicalDemand(String? physicalDemand) =>
      _$this._physicalDemand = physicalDemand;

  String? _bestTime;
  String? get bestTime => _$this._bestTime;
  set bestTime(String? bestTime) => _$this._bestTime = bestTime;

  bool? _isPublic;
  bool? get isPublic => _$this._isPublic;
  set isPublic(bool? isPublic) => _$this._isPublic = isPublic;

  PlaceMetadataCreateBuilder() {
    PlaceMetadataCreate._defaults(this);
  }

  PlaceMetadataCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _componentType = $v.componentType;
      _experienceTags = $v.experienceTags?.toBuilder();
      _bestFor = $v.bestFor?.toBuilder();
      _budgetPerPerson = $v.budgetPerPerson?.toBuilder();
      _durationHours = $v.durationHours;
      _difficultyRating = $v.difficultyRating;
      _physicalDemand = $v.physicalDemand;
      _bestTime = $v.bestTime;
      _isPublic = $v.isPublic;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlaceMetadataCreate other) {
    _$v = other as _$PlaceMetadataCreate;
  }

  @override
  void update(void Function(PlaceMetadataCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlaceMetadataCreate build() => _build();

  _$PlaceMetadataCreate _build() {
    _$PlaceMetadataCreate _$result;
    try {
      _$result = _$v ??
          _$PlaceMetadataCreate._(
            componentType: componentType,
            experienceTags: _experienceTags?.build(),
            bestFor: _bestFor?.build(),
            budgetPerPerson: _budgetPerPerson?.build(),
            durationHours: durationHours,
            difficultyRating: difficultyRating,
            physicalDemand: physicalDemand,
            bestTime: bestTime,
            isPublic: isPublic,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'experienceTags';
        _experienceTags?.build();
        _$failedField = 'bestFor';
        _bestFor?.build();
        _$failedField = 'budgetPerPerson';
        _budgetPerPerson?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlaceMetadataCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
