// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_session_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrackingSessionResponseStateEnum
    _$trackingSessionResponseStateEnum_active =
    const TrackingSessionResponseStateEnum._('active');
const TrackingSessionResponseStateEnum
    _$trackingSessionResponseStateEnum_paused =
    const TrackingSessionResponseStateEnum._('paused');
const TrackingSessionResponseStateEnum
    _$trackingSessionResponseStateEnum_ended =
    const TrackingSessionResponseStateEnum._('ended');
const TrackingSessionResponseStateEnum
    _$trackingSessionResponseStateEnum_abandoned =
    const TrackingSessionResponseStateEnum._('abandoned');

TrackingSessionResponseStateEnum _$trackingSessionResponseStateEnumValueOf(
    String name) {
  switch (name) {
    case 'active':
      return _$trackingSessionResponseStateEnum_active;
    case 'paused':
      return _$trackingSessionResponseStateEnum_paused;
    case 'ended':
      return _$trackingSessionResponseStateEnum_ended;
    case 'abandoned':
      return _$trackingSessionResponseStateEnum_abandoned;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackingSessionResponseStateEnum>
    _$trackingSessionResponseStateEnumValues = BuiltSet<
        TrackingSessionResponseStateEnum>(const <TrackingSessionResponseStateEnum>[
  _$trackingSessionResponseStateEnum_active,
  _$trackingSessionResponseStateEnum_paused,
  _$trackingSessionResponseStateEnum_ended,
  _$trackingSessionResponseStateEnum_abandoned,
]);

const TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnum_planned =
    const TrackingSessionResponseTripStatusEnum._('planned');
const TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnum_trackingActive =
    const TrackingSessionResponseTripStatusEnum._('trackingActive');
const TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnum_trackingPaused =
    const TrackingSessionResponseTripStatusEnum._('trackingPaused');
const TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnum_reviewPending =
    const TrackingSessionResponseTripStatusEnum._('reviewPending');
const TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnum_completed =
    const TrackingSessionResponseTripStatusEnum._('completed');
const TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnum_shared =
    const TrackingSessionResponseTripStatusEnum._('shared');

TrackingSessionResponseTripStatusEnum
    _$trackingSessionResponseTripStatusEnumValueOf(String name) {
  switch (name) {
    case 'planned':
      return _$trackingSessionResponseTripStatusEnum_planned;
    case 'trackingActive':
      return _$trackingSessionResponseTripStatusEnum_trackingActive;
    case 'trackingPaused':
      return _$trackingSessionResponseTripStatusEnum_trackingPaused;
    case 'reviewPending':
      return _$trackingSessionResponseTripStatusEnum_reviewPending;
    case 'completed':
      return _$trackingSessionResponseTripStatusEnum_completed;
    case 'shared':
      return _$trackingSessionResponseTripStatusEnum_shared;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackingSessionResponseTripStatusEnum>
    _$trackingSessionResponseTripStatusEnumValues = BuiltSet<
        TrackingSessionResponseTripStatusEnum>(const <TrackingSessionResponseTripStatusEnum>[
  _$trackingSessionResponseTripStatusEnum_planned,
  _$trackingSessionResponseTripStatusEnum_trackingActive,
  _$trackingSessionResponseTripStatusEnum_trackingPaused,
  _$trackingSessionResponseTripStatusEnum_reviewPending,
  _$trackingSessionResponseTripStatusEnum_completed,
  _$trackingSessionResponseTripStatusEnum_shared,
]);

Serializer<TrackingSessionResponseStateEnum>
    _$trackingSessionResponseStateEnumSerializer =
    _$TrackingSessionResponseStateEnumSerializer();
Serializer<TrackingSessionResponseTripStatusEnum>
    _$trackingSessionResponseTripStatusEnumSerializer =
    _$TrackingSessionResponseTripStatusEnumSerializer();

class _$TrackingSessionResponseStateEnumSerializer
    implements PrimitiveSerializer<TrackingSessionResponseStateEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'paused': 'paused',
    'ended': 'ended',
    'abandoned': 'abandoned',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'paused': 'paused',
    'ended': 'ended',
    'abandoned': 'abandoned',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackingSessionResponseStateEnum];
  @override
  final String wireName = 'TrackingSessionResponseStateEnum';

  @override
  Object serialize(
          Serializers serializers, TrackingSessionResponseStateEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackingSessionResponseStateEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackingSessionResponseStateEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackingSessionResponseTripStatusEnumSerializer
    implements PrimitiveSerializer<TrackingSessionResponseTripStatusEnum> {
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
    TrackingSessionResponseTripStatusEnum
  ];
  @override
  final String wireName = 'TrackingSessionResponseTripStatusEnum';

  @override
  Object serialize(
          Serializers serializers, TrackingSessionResponseTripStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackingSessionResponseTripStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackingSessionResponseTripStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackingSessionResponse extends TrackingSessionResponse {
  @override
  final String sessionId;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final TrackingSessionResponseStateEnum state;
  @override
  final String clientSessionId;
  @override
  final DateTime startedAt;
  @override
  final DateTime? pausedAt;
  @override
  final DateTime? resumedAt;
  @override
  final DateTime? endedAt;
  @override
  final DateTime? abandonedAt;
  @override
  final DateTime? lastPointAt;
  @override
  final String? timezone;
  @override
  final BuiltMap<String, JsonObject?>? deviceContext;
  @override
  final TrackingSessionResponseTripStatusEnum tripStatus;
  @override
  final bool trackingEnabled;
  @override
  final DateTime? trackingStartedAt;
  @override
  final DateTime? trackingEndedAt;

  factory _$TrackingSessionResponse(
          [void Function(TrackingSessionResponseBuilder)? updates]) =>
      (TrackingSessionResponseBuilder()..update(updates))._build();

  _$TrackingSessionResponse._(
      {required this.sessionId,
      required this.tripId,
      required this.userId,
      required this.state,
      required this.clientSessionId,
      required this.startedAt,
      this.pausedAt,
      this.resumedAt,
      this.endedAt,
      this.abandonedAt,
      this.lastPointAt,
      this.timezone,
      this.deviceContext,
      required this.tripStatus,
      required this.trackingEnabled,
      this.trackingStartedAt,
      this.trackingEndedAt})
      : super._();
  @override
  TrackingSessionResponse rebuild(
          void Function(TrackingSessionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingSessionResponseBuilder toBuilder() =>
      TrackingSessionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingSessionResponse &&
        sessionId == other.sessionId &&
        tripId == other.tripId &&
        userId == other.userId &&
        state == other.state &&
        clientSessionId == other.clientSessionId &&
        startedAt == other.startedAt &&
        pausedAt == other.pausedAt &&
        resumedAt == other.resumedAt &&
        endedAt == other.endedAt &&
        abandonedAt == other.abandonedAt &&
        lastPointAt == other.lastPointAt &&
        timezone == other.timezone &&
        deviceContext == other.deviceContext &&
        tripStatus == other.tripStatus &&
        trackingEnabled == other.trackingEnabled &&
        trackingStartedAt == other.trackingStartedAt &&
        trackingEndedAt == other.trackingEndedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, state.hashCode);
    _$hash = $jc(_$hash, clientSessionId.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, pausedAt.hashCode);
    _$hash = $jc(_$hash, resumedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, abandonedAt.hashCode);
    _$hash = $jc(_$hash, lastPointAt.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, deviceContext.hashCode);
    _$hash = $jc(_$hash, tripStatus.hashCode);
    _$hash = $jc(_$hash, trackingEnabled.hashCode);
    _$hash = $jc(_$hash, trackingStartedAt.hashCode);
    _$hash = $jc(_$hash, trackingEndedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingSessionResponse')
          ..add('sessionId', sessionId)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('state', state)
          ..add('clientSessionId', clientSessionId)
          ..add('startedAt', startedAt)
          ..add('pausedAt', pausedAt)
          ..add('resumedAt', resumedAt)
          ..add('endedAt', endedAt)
          ..add('abandonedAt', abandonedAt)
          ..add('lastPointAt', lastPointAt)
          ..add('timezone', timezone)
          ..add('deviceContext', deviceContext)
          ..add('tripStatus', tripStatus)
          ..add('trackingEnabled', trackingEnabled)
          ..add('trackingStartedAt', trackingStartedAt)
          ..add('trackingEndedAt', trackingEndedAt))
        .toString();
  }
}

class TrackingSessionResponseBuilder
    implements
        Builder<TrackingSessionResponse, TrackingSessionResponseBuilder> {
  _$TrackingSessionResponse? _$v;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  TrackingSessionResponseStateEnum? _state;
  TrackingSessionResponseStateEnum? get state => _$this._state;
  set state(TrackingSessionResponseStateEnum? state) => _$this._state = state;

  String? _clientSessionId;
  String? get clientSessionId => _$this._clientSessionId;
  set clientSessionId(String? clientSessionId) =>
      _$this._clientSessionId = clientSessionId;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _pausedAt;
  DateTime? get pausedAt => _$this._pausedAt;
  set pausedAt(DateTime? pausedAt) => _$this._pausedAt = pausedAt;

  DateTime? _resumedAt;
  DateTime? get resumedAt => _$this._resumedAt;
  set resumedAt(DateTime? resumedAt) => _$this._resumedAt = resumedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  DateTime? _abandonedAt;
  DateTime? get abandonedAt => _$this._abandonedAt;
  set abandonedAt(DateTime? abandonedAt) => _$this._abandonedAt = abandonedAt;

  DateTime? _lastPointAt;
  DateTime? get lastPointAt => _$this._lastPointAt;
  set lastPointAt(DateTime? lastPointAt) => _$this._lastPointAt = lastPointAt;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  MapBuilder<String, JsonObject?>? _deviceContext;
  MapBuilder<String, JsonObject?> get deviceContext =>
      _$this._deviceContext ??= MapBuilder<String, JsonObject?>();
  set deviceContext(MapBuilder<String, JsonObject?>? deviceContext) =>
      _$this._deviceContext = deviceContext;

  TrackingSessionResponseTripStatusEnum? _tripStatus;
  TrackingSessionResponseTripStatusEnum? get tripStatus => _$this._tripStatus;
  set tripStatus(TrackingSessionResponseTripStatusEnum? tripStatus) =>
      _$this._tripStatus = tripStatus;

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

  TrackingSessionResponseBuilder() {
    TrackingSessionResponse._defaults(this);
  }

  TrackingSessionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionId = $v.sessionId;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _state = $v.state;
      _clientSessionId = $v.clientSessionId;
      _startedAt = $v.startedAt;
      _pausedAt = $v.pausedAt;
      _resumedAt = $v.resumedAt;
      _endedAt = $v.endedAt;
      _abandonedAt = $v.abandonedAt;
      _lastPointAt = $v.lastPointAt;
      _timezone = $v.timezone;
      _deviceContext = $v.deviceContext?.toBuilder();
      _tripStatus = $v.tripStatus;
      _trackingEnabled = $v.trackingEnabled;
      _trackingStartedAt = $v.trackingStartedAt;
      _trackingEndedAt = $v.trackingEndedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingSessionResponse other) {
    _$v = other as _$TrackingSessionResponse;
  }

  @override
  void update(void Function(TrackingSessionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingSessionResponse build() => _build();

  _$TrackingSessionResponse _build() {
    _$TrackingSessionResponse _$result;
    try {
      _$result = _$v ??
          _$TrackingSessionResponse._(
            sessionId: BuiltValueNullFieldError.checkNotNull(
                sessionId, r'TrackingSessionResponse', 'sessionId'),
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TrackingSessionResponse', 'tripId'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'TrackingSessionResponse', 'userId'),
            state: BuiltValueNullFieldError.checkNotNull(
                state, r'TrackingSessionResponse', 'state'),
            clientSessionId: BuiltValueNullFieldError.checkNotNull(
                clientSessionId, r'TrackingSessionResponse', 'clientSessionId'),
            startedAt: BuiltValueNullFieldError.checkNotNull(
                startedAt, r'TrackingSessionResponse', 'startedAt'),
            pausedAt: pausedAt,
            resumedAt: resumedAt,
            endedAt: endedAt,
            abandonedAt: abandonedAt,
            lastPointAt: lastPointAt,
            timezone: timezone,
            deviceContext: _deviceContext?.build(),
            tripStatus: BuiltValueNullFieldError.checkNotNull(
                tripStatus, r'TrackingSessionResponse', 'tripStatus'),
            trackingEnabled: BuiltValueNullFieldError.checkNotNull(
                trackingEnabled, r'TrackingSessionResponse', 'trackingEnabled'),
            trackingStartedAt: trackingStartedAt,
            trackingEndedAt: trackingEndedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deviceContext';
        _deviceContext?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingSessionResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
