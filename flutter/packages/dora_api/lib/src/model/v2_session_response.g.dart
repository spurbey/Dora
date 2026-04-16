// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_session_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2SessionResponse extends V2SessionResponse {
  @override
  final String sessionServerId;
  @override
  final String tripId;
  @override
  final String clientSessionId;
  @override
  final String status;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final bool stopServerPending;
  @override
  final String? stopClientEventId;
  @override
  final int sealVersion;
  @override
  final String? timezone;
  @override
  final String? commitToken;

  factory _$V2SessionResponse(
          [void Function(V2SessionResponseBuilder)? updates]) =>
      (V2SessionResponseBuilder()..update(updates))._build();

  _$V2SessionResponse._(
      {required this.sessionServerId,
      required this.tripId,
      required this.clientSessionId,
      required this.status,
      required this.startedAt,
      this.endedAt,
      required this.stopServerPending,
      this.stopClientEventId,
      required this.sealVersion,
      this.timezone,
      this.commitToken})
      : super._();
  @override
  V2SessionResponse rebuild(void Function(V2SessionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2SessionResponseBuilder toBuilder() =>
      V2SessionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2SessionResponse &&
        sessionServerId == other.sessionServerId &&
        tripId == other.tripId &&
        clientSessionId == other.clientSessionId &&
        status == other.status &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        stopServerPending == other.stopServerPending &&
        stopClientEventId == other.stopClientEventId &&
        sealVersion == other.sealVersion &&
        timezone == other.timezone &&
        commitToken == other.commitToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sessionServerId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, clientSessionId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, stopServerPending.hashCode);
    _$hash = $jc(_$hash, stopClientEventId.hashCode);
    _$hash = $jc(_$hash, sealVersion.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, commitToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2SessionResponse')
          ..add('sessionServerId', sessionServerId)
          ..add('tripId', tripId)
          ..add('clientSessionId', clientSessionId)
          ..add('status', status)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('stopServerPending', stopServerPending)
          ..add('stopClientEventId', stopClientEventId)
          ..add('sealVersion', sealVersion)
          ..add('timezone', timezone)
          ..add('commitToken', commitToken))
        .toString();
  }
}

class V2SessionResponseBuilder
    implements Builder<V2SessionResponse, V2SessionResponseBuilder> {
  _$V2SessionResponse? _$v;

  String? _sessionServerId;
  String? get sessionServerId => _$this._sessionServerId;
  set sessionServerId(String? sessionServerId) =>
      _$this._sessionServerId = sessionServerId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _clientSessionId;
  String? get clientSessionId => _$this._clientSessionId;
  set clientSessionId(String? clientSessionId) =>
      _$this._clientSessionId = clientSessionId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  bool? _stopServerPending;
  bool? get stopServerPending => _$this._stopServerPending;
  set stopServerPending(bool? stopServerPending) =>
      _$this._stopServerPending = stopServerPending;

  String? _stopClientEventId;
  String? get stopClientEventId => _$this._stopClientEventId;
  set stopClientEventId(String? stopClientEventId) =>
      _$this._stopClientEventId = stopClientEventId;

  int? _sealVersion;
  int? get sealVersion => _$this._sealVersion;
  set sealVersion(int? sealVersion) => _$this._sealVersion = sealVersion;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  String? _commitToken;
  String? get commitToken => _$this._commitToken;
  set commitToken(String? commitToken) => _$this._commitToken = commitToken;

  V2SessionResponseBuilder() {
    V2SessionResponse._defaults(this);
  }

  V2SessionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sessionServerId = $v.sessionServerId;
      _tripId = $v.tripId;
      _clientSessionId = $v.clientSessionId;
      _status = $v.status;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _stopServerPending = $v.stopServerPending;
      _stopClientEventId = $v.stopClientEventId;
      _sealVersion = $v.sealVersion;
      _timezone = $v.timezone;
      _commitToken = $v.commitToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2SessionResponse other) {
    _$v = other as _$V2SessionResponse;
  }

  @override
  void update(void Function(V2SessionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2SessionResponse build() => _build();

  _$V2SessionResponse _build() {
    final _$result = _$v ??
        _$V2SessionResponse._(
          sessionServerId: BuiltValueNullFieldError.checkNotNull(
              sessionServerId, r'V2SessionResponse', 'sessionServerId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'V2SessionResponse', 'tripId'),
          clientSessionId: BuiltValueNullFieldError.checkNotNull(
              clientSessionId, r'V2SessionResponse', 'clientSessionId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'V2SessionResponse', 'status'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'V2SessionResponse', 'startedAt'),
          endedAt: endedAt,
          stopServerPending: BuiltValueNullFieldError.checkNotNull(
              stopServerPending, r'V2SessionResponse', 'stopServerPending'),
          stopClientEventId: stopClientEventId,
          sealVersion: BuiltValueNullFieldError.checkNotNull(
              sealVersion, r'V2SessionResponse', 'sealVersion'),
          timezone: timezone,
          commitToken: commitToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
