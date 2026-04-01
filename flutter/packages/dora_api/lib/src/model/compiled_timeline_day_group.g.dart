// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_timeline_day_group.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompiledTimelineDayGroup extends CompiledTimelineDayGroup {
  @override
  final Date day;
  @override
  final BuiltList<CompiledTimelineEntry>? placeEntries;
  @override
  final BuiltList<CompiledTimelineEntry>? onRouteEntries;

  factory _$CompiledTimelineDayGroup(
          [void Function(CompiledTimelineDayGroupBuilder)? updates]) =>
      (CompiledTimelineDayGroupBuilder()..update(updates))._build();

  _$CompiledTimelineDayGroup._(
      {required this.day, this.placeEntries, this.onRouteEntries})
      : super._();
  @override
  CompiledTimelineDayGroup rebuild(
          void Function(CompiledTimelineDayGroupBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompiledTimelineDayGroupBuilder toBuilder() =>
      CompiledTimelineDayGroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompiledTimelineDayGroup &&
        day == other.day &&
        placeEntries == other.placeEntries &&
        onRouteEntries == other.onRouteEntries;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, day.hashCode);
    _$hash = $jc(_$hash, placeEntries.hashCode);
    _$hash = $jc(_$hash, onRouteEntries.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompiledTimelineDayGroup')
          ..add('day', day)
          ..add('placeEntries', placeEntries)
          ..add('onRouteEntries', onRouteEntries))
        .toString();
  }
}

class CompiledTimelineDayGroupBuilder
    implements
        Builder<CompiledTimelineDayGroup, CompiledTimelineDayGroupBuilder> {
  _$CompiledTimelineDayGroup? _$v;

  Date? _day;
  Date? get day => _$this._day;
  set day(Date? day) => _$this._day = day;

  ListBuilder<CompiledTimelineEntry>? _placeEntries;
  ListBuilder<CompiledTimelineEntry> get placeEntries =>
      _$this._placeEntries ??= ListBuilder<CompiledTimelineEntry>();
  set placeEntries(ListBuilder<CompiledTimelineEntry>? placeEntries) =>
      _$this._placeEntries = placeEntries;

  ListBuilder<CompiledTimelineEntry>? _onRouteEntries;
  ListBuilder<CompiledTimelineEntry> get onRouteEntries =>
      _$this._onRouteEntries ??= ListBuilder<CompiledTimelineEntry>();
  set onRouteEntries(ListBuilder<CompiledTimelineEntry>? onRouteEntries) =>
      _$this._onRouteEntries = onRouteEntries;

  CompiledTimelineDayGroupBuilder() {
    CompiledTimelineDayGroup._defaults(this);
  }

  CompiledTimelineDayGroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _day = $v.day;
      _placeEntries = $v.placeEntries?.toBuilder();
      _onRouteEntries = $v.onRouteEntries?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompiledTimelineDayGroup other) {
    _$v = other as _$CompiledTimelineDayGroup;
  }

  @override
  void update(void Function(CompiledTimelineDayGroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompiledTimelineDayGroup build() => _build();

  _$CompiledTimelineDayGroup _build() {
    _$CompiledTimelineDayGroup _$result;
    try {
      _$result = _$v ??
          _$CompiledTimelineDayGroup._(
            day: BuiltValueNullFieldError.checkNotNull(
                day, r'CompiledTimelineDayGroup', 'day'),
            placeEntries: _placeEntries?.build(),
            onRouteEntries: _onRouteEntries?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'placeEntries';
        _placeEntries?.build();
        _$failedField = 'onRouteEntries';
        _onRouteEntries?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompiledTimelineDayGroup', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
