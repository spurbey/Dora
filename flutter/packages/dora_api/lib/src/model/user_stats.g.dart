// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserStats extends UserStats {
  @override
  final int? tripCount;
  @override
  final int? placeCount;
  @override
  final int? publicTripCount;
  @override
  final int? totalViews;
  @override
  final int? totalSaves;
  @override
  final int? photosUploaded;

  factory _$UserStats([void Function(UserStatsBuilder)? updates]) =>
      (UserStatsBuilder()..update(updates))._build();

  _$UserStats._(
      {this.tripCount,
      this.placeCount,
      this.publicTripCount,
      this.totalViews,
      this.totalSaves,
      this.photosUploaded})
      : super._();
  @override
  UserStats rebuild(void Function(UserStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserStatsBuilder toBuilder() => UserStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserStats &&
        tripCount == other.tripCount &&
        placeCount == other.placeCount &&
        publicTripCount == other.publicTripCount &&
        totalViews == other.totalViews &&
        totalSaves == other.totalSaves &&
        photosUploaded == other.photosUploaded;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripCount.hashCode);
    _$hash = $jc(_$hash, placeCount.hashCode);
    _$hash = $jc(_$hash, publicTripCount.hashCode);
    _$hash = $jc(_$hash, totalViews.hashCode);
    _$hash = $jc(_$hash, totalSaves.hashCode);
    _$hash = $jc(_$hash, photosUploaded.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserStats')
          ..add('tripCount', tripCount)
          ..add('placeCount', placeCount)
          ..add('publicTripCount', publicTripCount)
          ..add('totalViews', totalViews)
          ..add('totalSaves', totalSaves)
          ..add('photosUploaded', photosUploaded))
        .toString();
  }
}

class UserStatsBuilder implements Builder<UserStats, UserStatsBuilder> {
  _$UserStats? _$v;

  int? _tripCount;
  int? get tripCount => _$this._tripCount;
  set tripCount(int? tripCount) => _$this._tripCount = tripCount;

  int? _placeCount;
  int? get placeCount => _$this._placeCount;
  set placeCount(int? placeCount) => _$this._placeCount = placeCount;

  int? _publicTripCount;
  int? get publicTripCount => _$this._publicTripCount;
  set publicTripCount(int? publicTripCount) =>
      _$this._publicTripCount = publicTripCount;

  int? _totalViews;
  int? get totalViews => _$this._totalViews;
  set totalViews(int? totalViews) => _$this._totalViews = totalViews;

  int? _totalSaves;
  int? get totalSaves => _$this._totalSaves;
  set totalSaves(int? totalSaves) => _$this._totalSaves = totalSaves;

  int? _photosUploaded;
  int? get photosUploaded => _$this._photosUploaded;
  set photosUploaded(int? photosUploaded) =>
      _$this._photosUploaded = photosUploaded;

  UserStatsBuilder() {
    UserStats._defaults(this);
  }

  UserStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripCount = $v.tripCount;
      _placeCount = $v.placeCount;
      _publicTripCount = $v.publicTripCount;
      _totalViews = $v.totalViews;
      _totalSaves = $v.totalSaves;
      _photosUploaded = $v.photosUploaded;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserStats other) {
    _$v = other as _$UserStats;
  }

  @override
  void update(void Function(UserStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserStats build() => _build();

  _$UserStats _build() {
    final _$result = _$v ??
        _$UserStats._(
          tripCount: tripCount,
          placeCount: placeCount,
          publicTripCount: publicTripCount,
          totalViews: totalViews,
          totalSaves: totalSaves,
          photosUploaded: photosUploaded,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
