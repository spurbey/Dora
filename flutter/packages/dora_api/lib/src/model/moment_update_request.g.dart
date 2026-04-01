// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentUpdateRequest extends MomentUpdateRequest {
  @override
  final String clientEventId;
  @override
  final DateTime? capturedAt;
  @override
  final String? note;
  @override
  final MomentLocation? location;
  @override
  final BuiltList<JsonObject>? mediaRefs;
  @override
  final String? linkedTripPlaceId;
  @override
  final JsonObject? extraPayload;

  factory _$MomentUpdateRequest(
          [void Function(MomentUpdateRequestBuilder)? updates]) =>
      (MomentUpdateRequestBuilder()..update(updates))._build();

  _$MomentUpdateRequest._(
      {required this.clientEventId,
      this.capturedAt,
      this.note,
      this.location,
      this.mediaRefs,
      this.linkedTripPlaceId,
      this.extraPayload})
      : super._();
  @override
  MomentUpdateRequest rebuild(
          void Function(MomentUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MomentUpdateRequestBuilder toBuilder() =>
      MomentUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentUpdateRequest &&
        clientEventId == other.clientEventId &&
        capturedAt == other.capturedAt &&
        note == other.note &&
        location == other.location &&
        mediaRefs == other.mediaRefs &&
        linkedTripPlaceId == other.linkedTripPlaceId &&
        extraPayload == other.extraPayload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, mediaRefs.hashCode);
    _$hash = $jc(_$hash, linkedTripPlaceId.hashCode);
    _$hash = $jc(_$hash, extraPayload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentUpdateRequest')
          ..add('clientEventId', clientEventId)
          ..add('capturedAt', capturedAt)
          ..add('note', note)
          ..add('location', location)
          ..add('mediaRefs', mediaRefs)
          ..add('linkedTripPlaceId', linkedTripPlaceId)
          ..add('extraPayload', extraPayload))
        .toString();
  }
}

class MomentUpdateRequestBuilder
    implements Builder<MomentUpdateRequest, MomentUpdateRequestBuilder> {
  _$MomentUpdateRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  MomentLocationBuilder? _location;
  MomentLocationBuilder get location =>
      _$this._location ??= MomentLocationBuilder();
  set location(MomentLocationBuilder? location) => _$this._location = location;

  ListBuilder<JsonObject>? _mediaRefs;
  ListBuilder<JsonObject> get mediaRefs =>
      _$this._mediaRefs ??= ListBuilder<JsonObject>();
  set mediaRefs(ListBuilder<JsonObject>? mediaRefs) =>
      _$this._mediaRefs = mediaRefs;

  String? _linkedTripPlaceId;
  String? get linkedTripPlaceId => _$this._linkedTripPlaceId;
  set linkedTripPlaceId(String? linkedTripPlaceId) =>
      _$this._linkedTripPlaceId = linkedTripPlaceId;

  JsonObject? _extraPayload;
  JsonObject? get extraPayload => _$this._extraPayload;
  set extraPayload(JsonObject? extraPayload) =>
      _$this._extraPayload = extraPayload;

  MomentUpdateRequestBuilder() {
    MomentUpdateRequest._defaults(this);
  }

  MomentUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _capturedAt = $v.capturedAt;
      _note = $v.note;
      _location = $v.location?.toBuilder();
      _mediaRefs = $v.mediaRefs?.toBuilder();
      _linkedTripPlaceId = $v.linkedTripPlaceId;
      _extraPayload = $v.extraPayload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentUpdateRequest other) {
    _$v = other as _$MomentUpdateRequest;
  }

  @override
  void update(void Function(MomentUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentUpdateRequest build() => _build();

  _$MomentUpdateRequest _build() {
    _$MomentUpdateRequest _$result;
    try {
      _$result = _$v ??
          _$MomentUpdateRequest._(
            clientEventId: BuiltValueNullFieldError.checkNotNull(
                clientEventId, r'MomentUpdateRequest', 'clientEventId'),
            capturedAt: capturedAt,
            note: note,
            location: _location?.build(),
            mediaRefs: _mediaRefs?.build(),
            linkedTripPlaceId: linkedTripPlaceId,
            extraPayload: extraPayload,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
        _$failedField = 'mediaRefs';
        _mediaRefs?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MomentUpdateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
