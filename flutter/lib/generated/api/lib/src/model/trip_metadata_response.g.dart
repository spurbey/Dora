// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_metadata_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripMetadataResponse extends TripMetadataResponse {
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
  @override
  final String tripId;
  @override
  final num qualityScore;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$TripMetadataResponse(
          [void Function(TripMetadataResponseBuilder)? updates]) =>
      (TripMetadataResponseBuilder()..update(updates))._build();

  _$TripMetadataResponse._(
      {this.travelerType,
      this.ageGroup,
      this.travelStyle,
      this.difficultyLevel,
      this.budgetCategory,
      this.activityFocus,
      this.isDiscoverable,
      this.tags,
      required this.tripId,
      required this.qualityScore,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  TripMetadataResponse rebuild(
          void Function(TripMetadataResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripMetadataResponseBuilder toBuilder() =>
      TripMetadataResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripMetadataResponse &&
        travelerType == other.travelerType &&
        ageGroup == other.ageGroup &&
        travelStyle == other.travelStyle &&
        difficultyLevel == other.difficultyLevel &&
        budgetCategory == other.budgetCategory &&
        activityFocus == other.activityFocus &&
        isDiscoverable == other.isDiscoverable &&
        tags == other.tags &&
        tripId == other.tripId &&
        qualityScore == other.qualityScore &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, qualityScore.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripMetadataResponse')
          ..add('travelerType', travelerType)
          ..add('ageGroup', ageGroup)
          ..add('travelStyle', travelStyle)
          ..add('difficultyLevel', difficultyLevel)
          ..add('budgetCategory', budgetCategory)
          ..add('activityFocus', activityFocus)
          ..add('isDiscoverable', isDiscoverable)
          ..add('tags', tags)
          ..add('tripId', tripId)
          ..add('qualityScore', qualityScore)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class TripMetadataResponseBuilder
    implements Builder<TripMetadataResponse, TripMetadataResponseBuilder> {
  _$TripMetadataResponse? _$v;

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

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  num? _qualityScore;
  num? get qualityScore => _$this._qualityScore;
  set qualityScore(num? qualityScore) => _$this._qualityScore = qualityScore;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  TripMetadataResponseBuilder() {
    TripMetadataResponse._defaults(this);
  }

  TripMetadataResponseBuilder get _$this {
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
      _tripId = $v.tripId;
      _qualityScore = $v.qualityScore;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripMetadataResponse other) {
    _$v = other as _$TripMetadataResponse;
  }

  @override
  void update(void Function(TripMetadataResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripMetadataResponse build() => _build();

  _$TripMetadataResponse _build() {
    _$TripMetadataResponse _$result;
    try {
      _$result = _$v ??
          _$TripMetadataResponse._(
            travelerType: _travelerType?.build(),
            ageGroup: ageGroup,
            travelStyle: _travelStyle?.build(),
            difficultyLevel: difficultyLevel,
            budgetCategory: budgetCategory,
            activityFocus: _activityFocus?.build(),
            isDiscoverable: isDiscoverable,
            tags: _tags?.build(),
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TripMetadataResponse', 'tripId'),
            qualityScore: BuiltValueNullFieldError.checkNotNull(
                qualityScore, r'TripMetadataResponse', 'qualityScore'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'TripMetadataResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'TripMetadataResponse', 'updatedAt'),
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
            r'TripMetadataResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
