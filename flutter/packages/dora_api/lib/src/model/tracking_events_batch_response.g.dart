// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_events_batch_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingEventsBatchResponse extends TrackingEventsBatchResponse {
  @override
  final String tripId;
  @override
  final BuiltList<TrackingEventAcceptedResponse> accepted;
  @override
  final BuiltList<TrackingEventRejectedResponse> rejected;
  @override
  final int acceptedCount;
  @override
  final int rejectedCount;
  @override
  final bool idempotencyReplayed;

  factory _$TrackingEventsBatchResponse(
          [void Function(TrackingEventsBatchResponseBuilder)? updates]) =>
      (TrackingEventsBatchResponseBuilder()..update(updates))._build();

  _$TrackingEventsBatchResponse._(
      {required this.tripId,
      required this.accepted,
      required this.rejected,
      required this.acceptedCount,
      required this.rejectedCount,
      required this.idempotencyReplayed})
      : super._();
  @override
  TrackingEventsBatchResponse rebuild(
          void Function(TrackingEventsBatchResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingEventsBatchResponseBuilder toBuilder() =>
      TrackingEventsBatchResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingEventsBatchResponse &&
        tripId == other.tripId &&
        accepted == other.accepted &&
        rejected == other.rejected &&
        acceptedCount == other.acceptedCount &&
        rejectedCount == other.rejectedCount &&
        idempotencyReplayed == other.idempotencyReplayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, accepted.hashCode);
    _$hash = $jc(_$hash, rejected.hashCode);
    _$hash = $jc(_$hash, acceptedCount.hashCode);
    _$hash = $jc(_$hash, rejectedCount.hashCode);
    _$hash = $jc(_$hash, idempotencyReplayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingEventsBatchResponse')
          ..add('tripId', tripId)
          ..add('accepted', accepted)
          ..add('rejected', rejected)
          ..add('acceptedCount', acceptedCount)
          ..add('rejectedCount', rejectedCount)
          ..add('idempotencyReplayed', idempotencyReplayed))
        .toString();
  }
}

class TrackingEventsBatchResponseBuilder
    implements
        Builder<TrackingEventsBatchResponse,
            TrackingEventsBatchResponseBuilder> {
  _$TrackingEventsBatchResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  ListBuilder<TrackingEventAcceptedResponse>? _accepted;
  ListBuilder<TrackingEventAcceptedResponse> get accepted =>
      _$this._accepted ??= ListBuilder<TrackingEventAcceptedResponse>();
  set accepted(ListBuilder<TrackingEventAcceptedResponse>? accepted) =>
      _$this._accepted = accepted;

  ListBuilder<TrackingEventRejectedResponse>? _rejected;
  ListBuilder<TrackingEventRejectedResponse> get rejected =>
      _$this._rejected ??= ListBuilder<TrackingEventRejectedResponse>();
  set rejected(ListBuilder<TrackingEventRejectedResponse>? rejected) =>
      _$this._rejected = rejected;

  int? _acceptedCount;
  int? get acceptedCount => _$this._acceptedCount;
  set acceptedCount(int? acceptedCount) =>
      _$this._acceptedCount = acceptedCount;

  int? _rejectedCount;
  int? get rejectedCount => _$this._rejectedCount;
  set rejectedCount(int? rejectedCount) =>
      _$this._rejectedCount = rejectedCount;

  bool? _idempotencyReplayed;
  bool? get idempotencyReplayed => _$this._idempotencyReplayed;
  set idempotencyReplayed(bool? idempotencyReplayed) =>
      _$this._idempotencyReplayed = idempotencyReplayed;

  TrackingEventsBatchResponseBuilder() {
    TrackingEventsBatchResponse._defaults(this);
  }

  TrackingEventsBatchResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _accepted = $v.accepted.toBuilder();
      _rejected = $v.rejected.toBuilder();
      _acceptedCount = $v.acceptedCount;
      _rejectedCount = $v.rejectedCount;
      _idempotencyReplayed = $v.idempotencyReplayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingEventsBatchResponse other) {
    _$v = other as _$TrackingEventsBatchResponse;
  }

  @override
  void update(void Function(TrackingEventsBatchResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingEventsBatchResponse build() => _build();

  _$TrackingEventsBatchResponse _build() {
    _$TrackingEventsBatchResponse _$result;
    try {
      _$result = _$v ??
          _$TrackingEventsBatchResponse._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TrackingEventsBatchResponse', 'tripId'),
            accepted: accepted.build(),
            rejected: rejected.build(),
            acceptedCount: BuiltValueNullFieldError.checkNotNull(
                acceptedCount, r'TrackingEventsBatchResponse', 'acceptedCount'),
            rejectedCount: BuiltValueNullFieldError.checkNotNull(
                rejectedCount, r'TrackingEventsBatchResponse', 'rejectedCount'),
            idempotencyReplayed: BuiltValueNullFieldError.checkNotNull(
                idempotencyReplayed,
                r'TrackingEventsBatchResponse',
                'idempotencyReplayed'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'accepted';
        accepted.build();
        _$failedField = 'rejected';
        rejected.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingEventsBatchResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
