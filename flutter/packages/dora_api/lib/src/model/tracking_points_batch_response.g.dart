// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_points_batch_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingPointsBatchResponse extends TrackingPointsBatchResponse {
  @override
  final String tripId;
  @override
  final String sessionId;
  @override
  final String clientBatchId;
  @override
  final int acceptedPoints;
  @override
  final int duplicatePoints;
  @override
  final String ingestJobId;
  @override
  final bool idempotencyReplayed;

  factory _$TrackingPointsBatchResponse(
          [void Function(TrackingPointsBatchResponseBuilder)? updates]) =>
      (TrackingPointsBatchResponseBuilder()..update(updates))._build();

  _$TrackingPointsBatchResponse._(
      {required this.tripId,
      required this.sessionId,
      required this.clientBatchId,
      required this.acceptedPoints,
      required this.duplicatePoints,
      required this.ingestJobId,
      required this.idempotencyReplayed})
      : super._();
  @override
  TrackingPointsBatchResponse rebuild(
          void Function(TrackingPointsBatchResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingPointsBatchResponseBuilder toBuilder() =>
      TrackingPointsBatchResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingPointsBatchResponse &&
        tripId == other.tripId &&
        sessionId == other.sessionId &&
        clientBatchId == other.clientBatchId &&
        acceptedPoints == other.acceptedPoints &&
        duplicatePoints == other.duplicatePoints &&
        ingestJobId == other.ingestJobId &&
        idempotencyReplayed == other.idempotencyReplayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, sessionId.hashCode);
    _$hash = $jc(_$hash, clientBatchId.hashCode);
    _$hash = $jc(_$hash, acceptedPoints.hashCode);
    _$hash = $jc(_$hash, duplicatePoints.hashCode);
    _$hash = $jc(_$hash, ingestJobId.hashCode);
    _$hash = $jc(_$hash, idempotencyReplayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingPointsBatchResponse')
          ..add('tripId', tripId)
          ..add('sessionId', sessionId)
          ..add('clientBatchId', clientBatchId)
          ..add('acceptedPoints', acceptedPoints)
          ..add('duplicatePoints', duplicatePoints)
          ..add('ingestJobId', ingestJobId)
          ..add('idempotencyReplayed', idempotencyReplayed))
        .toString();
  }
}

class TrackingPointsBatchResponseBuilder
    implements
        Builder<TrackingPointsBatchResponse,
            TrackingPointsBatchResponseBuilder> {
  _$TrackingPointsBatchResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _sessionId;
  String? get sessionId => _$this._sessionId;
  set sessionId(String? sessionId) => _$this._sessionId = sessionId;

  String? _clientBatchId;
  String? get clientBatchId => _$this._clientBatchId;
  set clientBatchId(String? clientBatchId) =>
      _$this._clientBatchId = clientBatchId;

  int? _acceptedPoints;
  int? get acceptedPoints => _$this._acceptedPoints;
  set acceptedPoints(int? acceptedPoints) =>
      _$this._acceptedPoints = acceptedPoints;

  int? _duplicatePoints;
  int? get duplicatePoints => _$this._duplicatePoints;
  set duplicatePoints(int? duplicatePoints) =>
      _$this._duplicatePoints = duplicatePoints;

  String? _ingestJobId;
  String? get ingestJobId => _$this._ingestJobId;
  set ingestJobId(String? ingestJobId) => _$this._ingestJobId = ingestJobId;

  bool? _idempotencyReplayed;
  bool? get idempotencyReplayed => _$this._idempotencyReplayed;
  set idempotencyReplayed(bool? idempotencyReplayed) =>
      _$this._idempotencyReplayed = idempotencyReplayed;

  TrackingPointsBatchResponseBuilder() {
    TrackingPointsBatchResponse._defaults(this);
  }

  TrackingPointsBatchResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _sessionId = $v.sessionId;
      _clientBatchId = $v.clientBatchId;
      _acceptedPoints = $v.acceptedPoints;
      _duplicatePoints = $v.duplicatePoints;
      _ingestJobId = $v.ingestJobId;
      _idempotencyReplayed = $v.idempotencyReplayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingPointsBatchResponse other) {
    _$v = other as _$TrackingPointsBatchResponse;
  }

  @override
  void update(void Function(TrackingPointsBatchResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingPointsBatchResponse build() => _build();

  _$TrackingPointsBatchResponse _build() {
    final _$result = _$v ??
        _$TrackingPointsBatchResponse._(
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'TrackingPointsBatchResponse', 'tripId'),
          sessionId: BuiltValueNullFieldError.checkNotNull(
              sessionId, r'TrackingPointsBatchResponse', 'sessionId'),
          clientBatchId: BuiltValueNullFieldError.checkNotNull(
              clientBatchId, r'TrackingPointsBatchResponse', 'clientBatchId'),
          acceptedPoints: BuiltValueNullFieldError.checkNotNull(
              acceptedPoints, r'TrackingPointsBatchResponse', 'acceptedPoints'),
          duplicatePoints: BuiltValueNullFieldError.checkNotNull(
              duplicatePoints,
              r'TrackingPointsBatchResponse',
              'duplicatePoints'),
          ingestJobId: BuiltValueNullFieldError.checkNotNull(
              ingestJobId, r'TrackingPointsBatchResponse', 'ingestJobId'),
          idempotencyReplayed: BuiltValueNullFieldError.checkNotNull(
              idempotencyReplayed,
              r'TrackingPointsBatchResponse',
              'idempotencyReplayed'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
