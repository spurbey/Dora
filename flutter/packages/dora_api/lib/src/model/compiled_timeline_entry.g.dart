// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_timeline_entry.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompiledTimelineEntry extends CompiledTimelineEntry {
  @override
  final String entryId;
  @override
  final String sourceKind;
  @override
  final String sourceId;
  @override
  final String eventType;
  @override
  final DateTime capturedAt;
  @override
  final String bucketType;
  @override
  final String? placeId;
  @override
  final String? placeName;
  @override
  final String bindSource;
  @override
  final num? bindConfidence;
  @override
  final String? reasonCode;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final BuiltMap<String, JsonObject?>? payload;

  factory _$CompiledTimelineEntry(
          [void Function(CompiledTimelineEntryBuilder)? updates]) =>
      (CompiledTimelineEntryBuilder()..update(updates))._build();

  _$CompiledTimelineEntry._(
      {required this.entryId,
      required this.sourceKind,
      required this.sourceId,
      required this.eventType,
      required this.capturedAt,
      required this.bucketType,
      this.placeId,
      this.placeName,
      required this.bindSource,
      this.bindConfidence,
      this.reasonCode,
      required this.title,
      this.subtitle,
      this.payload})
      : super._();
  @override
  CompiledTimelineEntry rebuild(
          void Function(CompiledTimelineEntryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompiledTimelineEntryBuilder toBuilder() =>
      CompiledTimelineEntryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompiledTimelineEntry &&
        entryId == other.entryId &&
        sourceKind == other.sourceKind &&
        sourceId == other.sourceId &&
        eventType == other.eventType &&
        capturedAt == other.capturedAt &&
        bucketType == other.bucketType &&
        placeId == other.placeId &&
        placeName == other.placeName &&
        bindSource == other.bindSource &&
        bindConfidence == other.bindConfidence &&
        reasonCode == other.reasonCode &&
        title == other.title &&
        subtitle == other.subtitle &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entryId.hashCode);
    _$hash = $jc(_$hash, sourceKind.hashCode);
    _$hash = $jc(_$hash, sourceId.hashCode);
    _$hash = $jc(_$hash, eventType.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, bucketType.hashCode);
    _$hash = $jc(_$hash, placeId.hashCode);
    _$hash = $jc(_$hash, placeName.hashCode);
    _$hash = $jc(_$hash, bindSource.hashCode);
    _$hash = $jc(_$hash, bindConfidence.hashCode);
    _$hash = $jc(_$hash, reasonCode.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subtitle.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompiledTimelineEntry')
          ..add('entryId', entryId)
          ..add('sourceKind', sourceKind)
          ..add('sourceId', sourceId)
          ..add('eventType', eventType)
          ..add('capturedAt', capturedAt)
          ..add('bucketType', bucketType)
          ..add('placeId', placeId)
          ..add('placeName', placeName)
          ..add('bindSource', bindSource)
          ..add('bindConfidence', bindConfidence)
          ..add('reasonCode', reasonCode)
          ..add('title', title)
          ..add('subtitle', subtitle)
          ..add('payload', payload))
        .toString();
  }
}

class CompiledTimelineEntryBuilder
    implements Builder<CompiledTimelineEntry, CompiledTimelineEntryBuilder> {
  _$CompiledTimelineEntry? _$v;

  String? _entryId;
  String? get entryId => _$this._entryId;
  set entryId(String? entryId) => _$this._entryId = entryId;

  String? _sourceKind;
  String? get sourceKind => _$this._sourceKind;
  set sourceKind(String? sourceKind) => _$this._sourceKind = sourceKind;

  String? _sourceId;
  String? get sourceId => _$this._sourceId;
  set sourceId(String? sourceId) => _$this._sourceId = sourceId;

  String? _eventType;
  String? get eventType => _$this._eventType;
  set eventType(String? eventType) => _$this._eventType = eventType;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  String? _bucketType;
  String? get bucketType => _$this._bucketType;
  set bucketType(String? bucketType) => _$this._bucketType = bucketType;

  String? _placeId;
  String? get placeId => _$this._placeId;
  set placeId(String? placeId) => _$this._placeId = placeId;

  String? _placeName;
  String? get placeName => _$this._placeName;
  set placeName(String? placeName) => _$this._placeName = placeName;

  String? _bindSource;
  String? get bindSource => _$this._bindSource;
  set bindSource(String? bindSource) => _$this._bindSource = bindSource;

  num? _bindConfidence;
  num? get bindConfidence => _$this._bindConfidence;
  set bindConfidence(num? bindConfidence) =>
      _$this._bindConfidence = bindConfidence;

  String? _reasonCode;
  String? get reasonCode => _$this._reasonCode;
  set reasonCode(String? reasonCode) => _$this._reasonCode = reasonCode;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _subtitle;
  String? get subtitle => _$this._subtitle;
  set subtitle(String? subtitle) => _$this._subtitle = subtitle;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  CompiledTimelineEntryBuilder() {
    CompiledTimelineEntry._defaults(this);
  }

  CompiledTimelineEntryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entryId = $v.entryId;
      _sourceKind = $v.sourceKind;
      _sourceId = $v.sourceId;
      _eventType = $v.eventType;
      _capturedAt = $v.capturedAt;
      _bucketType = $v.bucketType;
      _placeId = $v.placeId;
      _placeName = $v.placeName;
      _bindSource = $v.bindSource;
      _bindConfidence = $v.bindConfidence;
      _reasonCode = $v.reasonCode;
      _title = $v.title;
      _subtitle = $v.subtitle;
      _payload = $v.payload?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompiledTimelineEntry other) {
    _$v = other as _$CompiledTimelineEntry;
  }

  @override
  void update(void Function(CompiledTimelineEntryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompiledTimelineEntry build() => _build();

  _$CompiledTimelineEntry _build() {
    _$CompiledTimelineEntry _$result;
    try {
      _$result = _$v ??
          _$CompiledTimelineEntry._(
            entryId: BuiltValueNullFieldError.checkNotNull(
                entryId, r'CompiledTimelineEntry', 'entryId'),
            sourceKind: BuiltValueNullFieldError.checkNotNull(
                sourceKind, r'CompiledTimelineEntry', 'sourceKind'),
            sourceId: BuiltValueNullFieldError.checkNotNull(
                sourceId, r'CompiledTimelineEntry', 'sourceId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'CompiledTimelineEntry', 'eventType'),
            capturedAt: BuiltValueNullFieldError.checkNotNull(
                capturedAt, r'CompiledTimelineEntry', 'capturedAt'),
            bucketType: BuiltValueNullFieldError.checkNotNull(
                bucketType, r'CompiledTimelineEntry', 'bucketType'),
            placeId: placeId,
            placeName: placeName,
            bindSource: BuiltValueNullFieldError.checkNotNull(
                bindSource, r'CompiledTimelineEntry', 'bindSource'),
            bindConfidence: bindConfidence,
            reasonCode: reasonCode,
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'CompiledTimelineEntry', 'title'),
            subtitle: subtitle,
            payload: _payload?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        _payload?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompiledTimelineEntry', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
