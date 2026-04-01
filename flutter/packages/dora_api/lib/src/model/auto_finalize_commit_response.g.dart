// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_finalize_commit_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnum_planned =
    const AutoFinalizeCommitResponseStatusEnum._('planned');
const AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnum_trackingActive =
    const AutoFinalizeCommitResponseStatusEnum._('trackingActive');
const AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnum_trackingPaused =
    const AutoFinalizeCommitResponseStatusEnum._('trackingPaused');
const AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnum_reviewPending =
    const AutoFinalizeCommitResponseStatusEnum._('reviewPending');
const AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnum_completed =
    const AutoFinalizeCommitResponseStatusEnum._('completed');
const AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnum_shared =
    const AutoFinalizeCommitResponseStatusEnum._('shared');

AutoFinalizeCommitResponseStatusEnum
    _$autoFinalizeCommitResponseStatusEnumValueOf(String name) {
  switch (name) {
    case 'planned':
      return _$autoFinalizeCommitResponseStatusEnum_planned;
    case 'trackingActive':
      return _$autoFinalizeCommitResponseStatusEnum_trackingActive;
    case 'trackingPaused':
      return _$autoFinalizeCommitResponseStatusEnum_trackingPaused;
    case 'reviewPending':
      return _$autoFinalizeCommitResponseStatusEnum_reviewPending;
    case 'completed':
      return _$autoFinalizeCommitResponseStatusEnum_completed;
    case 'shared':
      return _$autoFinalizeCommitResponseStatusEnum_shared;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AutoFinalizeCommitResponseStatusEnum>
    _$autoFinalizeCommitResponseStatusEnumValues = BuiltSet<
        AutoFinalizeCommitResponseStatusEnum>(const <AutoFinalizeCommitResponseStatusEnum>[
  _$autoFinalizeCommitResponseStatusEnum_planned,
  _$autoFinalizeCommitResponseStatusEnum_trackingActive,
  _$autoFinalizeCommitResponseStatusEnum_trackingPaused,
  _$autoFinalizeCommitResponseStatusEnum_reviewPending,
  _$autoFinalizeCommitResponseStatusEnum_completed,
  _$autoFinalizeCommitResponseStatusEnum_shared,
]);

Serializer<AutoFinalizeCommitResponseStatusEnum>
    _$autoFinalizeCommitResponseStatusEnumSerializer =
    _$AutoFinalizeCommitResponseStatusEnumSerializer();

class _$AutoFinalizeCommitResponseStatusEnumSerializer
    implements PrimitiveSerializer<AutoFinalizeCommitResponseStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'planned': 'planned',
    'trackingActive': 'tracking_active',
    'trackingPaused': 'tracking_paused',
    'reviewPending': 'review_pending',
    'completed': 'completed',
    'shared': 'shared',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'planned': 'planned',
    'tracking_active': 'trackingActive',
    'tracking_paused': 'trackingPaused',
    'review_pending': 'reviewPending',
    'completed': 'completed',
    'shared': 'shared',
  };

  @override
  final Iterable<Type> types = const <Type>[
    AutoFinalizeCommitResponseStatusEnum
  ];
  @override
  final String wireName = 'AutoFinalizeCommitResponseStatusEnum';

  @override
  Object serialize(
          Serializers serializers, AutoFinalizeCommitResponseStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AutoFinalizeCommitResponseStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AutoFinalizeCommitResponseStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$AutoFinalizeCommitResponse extends AutoFinalizeCommitResponse {
  @override
  final String tripId;
  @override
  final AutoFinalizeCommitResponseStatusEnum status;
  @override
  final bool trackingEnabled;
  @override
  final DateTime? trackingStartedAt;
  @override
  final DateTime? trackingEndedAt;
  @override
  final bool idempotencyReplayed;

  factory _$AutoFinalizeCommitResponse(
          [void Function(AutoFinalizeCommitResponseBuilder)? updates]) =>
      (AutoFinalizeCommitResponseBuilder()..update(updates))._build();

  _$AutoFinalizeCommitResponse._(
      {required this.tripId,
      required this.status,
      required this.trackingEnabled,
      this.trackingStartedAt,
      this.trackingEndedAt,
      required this.idempotencyReplayed})
      : super._();
  @override
  AutoFinalizeCommitResponse rebuild(
          void Function(AutoFinalizeCommitResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AutoFinalizeCommitResponseBuilder toBuilder() =>
      AutoFinalizeCommitResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AutoFinalizeCommitResponse &&
        tripId == other.tripId &&
        status == other.status &&
        trackingEnabled == other.trackingEnabled &&
        trackingStartedAt == other.trackingStartedAt &&
        trackingEndedAt == other.trackingEndedAt &&
        idempotencyReplayed == other.idempotencyReplayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, trackingEnabled.hashCode);
    _$hash = $jc(_$hash, trackingStartedAt.hashCode);
    _$hash = $jc(_$hash, trackingEndedAt.hashCode);
    _$hash = $jc(_$hash, idempotencyReplayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AutoFinalizeCommitResponse')
          ..add('tripId', tripId)
          ..add('status', status)
          ..add('trackingEnabled', trackingEnabled)
          ..add('trackingStartedAt', trackingStartedAt)
          ..add('trackingEndedAt', trackingEndedAt)
          ..add('idempotencyReplayed', idempotencyReplayed))
        .toString();
  }
}

class AutoFinalizeCommitResponseBuilder
    implements
        Builder<AutoFinalizeCommitResponse, AutoFinalizeCommitResponseBuilder> {
  _$AutoFinalizeCommitResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  AutoFinalizeCommitResponseStatusEnum? _status;
  AutoFinalizeCommitResponseStatusEnum? get status => _$this._status;
  set status(AutoFinalizeCommitResponseStatusEnum? status) =>
      _$this._status = status;

  bool? _trackingEnabled;
  bool? get trackingEnabled => _$this._trackingEnabled;
  set trackingEnabled(bool? trackingEnabled) =>
      _$this._trackingEnabled = trackingEnabled;

  DateTime? _trackingStartedAt;
  DateTime? get trackingStartedAt => _$this._trackingStartedAt;
  set trackingStartedAt(DateTime? trackingStartedAt) =>
      _$this._trackingStartedAt = trackingStartedAt;

  DateTime? _trackingEndedAt;
  DateTime? get trackingEndedAt => _$this._trackingEndedAt;
  set trackingEndedAt(DateTime? trackingEndedAt) =>
      _$this._trackingEndedAt = trackingEndedAt;

  bool? _idempotencyReplayed;
  bool? get idempotencyReplayed => _$this._idempotencyReplayed;
  set idempotencyReplayed(bool? idempotencyReplayed) =>
      _$this._idempotencyReplayed = idempotencyReplayed;

  AutoFinalizeCommitResponseBuilder() {
    AutoFinalizeCommitResponse._defaults(this);
  }

  AutoFinalizeCommitResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _status = $v.status;
      _trackingEnabled = $v.trackingEnabled;
      _trackingStartedAt = $v.trackingStartedAt;
      _trackingEndedAt = $v.trackingEndedAt;
      _idempotencyReplayed = $v.idempotencyReplayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AutoFinalizeCommitResponse other) {
    _$v = other as _$AutoFinalizeCommitResponse;
  }

  @override
  void update(void Function(AutoFinalizeCommitResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AutoFinalizeCommitResponse build() => _build();

  _$AutoFinalizeCommitResponse _build() {
    final _$result = _$v ??
        _$AutoFinalizeCommitResponse._(
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'AutoFinalizeCommitResponse', 'tripId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'AutoFinalizeCommitResponse', 'status'),
          trackingEnabled: BuiltValueNullFieldError.checkNotNull(
              trackingEnabled,
              r'AutoFinalizeCommitResponse',
              'trackingEnabled'),
          trackingStartedAt: trackingStartedAt,
          trackingEndedAt: trackingEndedAt,
          idempotencyReplayed: BuiltValueNullFieldError.checkNotNull(
              idempotencyReplayed,
              r'AutoFinalizeCommitResponse',
              'idempotencyReplayed'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
