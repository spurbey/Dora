// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripCreate extends TripCreate {
  @override
  final String title;
  @override
  final String? description;
  @override
  final Date? startDate;
  @override
  final Date? endDate;
  @override
  final String? coverPhotoUrl;
  @override
  final String? visibility;
  @override
  final BuiltList<String>? activityFocus;
  @override
  final BuiltList<String>? travelStyle;
  @override
  final String? budgetCategory;

  factory _$TripCreate([void Function(TripCreateBuilder)? updates]) =>
      (TripCreateBuilder()..update(updates))._build();

  _$TripCreate._(
      {required this.title,
      this.description,
      this.startDate,
      this.endDate,
      this.coverPhotoUrl,
      this.visibility,
      this.activityFocus,
      this.travelStyle,
      this.budgetCategory})
      : super._();
  @override
  TripCreate rebuild(void Function(TripCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripCreateBuilder toBuilder() => TripCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripCreate &&
        title == other.title &&
        description == other.description &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        coverPhotoUrl == other.coverPhotoUrl &&
        visibility == other.visibility &&
        activityFocus == other.activityFocus &&
        travelStyle == other.travelStyle &&
        budgetCategory == other.budgetCategory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, coverPhotoUrl.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jc(_$hash, activityFocus.hashCode);
    _$hash = $jc(_$hash, travelStyle.hashCode);
    _$hash = $jc(_$hash, budgetCategory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripCreate')
          ..add('title', title)
          ..add('description', description)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('coverPhotoUrl', coverPhotoUrl)
          ..add('visibility', visibility)
          ..add('activityFocus', activityFocus)
          ..add('travelStyle', travelStyle)
          ..add('budgetCategory', budgetCategory))
        .toString();
  }
}

class TripCreateBuilder implements Builder<TripCreate, TripCreateBuilder> {
  _$TripCreate? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  Date? _startDate;
  Date? get startDate => _$this._startDate;
  set startDate(Date? startDate) => _$this._startDate = startDate;

  Date? _endDate;
  Date? get endDate => _$this._endDate;
  set endDate(Date? endDate) => _$this._endDate = endDate;

  String? _coverPhotoUrl;
  String? get coverPhotoUrl => _$this._coverPhotoUrl;
  set coverPhotoUrl(String? coverPhotoUrl) =>
      _$this._coverPhotoUrl = coverPhotoUrl;

  String? _visibility;
  String? get visibility => _$this._visibility;
  set visibility(String? visibility) => _$this._visibility = visibility;

  ListBuilder<String>? _activityFocus;
  ListBuilder<String> get activityFocus =>
      _$this._activityFocus ??= ListBuilder<String>();
  set activityFocus(ListBuilder<String>? activityFocus) =>
      _$this._activityFocus = activityFocus;

  ListBuilder<String>? _travelStyle;
  ListBuilder<String> get travelStyle =>
      _$this._travelStyle ??= ListBuilder<String>();
  set travelStyle(ListBuilder<String>? travelStyle) =>
      _$this._travelStyle = travelStyle;

  String? _budgetCategory;
  String? get budgetCategory => _$this._budgetCategory;
  set budgetCategory(String? budgetCategory) =>
      _$this._budgetCategory = budgetCategory;

  TripCreateBuilder() {
    TripCreate._defaults(this);
  }

  TripCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _description = $v.description;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _coverPhotoUrl = $v.coverPhotoUrl;
      _visibility = $v.visibility;
      _activityFocus = $v.activityFocus?.toBuilder();
      _travelStyle = $v.travelStyle?.toBuilder();
      _budgetCategory = $v.budgetCategory;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripCreate other) {
    _$v = other as _$TripCreate;
  }

  @override
  void update(void Function(TripCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripCreate build() => _build();

  _$TripCreate _build() {
    _$TripCreate _$result;
    try {
      _$result = _$v ??
          _$TripCreate._(
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'TripCreate', 'title'),
            description: description,
            startDate: startDate,
            endDate: endDate,
            coverPhotoUrl: coverPhotoUrl,
            visibility: visibility,
            activityFocus: _activityFocus?.build(),
            travelStyle: _travelStyle?.build(),
            budgetCategory: budgetCategory,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activityFocus';
        _activityFocus?.build();
        _$failedField = 'travelStyle';
        _travelStyle?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TripCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
