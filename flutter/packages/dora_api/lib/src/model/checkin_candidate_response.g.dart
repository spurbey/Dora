// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkin_candidate_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CheckinCandidateResponseStatusEnum
    _$checkinCandidateResponseStatusEnum_pending =
    const CheckinCandidateResponseStatusEnum._('pending');
const CheckinCandidateResponseStatusEnum
    _$checkinCandidateResponseStatusEnum_confirmed =
    const CheckinCandidateResponseStatusEnum._('confirmed');
const CheckinCandidateResponseStatusEnum
    _$checkinCandidateResponseStatusEnum_rejected =
    const CheckinCandidateResponseStatusEnum._('rejected');
const CheckinCandidateResponseStatusEnum
    _$checkinCandidateResponseStatusEnum_snoozed =
    const CheckinCandidateResponseStatusEnum._('snoozed');
const CheckinCandidateResponseStatusEnum
    _$checkinCandidateResponseStatusEnum_expired =
    const CheckinCandidateResponseStatusEnum._('expired');

CheckinCandidateResponseStatusEnum _$checkinCandidateResponseStatusEnumValueOf(
    String name) {
  switch (name) {
    case 'pending':
      return _$checkinCandidateResponseStatusEnum_pending;
    case 'confirmed':
      return _$checkinCandidateResponseStatusEnum_confirmed;
    case 'rejected':
      return _$checkinCandidateResponseStatusEnum_rejected;
    case 'snoozed':
      return _$checkinCandidateResponseStatusEnum_snoozed;
    case 'expired':
      return _$checkinCandidateResponseStatusEnum_expired;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CheckinCandidateResponseStatusEnum>
    _$checkinCandidateResponseStatusEnumValues = BuiltSet<
        CheckinCandidateResponseStatusEnum>(const <CheckinCandidateResponseStatusEnum>[
  _$checkinCandidateResponseStatusEnum_pending,
  _$checkinCandidateResponseStatusEnum_confirmed,
  _$checkinCandidateResponseStatusEnum_rejected,
  _$checkinCandidateResponseStatusEnum_snoozed,
  _$checkinCandidateResponseStatusEnum_expired,
]);

Serializer<CheckinCandidateResponseStatusEnum>
    _$checkinCandidateResponseStatusEnumSerializer =
    _$CheckinCandidateResponseStatusEnumSerializer();

class _$CheckinCandidateResponseStatusEnumSerializer
    implements PrimitiveSerializer<CheckinCandidateResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'confirmed': 'confirmed',
    'rejected': 'rejected',
    'snoozed': 'snoozed',
    'expired': 'expired',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'confirmed': 'confirmed',
    'rejected': 'rejected',
    'snoozed': 'snoozed',
    'expired': 'expired',
  };

  @override
  final Iterable<Type> types = const <Type>[CheckinCandidateResponseStatusEnum];
  @override
  final String wireName = 'CheckinCandidateResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, CheckinCandidateResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CheckinCandidateResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CheckinCandidateResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CheckinCandidateResponse extends CheckinCandidateResponse {
  @override
  final String id;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final String? sessionId;
  @override
  final String fingerprint;
  @override
  final CheckinCandidateResponseStatusEnum status;
  @override
  final num confidence;
  @override
  final String? suggestedName;
  @override
  final num? suggestedLatitude;
  @override
  final num? suggestedLongitude;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final String? confirmedTripPlaceId;
  @override
  final String? rejectedReason;
  @override
  final DateTime? snoozedUntil;
  @override
  final DateTime? cooldownUntil;
  @override
  final BuiltMap<String, JsonObject?>? payload;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$CheckinCandidateResponse(
          [void Function(CheckinCandidateResponseBuilder)? updates]) =>
      (CheckinCandidateResponseBuilder()..update(updates))._build();

  _$CheckinCandidateResponse._(
      {required this.id,
      required this.tripId,
      required this.userId,
      this.sessionId,
      required this.fingerprint,
      required this.status,
      required this.confidence,
      this.suggestedName,
      this.suggestedLatitude,
      this.suggestedLongitude,
      this.startedAt,
      this.endedAt,
      this.confirmedTripPlaceId,
      this.rejectedReason,
      this.snoozedUntil,
      this.cooldownUntil,
      this.payload,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  CheckinCandidateResponse rebuild(
          void Function(CheckinCandidateResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckinCandidateResponseBuilder toBuilder() =>
      CheckinCandidateResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckinCandidateResponse &&
        id == other.id &&
        tripId == other.tripId &&
        userId == other.userId &&
        sessionId == other.sessionId &&
        fingerprint == other.fingerprint &&
        status == other.status &&
        confidence == other.confidence &&
        suggestedName == other.suggestedName &&
        suggestedLatitude == other.suggestedLatitude &&
        suggestedLongitude == other.suggestedLongitude &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        confirmedTripPlaceId == other.confirmedTripPlaceId &&
        rejectedReason == other.rejectedReason &&
        snoozedUntil == other.snoozedUntil &&
        cooldownUntil == other.cooldownUntil &&
        payload == other.payload &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, fingerprint.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, confidence.hashCode);
    _$hash = $jc(_$hash, suggestedName.hashCode);
    _$hash = $jc(_$hash, suggestedLatitude.hashCode);
    _$hash = $jc(_$hash, suggestedLongitude.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, confirmedTripPlaceId.hashCode);
    _$hash = $jc(_$hash, rejectedReason.hashCode);
    _$hash = $jc(_$hash, snoozedUntil.hashCode);
    _$hash = $jc(_$hash, cooldownUntil.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckinCandidateResponse')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('sessionId', sessionId)
          ..add('fingerprint', fingerprint)
          ..add('status', status)
          ..add('confidence', confidence)
          ..add('suggestedName', suggestedName)
          ..add('suggestedLatitude', suggestedLatitude)
          ..add('suggestedLongitude', suggestedLongitude)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('confirmedTripPlaceId', confirmedTripPlaceId)
          ..add('rejectedReason', rejectedReason)
          ..add('snoozedUntil', snoozedUntil)
          ..add('cooldownUntil', cooldownUntil)
          ..add('payload', payload)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CheckinCandidateResponseBuilder
    implements
        Builder<CheckinCandidateResponse, CheckinCandidateResponseBuilder> {
  _$CheckinCandidateResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _fingerprint;
  String? get fingerprint => _$this._fingerprint;
  set fingerprint(String? fingerprint) => _$this._fingerprint = fingerprint;

  CheckinCandidateResponseStatusEnum? _status;
  CheckinCandidateResponseStatusEnum? get status => _$this._status;
  set status(CheckinCandidateResponseStatusEnum? status) =>
      _$this._status = status;

  num? _confidence;
  num? get confidence => _$this._confidence;
  set confidence(num? confidence) => _$this._confidence = confidence;

  String? _suggestedName;
  String? get suggestedName => _$this._suggestedName;
  set suggestedName(String? suggestedName) =>
      _$this._suggestedName = suggestedName;

  num? _suggestedLatitude;
  num? get suggestedLatitude => _$this._suggestedLatitude;
  set suggestedLatitude(num? suggestedLatitude) =>
      _$this._suggestedLatitude = suggestedLatitude;

  num? _suggestedLongitude;
  num? get suggestedLongitude => _$this._suggestedLongitude;
  set suggestedLongitude(num? suggestedLongitude) =>
      _$this._suggestedLongitude = suggestedLongitude;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  String? _confirmedTripPlaceId;
  String? get confirmedTripPlaceId => _$this._confirmedTripPlaceId;
  set confirmedTripPlaceId(String? confirmedTripPlaceId) =>
      _$this._confirmedTripPlaceId = confirmedTripPlaceId;

  String? _rejectedReason;
  String? get rejectedReason => _$this._rejectedReason;
  set rejectedReason(String? rejectedReason) =>
      _$this._rejectedReason = rejectedReason;

  DateTime? _snoozedUntil;
  DateTime? get snoozedUntil => _$this._snoozedUntil;
  set snoozedUntil(DateTime? snoozedUntil) =>
      _$this._snoozedUntil = snoozedUntil;

  DateTime? _cooldownUntil;
  DateTime? get cooldownUntil => _$this._cooldownUntil;
  set cooldownUntil(DateTime? cooldownUntil) =>
      _$this._cooldownUntil = cooldownUntil;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CheckinCandidateResponseBuilder() {
    CheckinCandidateResponse._defaults(this);
  }

  CheckinCandidateResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _sessionId = $v.sessionId;
      _fingerprint = $v.fingerprint;
      _status = $v.status;
      _confidence = $v.confidence;
      _suggestedName = $v.suggestedName;
      _suggestedLatitude = $v.suggestedLatitude;
      _suggestedLongitude = $v.suggestedLongitude;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _confirmedTripPlaceId = $v.confirmedTripPlaceId;
      _rejectedReason = $v.rejectedReason;
      _snoozedUntil = $v.snoozedUntil;
      _cooldownUntil = $v.cooldownUntil;
      _payload = $v.payload?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckinCandidateResponse other) {
    _$v = other as _$CheckinCandidateResponse;
  }

  @override
  void update(void Function(CheckinCandidateResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckinCandidateResponse build() => _build();

  _$CheckinCandidateResponse _build() {
    _$CheckinCandidateResponse _$result;
    try {
      _$result = _$v ??
          _$CheckinCandidateResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'CheckinCandidateResponse', 'id'),
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'CheckinCandidateResponse', 'tripId'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'CheckinCandidateResponse', 'userId'),
            sessionId: sessionId,
            fingerprint: BuiltValueNullFieldError.checkNotNull(
                fingerprint, r'CheckinCandidateResponse', 'fingerprint'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'CheckinCandidateResponse', 'status'),
            confidence: BuiltValueNullFieldError.checkNotNull(
                confidence, r'CheckinCandidateResponse', 'confidence'),
            suggestedName: suggestedName,
            suggestedLatitude: suggestedLatitude,
            suggestedLongitude: suggestedLongitude,
            startedAt: startedAt,
            endedAt: endedAt,
            confirmedTripPlaceId: confirmedTripPlaceId,
            rejectedReason: rejectedReason,
            snoozedUntil: snoozedUntil,
            cooldownUntil: cooldownUntil,
            payload: _payload?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'CheckinCandidateResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'CheckinCandidateResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        _payload?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CheckinCandidateResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
