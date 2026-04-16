// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const MomentResponseSource_Enum _$momentResponseSourceEnum_manual =
    const MomentResponseSource_Enum._('manual');
const MomentResponseSource_Enum _$momentResponseSourceEnum_auto =
    const MomentResponseSource_Enum._('auto');
const MomentResponseSource_Enum _$momentResponseSourceEnum_editedAuto =
    const MomentResponseSource_Enum._('editedAuto');

MomentResponseSource_Enum _$momentResponseSourceEnumValueOf(String name) {
  switch (name) {
    case 'manual':
      return _$momentResponseSourceEnum_manual;
    case 'auto':
      return _$momentResponseSourceEnum_auto;
    case 'editedAuto':
      return _$momentResponseSourceEnum_editedAuto;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<MomentResponseSource_Enum> _$momentResponseSourceEnumValues =
    BuiltSet<MomentResponseSource_Enum>(const <MomentResponseSource_Enum>[
  _$momentResponseSourceEnum_manual,
  _$momentResponseSourceEnum_auto,
  _$momentResponseSourceEnum_editedAuto,
]);

Serializer<MomentResponseSource_Enum> _$momentResponseSourceEnumSerializer =
    _$MomentResponseSource_EnumSerializer();

class _$MomentResponseSource_EnumSerializer
    implements PrimitiveSerializer<MomentResponseSource_Enum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'manual': 'manual',
    'auto': 'auto',
    'editedAuto': 'edited_auto',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'manual': 'manual',
    'auto': 'auto',
    'edited_auto': 'editedAuto',
  };

  @override
  final Iterable<Type> types = const <Type>[MomentResponseSource_Enum];
  @override
  final String wireName = 'MomentResponseSource_Enum';

  @override
  Object serialize(Serializers serializers, MomentResponseSource_Enum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  MomentResponseSource_Enum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      MomentResponseSource_Enum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$MomentResponse extends MomentResponse {
  @override
  final String id;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final String? candidateId;
  @override
  final String? linkedTripPlaceId;
  @override
  final MomentResponseSource_Enum source_;
  @override
  final num? confidence;
  @override
  final DateTime capturedAt;
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final String? note;
  @override
  final BuiltList<BuiltMap<String, JsonObject?>>? mediaRefs;
  @override
  final BuiltMap<String, JsonObject?>? extraPayload;
  @override
  final BuiltMap<String, JsonObject?>? lockedFields;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$MomentResponse([void Function(MomentResponseBuilder)? updates]) =>
      (MomentResponseBuilder()..update(updates))._build();

  _$MomentResponse._(
      {required this.id,
      required this.tripId,
      required this.userId,
      this.candidateId,
      this.linkedTripPlaceId,
      required this.source_,
      this.confidence,
      required this.capturedAt,
      this.latitude,
      this.longitude,
      this.note,
      this.mediaRefs,
      this.extraPayload,
      this.lockedFields,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  MomentResponse rebuild(void Function(MomentResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MomentResponseBuilder toBuilder() => MomentResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentResponse &&
        id == other.id &&
        tripId == other.tripId &&
        userId == other.userId &&
        candidateId == other.candidateId &&
        linkedTripPlaceId == other.linkedTripPlaceId &&
        source_ == other.source_ &&
        confidence == other.confidence &&
        capturedAt == other.capturedAt &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        note == other.note &&
        mediaRefs == other.mediaRefs &&
        extraPayload == other.extraPayload &&
        lockedFields == other.lockedFields &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, candidateId.hashCode);
    _$hash = $jc(_$hash, linkedTripPlaceId.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, mediaRefs.hashCode);
    _$hash = $jc(_$hash, extraPayload.hashCode);
    _$hash = $jc(_$hash, lockedFields.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentResponse')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('candidateId', candidateId)
          ..add('linkedTripPlaceId', linkedTripPlaceId)
          ..add('source_', source_)
          ..add('confidence', confidence)
          ..add('capturedAt', capturedAt)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('note', note)
          ..add('mediaRefs', mediaRefs)
          ..add('extraPayload', extraPayload)
          ..add('lockedFields', lockedFields)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class MomentResponseBuilder
    implements Builder<MomentResponse, MomentResponseBuilder> {
  _$MomentResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _candidateId;
  String? get candidateId => _$this._candidateId;
  set candidateId(String? candidateId) => _$this._candidateId = candidateId;

  String? _linkedTripPlaceId;
  String? get linkedTripPlaceId => _$this._linkedTripPlaceId;
  set linkedTripPlaceId(String? linkedTripPlaceId) =>
      _$this._linkedTripPlaceId = linkedTripPlaceId;

  MomentResponseSource_Enum? _source_;
  MomentResponseSource_Enum? get source_ => _$this._source_;
  set source_(MomentResponseSource_Enum? source_) => _$this._source_ = source_;

  num? _confidence;
  num? get confidence => _$this._confidence;
  set confidence(num? confidence) => _$this._confidence = confidence;

  DateTime? _capturedAt;
  DateTime? get capturedAt => _$this._capturedAt;
  set capturedAt(DateTime? capturedAt) => _$this._capturedAt = capturedAt;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<BuiltMap<String, JsonObject?>>? _mediaRefs;
  ListBuilder<BuiltMap<String, JsonObject?>> get mediaRefs =>
      _$this._mediaRefs ??= ListBuilder<BuiltMap<String, JsonObject?>>();
  set mediaRefs(ListBuilder<BuiltMap<String, JsonObject?>>? mediaRefs) =>
      _$this._mediaRefs = mediaRefs;

  MapBuilder<String, JsonObject?>? _extraPayload;
  MapBuilder<String, JsonObject?> get extraPayload =>
      _$this._extraPayload ??= MapBuilder<String, JsonObject?>();
  set extraPayload(MapBuilder<String, JsonObject?>? extraPayload) =>
      _$this._extraPayload = extraPayload;

  MapBuilder<String, JsonObject?>? _lockedFields;
  MapBuilder<String, JsonObject?> get lockedFields =>
      _$this._lockedFields ??= MapBuilder<String, JsonObject?>();
  set lockedFields(MapBuilder<String, JsonObject?>? lockedFields) =>
      _$this._lockedFields = lockedFields;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  MomentResponseBuilder() {
    MomentResponse._defaults(this);
  }

  MomentResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _candidateId = $v.candidateId;
      _linkedTripPlaceId = $v.linkedTripPlaceId;
      _source_ = $v.source_;
      _confidence = $v.confidence;
      _capturedAt = $v.capturedAt;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _note = $v.note;
      _mediaRefs = $v.mediaRefs?.toBuilder();
      _extraPayload = $v.extraPayload?.toBuilder();
      _lockedFields = $v.lockedFields?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentResponse other) {
    _$v = other as _$MomentResponse;
  }

  @override
  void update(void Function(MomentResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentResponse build() => _build();

  _$MomentResponse _build() {
    _$MomentResponse _$result;
    try {
      _$result = _$v ??
          _$MomentResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'MomentResponse', 'id'),
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'MomentResponse', 'tripId'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'MomentResponse', 'userId'),
            candidateId: candidateId,
            linkedTripPlaceId: linkedTripPlaceId,
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'MomentResponse', 'source_'),
            confidence: confidence,
            capturedAt: BuiltValueNullFieldError.checkNotNull(
                capturedAt, r'MomentResponse', 'capturedAt'),
            latitude: latitude,
            longitude: longitude,
            note: note,
            mediaRefs: _mediaRefs?.build(),
            extraPayload: _extraPayload?.build(),
            lockedFields: _lockedFields?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'MomentResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'MomentResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'mediaRefs';
        _mediaRefs?.build();
        _$failedField = 'extraPayload';
        _extraPayload?.build();
        _$failedField = 'lockedFields';
        _lockedFields?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MomentResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
