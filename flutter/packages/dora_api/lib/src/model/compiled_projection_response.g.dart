// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_projection_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompiledProjectionResponse extends CompiledProjectionResponse {
  @override
  final String tripId;
  @override
  final int compilerVersion;
  @override
  final bool stale;
  @override
  final DateTime? compiledAt;
  @override
  final BuiltList<CompiledTimelineEntry>? timelineEntries;
  @override
  final BuiltList<CompiledTimelineDayGroup>? timelineGroups;
  @override
  final BuiltList<CompiledRouteSegment>? routeSegments;
  @override
  final CompiledProjectionStats? stats;

  factory _$CompiledProjectionResponse(
          [void Function(CompiledProjectionResponseBuilder)? updates]) =>
      (CompiledProjectionResponseBuilder()..update(updates))._build();

  _$CompiledProjectionResponse._(
      {required this.tripId,
      required this.compilerVersion,
      required this.stale,
      this.compiledAt,
      this.timelineEntries,
      this.timelineGroups,
      this.routeSegments,
      this.stats})
      : super._();
  @override
  CompiledProjectionResponse rebuild(
          void Function(CompiledProjectionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompiledProjectionResponseBuilder toBuilder() =>
      CompiledProjectionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompiledProjectionResponse &&
        tripId == other.tripId &&
        compilerVersion == other.compilerVersion &&
        stale == other.stale &&
        compiledAt == other.compiledAt &&
        timelineEntries == other.timelineEntries &&
        timelineGroups == other.timelineGroups &&
        routeSegments == other.routeSegments &&
        stats == other.stats;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, compilerVersion.hashCode);
    _$hash = $jc(_$hash, stale.hashCode);
    _$hash = $jc(_$hash, compiledAt.hashCode);
    _$hash = $jc(_$hash, timelineEntries.hashCode);
    _$hash = $jc(_$hash, timelineGroups.hashCode);
    _$hash = $jc(_$hash, routeSegments.hashCode);
    _$hash = $jc(_$hash, stats.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompiledProjectionResponse')
          ..add('tripId', tripId)
          ..add('compilerVersion', compilerVersion)
          ..add('stale', stale)
          ..add('compiledAt', compiledAt)
          ..add('timelineEntries', timelineEntries)
          ..add('timelineGroups', timelineGroups)
          ..add('routeSegments', routeSegments)
          ..add('stats', stats))
        .toString();
  }
}

class CompiledProjectionResponseBuilder
    implements
        Builder<CompiledProjectionResponse, CompiledProjectionResponseBuilder> {
  _$CompiledProjectionResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  int? _compilerVersion;
  int? get compilerVersion => _$this._compilerVersion;
  set compilerVersion(int? compilerVersion) =>
      _$this._compilerVersion = compilerVersion;

  bool? _stale;
  bool? get stale => _$this._stale;
  set stale(bool? stale) => _$this._stale = stale;

  DateTime? _compiledAt;
  DateTime? get compiledAt => _$this._compiledAt;
  set compiledAt(DateTime? compiledAt) => _$this._compiledAt = compiledAt;

  ListBuilder<CompiledTimelineEntry>? _timelineEntries;
  ListBuilder<CompiledTimelineEntry> get timelineEntries =>
      _$this._timelineEntries ??= ListBuilder<CompiledTimelineEntry>();
  set timelineEntries(ListBuilder<CompiledTimelineEntry>? timelineEntries) =>
      _$this._timelineEntries = timelineEntries;

  ListBuilder<CompiledTimelineDayGroup>? _timelineGroups;
  ListBuilder<CompiledTimelineDayGroup> get timelineGroups =>
      _$this._timelineGroups ??= ListBuilder<CompiledTimelineDayGroup>();
  set timelineGroups(ListBuilder<CompiledTimelineDayGroup>? timelineGroups) =>
      _$this._timelineGroups = timelineGroups;

  ListBuilder<CompiledRouteSegment>? _routeSegments;
  ListBuilder<CompiledRouteSegment> get routeSegments =>
      _$this._routeSegments ??= ListBuilder<CompiledRouteSegment>();
  set routeSegments(ListBuilder<CompiledRouteSegment>? routeSegments) =>
      _$this._routeSegments = routeSegments;

  CompiledProjectionStatsBuilder? _stats;
  CompiledProjectionStatsBuilder get stats =>
      _$this._stats ??= CompiledProjectionStatsBuilder();
  set stats(CompiledProjectionStatsBuilder? stats) => _$this._stats = stats;

  CompiledProjectionResponseBuilder() {
    CompiledProjectionResponse._defaults(this);
  }

  CompiledProjectionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _compilerVersion = $v.compilerVersion;
      _stale = $v.stale;
      _compiledAt = $v.compiledAt;
      _timelineEntries = $v.timelineEntries?.toBuilder();
      _timelineGroups = $v.timelineGroups?.toBuilder();
      _routeSegments = $v.routeSegments?.toBuilder();
      _stats = $v.stats?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompiledProjectionResponse other) {
    _$v = other as _$CompiledProjectionResponse;
  }

  @override
  void update(void Function(CompiledProjectionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompiledProjectionResponse build() => _build();

  _$CompiledProjectionResponse _build() {
    _$CompiledProjectionResponse _$result;
    try {
      _$result = _$v ??
          _$CompiledProjectionResponse._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'CompiledProjectionResponse', 'tripId'),
            compilerVersion: BuiltValueNullFieldError.checkNotNull(
                compilerVersion,
                r'CompiledProjectionResponse',
                'compilerVersion'),
            stale: BuiltValueNullFieldError.checkNotNull(
                stale, r'CompiledProjectionResponse', 'stale'),
            compiledAt: compiledAt,
            timelineEntries: _timelineEntries?.build(),
            timelineGroups: _timelineGroups?.build(),
            routeSegments: _routeSegments?.build(),
            stats: _stats?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'timelineEntries';
        _timelineEntries?.build();
        _$failedField = 'timelineGroups';
        _timelineGroups?.build();
        _$failedField = 'routeSegments';
        _routeSegments?.build();
        _$failedField = 'stats';
        _stats?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompiledProjectionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
