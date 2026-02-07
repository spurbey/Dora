// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TripResponse extends TripResponse {
  @override
  final String id;
  @override
  final String userId;
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
  final String visibility;
  @override
  final int viewsCount;
  @override
  final int savesCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$TripResponse([void Function(TripResponseBuilder)? updates]) =>
      (TripResponseBuilder()..update(updates))._build();

  _$TripResponse._(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      this.startDate,
      this.endDate,
      this.coverPhotoUrl,
      required this.visibility,
      required this.viewsCount,
      required this.savesCount,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  TripResponse rebuild(void Function(TripResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TripResponseBuilder toBuilder() => TripResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TripResponse &&
        id == other.id &&
        userId == other.userId &&
        title == other.title &&
        description == other.description &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        coverPhotoUrl == other.coverPhotoUrl &&
        visibility == other.visibility &&
        viewsCount == other.viewsCount &&
        savesCount == other.savesCount &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, coverPhotoUrl.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jc(_$hash, viewsCount.hashCode);
    _$hash = $jc(_$hash, savesCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TripResponse')
          ..add('id', id)
          ..add('userId', userId)
          ..add('title', title)
          ..add('description', description)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('coverPhotoUrl', coverPhotoUrl)
          ..add('visibility', visibility)
          ..add('viewsCount', viewsCount)
          ..add('savesCount', savesCount)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class TripResponseBuilder
    implements Builder<TripResponse, TripResponseBuilder> {
  _$TripResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

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

  int? _viewsCount;
  int? get viewsCount => _$this._viewsCount;
  set viewsCount(int? viewsCount) => _$this._viewsCount = viewsCount;

  int? _savesCount;
  int? get savesCount => _$this._savesCount;
  set savesCount(int? savesCount) => _$this._savesCount = savesCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  TripResponseBuilder() {
    TripResponse._defaults(this);
  }

  TripResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _title = $v.title;
      _description = $v.description;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _coverPhotoUrl = $v.coverPhotoUrl;
      _visibility = $v.visibility;
      _viewsCount = $v.viewsCount;
      _savesCount = $v.savesCount;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TripResponse other) {
    _$v = other as _$TripResponse;
  }

  @override
  void update(void Function(TripResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TripResponse build() => _build();

  _$TripResponse _build() {
    final _$result = _$v ??
        _$TripResponse._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'TripResponse', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'TripResponse', 'userId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'TripResponse', 'title'),
          description: description,
          startDate: startDate,
          endDate: endDate,
          coverPhotoUrl: coverPhotoUrl,
          visibility: BuiltValueNullFieldError.checkNotNull(
              visibility, r'TripResponse', 'visibility'),
          viewsCount: BuiltValueNullFieldError.checkNotNull(
              viewsCount, r'TripResponse', 'viewsCount'),
          savesCount: BuiltValueNullFieldError.checkNotNull(
              savesCount, r'TripResponse', 'savesCount'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'TripResponse', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'TripResponse', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
