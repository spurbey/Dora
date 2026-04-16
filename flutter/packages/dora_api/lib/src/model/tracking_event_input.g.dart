// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_event_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingEventInput extends TrackingEventInput {
  @override
  final String clientEventId;
  @override
  final String eventType;
  @override
  final JsonObject? capturedAt;
  @override
  final String? sessionId;
  @override
  final String? note;
  @override
  final BuiltMap<String, JsonObject?>? location;
  @override
  final BuiltMap<String, JsonObject?>? payload;

  factory _$TrackingEventInput(
          [void Function(TrackingEventInputBuilder)? updates]) =>
      (TrackingEventInputBuilder()..update(updates))._build();

  _$TrackingEventInput._(
      {required this.clientEventId,
      required this.eventType,
      this.capturedAt,
      this.sessionId,
      this.note,
      this.location,
      this.payload})
      : super._();
  @override
  TrackingEventInput rebuild(
          void Function(TrackingEventInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingEventInputBuilder toBuilder() =>
      TrackingEventInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingEventInput &&
        clientEventId == other.clientEventId &&
        eventType == other.eventType &&
        capturedAt == other.capturedAt &&
        sessionId == other.sessionId &&
        note == other.note &&
        location == other.location &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, eventType.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingEventInput')
          ..add('clientEventId', clientEventId)
          ..add('eventType', eventType)
          ..add('capturedAt', capturedAt)
          ..add('sessionId', sessionId)
          ..add('note', note)
          ..add('location', location)
          ..add('payload', payload))
        .toString();
  }
}

class TrackingEventInputBuilder
    implements Builder<TrackingEventInput, TrackingEventInputBuilder> {
  _$TrackingEventInput? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _eventType;
  String? get eventType => _$this._eventType;
  set eventType(String? eventType) => _$this._eventType = eventType;

  JsonObject? _capturedAt;
  JsonObject? get capturedAt => _$this._capturedAt;
  set capturedAt(JsonObject? capturedAt) => _$this._capturedAt = capturedAt;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  MapBuilder<String, JsonObject?>? _location;
  MapBuilder<String, JsonObject?> get location =>
      _$this._location ??= MapBuilder<String, JsonObject?>();
  set location(MapBuilder<String, JsonObject?>? location) =>
      _$this._location = location;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  TrackingEventInputBuilder() {
    TrackingEventInput._defaults(this);
  }

  TrackingEventInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _eventType = $v.eventType;
      _capturedAt = $v.capturedAt;
      _sessionId = $v.sessionId;
      _note = $v.note;
      _location = $v.location?.toBuilder();
      _payload = $v.payload?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingEventInput other) {
    _$v = other as _$TrackingEventInput;
  }

  @override
  void update(void Function(TrackingEventInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingEventInput build() => _build();

  _$TrackingEventInput _build() {
    _$TrackingEventInput _$result;
    try {
      _$result = _$v ??
          _$TrackingEventInput._(
            clientEventId: BuiltValueNullFieldError.checkNotNull(
                clientEventId, r'TrackingEventInput', 'clientEventId'),
            eventType: BuiltValueNullFieldError.checkNotNull(
                eventType, r'TrackingEventInput', 'eventType'),
            capturedAt: capturedAt,
            sessionId: sessionId,
            note: note,
            location: _location?.build(),
            payload: _payload?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
        _$failedField = 'payload';
        _payload?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingEventInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
