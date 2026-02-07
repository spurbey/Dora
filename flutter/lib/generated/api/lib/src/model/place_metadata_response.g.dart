// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_metadata_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlaceMetadataResponse extends PlaceMetadataResponse {
  @override
  final String? componentType;
  @override
  final BuiltList<String>? experienceTags;
  @override
  final BuiltList<String>? bestFor;
  @override
  final String? budgetPerPerson;
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
  @override
  final String placeId;
  @override
  final num contributionScore;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PlaceMetadataResponse(
          [void Function(PlaceMetadataResponseBuilder)? updates]) =>
      (PlaceMetadataResponseBuilder()..update(updates))._build();

  _$PlaceMetadataResponse._(
      {this.componentType,
      this.experienceTags,
      this.bestFor,
      this.budgetPerPerson,
      this.durationHours,
      this.difficultyRating,
      this.physicalDemand,
      this.bestTime,
      this.isPublic,
      required this.placeId,
      required this.contributionScore,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PlaceMetadataResponse rebuild(
          void Function(PlaceMetadataResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlaceMetadataResponseBuilder toBuilder() =>
      PlaceMetadataResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlaceMetadataResponse &&
        componentType == other.componentType &&
        experienceTags == other.experienceTags &&
        bestFor == other.bestFor &&
        budgetPerPerson == other.budgetPerPerson &&
        durationHours == other.durationHours &&
        difficultyRating == other.difficultyRating &&
        physicalDemand == other.physicalDemand &&
        bestTime == other.bestTime &&
        isPublic == other.isPublic &&
        placeId == other.placeId &&
        contributionScore == other.contributionScore &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, placeId.hashCode);
    _$hash = $jc(_$hash, contributionScore.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlaceMetadataResponse')
          ..add('componentType', componentType)
          ..add('experienceTags', experienceTags)
          ..add('bestFor', bestFor)
          ..add('budgetPerPerson', budgetPerPerson)
          ..add('durationHours', durationHours)
          ..add('difficultyRating', difficultyRating)
          ..add('physicalDemand', physicalDemand)
          ..add('bestTime', bestTime)
          ..add('isPublic', isPublic)
          ..add('placeId', placeId)
          ..add('contributionScore', contributionScore)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PlaceMetadataResponseBuilder
    implements Builder<PlaceMetadataResponse, PlaceMetadataResponseBuilder> {
  _$PlaceMetadataResponse? _$v;

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

  String? _budgetPerPerson;
  String? get budgetPerPerson => _$this._budgetPerPerson;
  set budgetPerPerson(String? budgetPerPerson) =>
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

  String? _placeId;
  String? get placeId => _$this._placeId;
  set placeId(String? placeId) => _$this._placeId = placeId;

  num? _contributionScore;
  num? get contributionScore => _$this._contributionScore;
  set contributionScore(num? contributionScore) =>
      _$this._contributionScore = contributionScore;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PlaceMetadataResponseBuilder() {
    PlaceMetadataResponse._defaults(this);
  }

  PlaceMetadataResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _componentType = $v.componentType;
      _experienceTags = $v.experienceTags?.toBuilder();
      _bestFor = $v.bestFor?.toBuilder();
      _budgetPerPerson = $v.budgetPerPerson;
      _durationHours = $v.durationHours;
      _difficultyRating = $v.difficultyRating;
      _physicalDemand = $v.physicalDemand;
      _bestTime = $v.bestTime;
      _isPublic = $v.isPublic;
      _placeId = $v.placeId;
      _contributionScore = $v.contributionScore;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlaceMetadataResponse other) {
    _$v = other as _$PlaceMetadataResponse;
  }

  @override
  void update(void Function(PlaceMetadataResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlaceMetadataResponse build() => _build();

  _$PlaceMetadataResponse _build() {
    _$PlaceMetadataResponse _$result;
    try {
      _$result = _$v ??
          _$PlaceMetadataResponse._(
            componentType: componentType,
            experienceTags: _experienceTags?.build(),
            bestFor: _bestFor?.build(),
            budgetPerPerson: budgetPerPerson,
            durationHours: durationHours,
            difficultyRating: difficultyRating,
            physicalDemand: physicalDemand,
            bestTime: bestTime,
            isPublic: isPublic,
            placeId: BuiltValueNullFieldError.checkNotNull(
                placeId, r'PlaceMetadataResponse', 'placeId'),
            contributionScore: BuiltValueNullFieldError.checkNotNull(
                contributionScore,
                r'PlaceMetadataResponse',
                'contributionScore'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'PlaceMetadataResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'PlaceMetadataResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'experienceTags';
        _experienceTags?.build();
        _$failedField = 'bestFor';
        _bestFor?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlaceMetadataResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
