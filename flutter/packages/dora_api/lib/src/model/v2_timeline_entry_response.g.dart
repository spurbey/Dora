// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_timeline_entry_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2TimelineEntryResponse extends V2TimelineEntryResponse {
  @override
  final String entryId;
  @override
  final String entryKind;
  @override
  final String sourceServerId;
  @override
  final DateTime capturedAt;
  @override
  final String bucketType;
  @override
  final String? placeBindName;
  @override
  final String? placeBindId;
  @override
  final String? decisionSource;
  @override
  final bool manualLock;
  @override
  final num anchorLatitude;
  @override
  final num anchorLongitude;
  @override
  final String? routeSegmentKey;
  @override
  final num? routeDistanceM;
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final JsonObject? renderPayloadJson;

  factory _$V2TimelineEntryResponse(
          [void Function(V2TimelineEntryResponseBuilder)? updates]) =>
      (V2TimelineEntryResponseBuilder()..update(updates))._build();

  _$V2TimelineEntryResponse._(
      {required this.entryId,
      required this.entryKind,
      required this.sourceServerId,
      required this.capturedAt,
      required this.bucketType,
      this.placeBindName,
      this.placeBindId,
      this.decisionSource,
      required this.manualLock,
      required this.anchorLatitude,
      required this.anchorLongitude,
      this.routeSegmentKey,
      this.routeDistanceM,
      required this.title,
      this.subtitle,
      this.renderPayloadJson})
      : super._();
  @override
  V2TimelineEntryResponse rebuild(
          void Function(V2TimelineEntryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2TimelineEntryResponseBuilder toBuilder() =>
      V2TimelineEntryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2TimelineEntryResponse &&
        entryId == other.entryId &&
        entryKind == other.entryKind &&
        sourceServerId == other.sourceServerId &&
        capturedAt == other.capturedAt &&
        bucketType == other.bucketType &&
        placeBindName == other.placeBindName &&
        placeBindId == other.placeBindId &&
        decisionSource == other.decisionSource &&
        manualLock == other.manualLock &&
        anchorLatitude == other.anchorLatitude &&
        anchorLongitude == other.anchorLongitude &&
        routeSegmentKey == other.routeSegmentKey &&
        routeDistanceM == other.routeDistanceM &&
        title == other.title &&
        subtitle == other.subtitle &&
        renderPayloadJson == other.renderPayloadJson;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entryId.hashCode);
    _$hash = $jc(_$hash, entryKind.hashCode);
    _$hash = $jc(_$hash, sourceServerId.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, bucketType.hashCode);
    _$hash = $jc(_$hash, placeBindName.hashCode);
    _$hash = $jc(_$hash, placeBindId.hashCode);
    _$hash = $jc(_$hash, decisionSource.hashCode);
    _$hash = $jc(_$hash, manualLock.hashCode);
    _$hash = $jc(_$hash, anchorLatitude.hashCode);
    _$hash = $jc(_$hash, anchorLongitude.hashCode);
    _$hash = $jc(_$hash, routeSegmentKey.hashCode);
    _$hash = $jc(_$hash, routeDistanceM.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subtitle.hashCode);
    _$hash = $jc(_$hash, renderPayloadJson.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2TimelineEntryResponse')
          ..add('entryId', entryId)
          ..add('entryKind', entryKind)
          ..add('sourceServerId', sourceServerId)
          ..add('capturedAt', capturedAt)
          ..add('bucketType', bucketType)
          ..add('placeBindName', placeBindName)
          ..add('placeBindId', placeBindId)
          ..add('decisionSource', decisionSource)
          ..add('manualLock', manualLock)
          ..add('anchorLatitude', anchorLatitude)
          ..add('anchorLongitude', anchorLongitude)
          ..add('routeSegmentKey', routeSegmentKey)
          ..add('routeDistanceM', routeDistanceM)
          ..add('title', title)
          ..add('subtitle', subtitle)
          ..add('renderPayloadJson', renderPayloadJson))
        .toString();
  }
}

class V2TimelineEntryResponseBuilder
    implements
        Builder<V2TimelineEntryResponse, V2TimelineEntryResponseBuilder> {
  _$V2TimelineEntryResponse? _$v;

  String? _entryId;
  String? get entryId => _$this._entryId;
  set entryId(String? entryId) => _$this._entryId = entryId;

  String? _entryKind;
  String? get entryKind => _$this._entryKind;
  set entryKind(String? entryKind) => _$this._entryKind = entryKind;

  String? _sourceServerId;
  String? get sourceServerId => _$this._sourceServerId;
  set sourceServerId(String? sourceServerId) =>
      _$this._sourceServerId = sourceServerId;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  String? _bucketType;
  String? get bucketType => _$this._bucketType;
  set bucketType(String? bucketType) => _$this._bucketType = bucketType;

  String? _placeBindName;
  String? get placeBindName => _$this._placeBindName;
  set placeBindName(String? placeBindName) =>
      _$this._placeBindName = placeBindName;

  String? _placeBindId;
  String? get placeBindId => _$this._placeBindId;
  set placeBindId(String? placeBindId) => _$this._placeBindId = placeBindId;

  String? _decisionSource;
  String? get decisionSource => _$this._decisionSource;
  set decisionSource(String? decisionSource) =>
      _$this._decisionSource = decisionSource;

  bool? _manualLock;
  bool? get manualLock => _$this._manualLock;
  set manualLock(bool? manualLock) => _$this._manualLock = manualLock;

  num? _anchorLatitude;
  num? get anchorLatitude => _$this._anchorLatitude;
  set anchorLatitude(num? anchorLatitude) =>
      _$this._anchorLatitude = anchorLatitude;

  num? _anchorLongitude;
  num? get anchorLongitude => _$this._anchorLongitude;
  set anchorLongitude(num? anchorLongitude) =>
      _$this._anchorLongitude = anchorLongitude;

  String? _routeSegmentKey;
  String? get routeSegmentKey => _$this._routeSegmentKey;
  set routeSegmentKey(String? routeSegmentKey) =>
      _$this._routeSegmentKey = routeSegmentKey;

  num? _routeDistanceM;
  num? get routeDistanceM => _$this._routeDistanceM;
  set routeDistanceM(num? routeDistanceM) =>
      _$this._routeDistanceM = routeDistanceM;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _subtitle;
  String? get subtitle => _$this._subtitle;
  set subtitle(String? subtitle) => _$this._subtitle = subtitle;

  JsonObject? _renderPayloadJson;
  JsonObject? get renderPayloadJson => _$this._renderPayloadJson;
  set renderPayloadJson(JsonObject? renderPayloadJson) =>
      _$this._renderPayloadJson = renderPayloadJson;

  V2TimelineEntryResponseBuilder() {
    V2TimelineEntryResponse._defaults(this);
  }

  V2TimelineEntryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entryId = $v.entryId;
      _entryKind = $v.entryKind;
      _sourceServerId = $v.sourceServerId;
      _capturedAt = $v.capturedAt;
      _bucketType = $v.bucketType;
      _placeBindName = $v.placeBindName;
      _placeBindId = $v.placeBindId;
      _decisionSource = $v.decisionSource;
      _manualLock = $v.manualLock;
      _anchorLatitude = $v.anchorLatitude;
      _anchorLongitude = $v.anchorLongitude;
      _routeSegmentKey = $v.routeSegmentKey;
      _routeDistanceM = $v.routeDistanceM;
      _title = $v.title;
      _subtitle = $v.subtitle;
      _renderPayloadJson = $v.renderPayloadJson;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2TimelineEntryResponse other) {
    _$v = other as _$V2TimelineEntryResponse;
  }

  @override
  void update(void Function(V2TimelineEntryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2TimelineEntryResponse build() => _build();

  _$V2TimelineEntryResponse _build() {
    final _$result = _$v ??
        _$V2TimelineEntryResponse._(
          entryId: BuiltValueNullFieldError.checkNotNull(
              entryId, r'V2TimelineEntryResponse', 'entryId'),
          entryKind: BuiltValueNullFieldError.checkNotNull(
              entryKind, r'V2TimelineEntryResponse', 'entryKind'),
          sourceServerId: BuiltValueNullFieldError.checkNotNull(
              sourceServerId, r'V2TimelineEntryResponse', 'sourceServerId'),
          capturedAt: BuiltValueNullFieldError.checkNotNull(
              capturedAt, r'V2TimelineEntryResponse', 'capturedAt'),
          bucketType: BuiltValueNullFieldError.checkNotNull(
              bucketType, r'V2TimelineEntryResponse', 'bucketType'),
          placeBindName: placeBindName,
          placeBindId: placeBindId,
          decisionSource: decisionSource,
          manualLock: BuiltValueNullFieldError.checkNotNull(
              manualLock, r'V2TimelineEntryResponse', 'manualLock'),
          anchorLatitude: BuiltValueNullFieldError.checkNotNull(
              anchorLatitude, r'V2TimelineEntryResponse', 'anchorLatitude'),
          anchorLongitude: BuiltValueNullFieldError.checkNotNull(
              anchorLongitude, r'V2TimelineEntryResponse', 'anchorLongitude'),
          routeSegmentKey: routeSegmentKey,
          routeDistanceM: routeDistanceM,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'V2TimelineEntryResponse', 'title'),
          subtitle: subtitle,
          renderPayloadJson: renderPayloadJson,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
