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

  factory _$TripCreate([void Function(TripCreateBuilder)? updates]) =>
      (TripCreateBuilder()..update(updates))._build();

  _$TripCreate._(
      {required this.title,
      this.description,
      this.startDate,
      this.endDate,
      this.coverPhotoUrl,
      this.visibility})
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
        visibility == other.visibility;
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
          ..add('visibility', visibility))
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
    final _$result = _$v ??
        _$TripCreate._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'TripCreate', 'title'),
          description: description,
          startDate: startDate,
          endDate: endDate,
          coverPhotoUrl: coverPhotoUrl,
          visibility: visibility,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
