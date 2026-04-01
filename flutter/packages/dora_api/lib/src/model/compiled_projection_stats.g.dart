// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_projection_stats.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompiledProjectionStats extends CompiledProjectionStats {
  @override
  final int? rawEventCount;
  @override
  final int? compiledEventCount;
  @override
  final int? rawPointCount;
  @override
  final int? compiledRouteSegmentCount;
  @override
  final bool? hasDrift;
  @override
  final int? rawEventCountDelta;
  @override
  final int? compiledEventCountDelta;
  @override
  final int? compiledRouteSegmentCountDelta;
  @override
  final int? rawVsCompiledEventDelta;
  @override
  final BuiltList<String>? driftReasons;

  factory _$CompiledProjectionStats(
          [void Function(CompiledProjectionStatsBuilder)? updates]) =>
      (CompiledProjectionStatsBuilder()..update(updates))._build();

  _$CompiledProjectionStats._(
      {this.rawEventCount,
      this.compiledEventCount,
      this.rawPointCount,
      this.compiledRouteSegmentCount,
      this.hasDrift,
      this.rawEventCountDelta,
      this.compiledEventCountDelta,
      this.compiledRouteSegmentCountDelta,
      this.rawVsCompiledEventDelta,
      this.driftReasons})
      : super._();
  @override
  CompiledProjectionStats rebuild(
          void Function(CompiledProjectionStatsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompiledProjectionStatsBuilder toBuilder() =>
      CompiledProjectionStatsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompiledProjectionStats &&
        rawEventCount == other.rawEventCount &&
        compiledEventCount == other.compiledEventCount &&
        rawPointCount == other.rawPointCount &&
        compiledRouteSegmentCount == other.compiledRouteSegmentCount &&
        hasDrift == other.hasDrift &&
        rawEventCountDelta == other.rawEventCountDelta &&
        compiledEventCountDelta == other.compiledEventCountDelta &&
        compiledRouteSegmentCountDelta ==
            other.compiledRouteSegmentCountDelta &&
        rawVsCompiledEventDelta == other.rawVsCompiledEventDelta &&
        driftReasons == other.driftReasons;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rawEventCount.hashCode);
    _$hash = $jc(_$hash, compiledEventCount.hashCode);
    _$hash = $jc(_$hash, rawPointCount.hashCode);
    _$hash = $jc(_$hash, compiledRouteSegmentCount.hashCode);
    _$hash = $jc(_$hash, hasDrift.hashCode);
    _$hash = $jc(_$hash, rawEventCountDelta.hashCode);
    _$hash = $jc(_$hash, compiledEventCountDelta.hashCode);
    _$hash = $jc(_$hash, compiledRouteSegmentCountDelta.hashCode);
    _$hash = $jc(_$hash, rawVsCompiledEventDelta.hashCode);
    _$hash = $jc(_$hash, driftReasons.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompiledProjectionStats')
          ..add('rawEventCount', rawEventCount)
          ..add('compiledEventCount', compiledEventCount)
          ..add('rawPointCount', rawPointCount)
          ..add('compiledRouteSegmentCount', compiledRouteSegmentCount)
          ..add('hasDrift', hasDrift)
          ..add('rawEventCountDelta', rawEventCountDelta)
          ..add('compiledEventCountDelta', compiledEventCountDelta)
          ..add(
              'compiledRouteSegmentCountDelta', compiledRouteSegmentCountDelta)
          ..add('rawVsCompiledEventDelta', rawVsCompiledEventDelta)
          ..add('driftReasons', driftReasons))
        .toString();
  }
}

class CompiledProjectionStatsBuilder
    implements
        Builder<CompiledProjectionStats, CompiledProjectionStatsBuilder> {
  _$CompiledProjectionStats? _$v;

  int? _rawEventCount;
  int? get rawEventCount => _$this._rawEventCount;
  set rawEventCount(int? rawEventCount) =>
      _$this._rawEventCount = rawEventCount;

  int? _compiledEventCount;
  int? get compiledEventCount => _$this._compiledEventCount;
  set compiledEventCount(int? compiledEventCount) =>
      _$this._compiledEventCount = compiledEventCount;

  int? _rawPointCount;
  int? get rawPointCount => _$this._rawPointCount;
  set rawPointCount(int? rawPointCount) =>
      _$this._rawPointCount = rawPointCount;

  int? _compiledRouteSegmentCount;
  int? get compiledRouteSegmentCount => _$this._compiledRouteSegmentCount;
  set compiledRouteSegmentCount(int? compiledRouteSegmentCount) =>
      _$this._compiledRouteSegmentCount = compiledRouteSegmentCount;

  bool? _hasDrift;
  bool? get hasDrift => _$this._hasDrift;
  set hasDrift(bool? hasDrift) => _$this._hasDrift = hasDrift;

  int? _rawEventCountDelta;
  int? get rawEventCountDelta => _$this._rawEventCountDelta;
  set rawEventCountDelta(int? rawEventCountDelta) =>
      _$this._rawEventCountDelta = rawEventCountDelta;

  int? _compiledEventCountDelta;
  int? get compiledEventCountDelta => _$this._compiledEventCountDelta;
  set compiledEventCountDelta(int? compiledEventCountDelta) =>
      _$this._compiledEventCountDelta = compiledEventCountDelta;

  int? _compiledRouteSegmentCountDelta;
  int? get compiledRouteSegmentCountDelta =>
      _$this._compiledRouteSegmentCountDelta;
  set compiledRouteSegmentCountDelta(int? compiledRouteSegmentCountDelta) =>
      _$this._compiledRouteSegmentCountDelta = compiledRouteSegmentCountDelta;

  int? _rawVsCompiledEventDelta;
  int? get rawVsCompiledEventDelta => _$this._rawVsCompiledEventDelta;
  set rawVsCompiledEventDelta(int? rawVsCompiledEventDelta) =>
      _$this._rawVsCompiledEventDelta = rawVsCompiledEventDelta;

  ListBuilder<String>? _driftReasons;
  ListBuilder<String> get driftReasons =>
      _$this._driftReasons ??= ListBuilder<String>();
  set driftReasons(ListBuilder<String>? driftReasons) =>
      _$this._driftReasons = driftReasons;

  CompiledProjectionStatsBuilder() {
    CompiledProjectionStats._defaults(this);
  }

  CompiledProjectionStatsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rawEventCount = $v.rawEventCount;
      _compiledEventCount = $v.compiledEventCount;
      _rawPointCount = $v.rawPointCount;
      _compiledRouteSegmentCount = $v.compiledRouteSegmentCount;
      _hasDrift = $v.hasDrift;
      _rawEventCountDelta = $v.rawEventCountDelta;
      _compiledEventCountDelta = $v.compiledEventCountDelta;
      _compiledRouteSegmentCountDelta = $v.compiledRouteSegmentCountDelta;
      _rawVsCompiledEventDelta = $v.rawVsCompiledEventDelta;
      _driftReasons = $v.driftReasons?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompiledProjectionStats other) {
    _$v = other as _$CompiledProjectionStats;
  }

  @override
  void update(void Function(CompiledProjectionStatsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompiledProjectionStats build() => _build();

  _$CompiledProjectionStats _build() {
    _$CompiledProjectionStats _$result;
    try {
      _$result = _$v ??
          _$CompiledProjectionStats._(
            rawEventCount: rawEventCount,
            compiledEventCount: compiledEventCount,
            rawPointCount: rawPointCount,
            compiledRouteSegmentCount: compiledRouteSegmentCount,
            hasDrift: hasDrift,
            rawEventCountDelta: rawEventCountDelta,
            compiledEventCountDelta: compiledEventCountDelta,
            compiledRouteSegmentCountDelta: compiledRouteSegmentCountDelta,
            rawVsCompiledEventDelta: rawVsCompiledEventDelta,
            driftReasons: _driftReasons?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'driftReasons';
        _driftReasons?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompiledProjectionStats', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
