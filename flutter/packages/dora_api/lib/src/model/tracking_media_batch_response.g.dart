// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_media_batch_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingMediaBatchResponse extends TrackingMediaBatchResponse {
  @override
  final String tripId;
  @override
  final BuiltList<TrackingMediaAcceptedResponse> accepted;
  @override
  final BuiltList<TrackingMediaRejectedResponse> rejected;
  @override
  final int acceptedCount;
  @override
  final int rejectedCount;
  @override
  final bool idempotencyReplayed;

  factory _$TrackingMediaBatchResponse(
          [void Function(TrackingMediaBatchResponseBuilder)? updates]) =>
      (TrackingMediaBatchResponseBuilder()..update(updates))._build();

  _$TrackingMediaBatchResponse._(
      {required this.tripId,
      required this.accepted,
      required this.rejected,
      required this.acceptedCount,
      required this.rejectedCount,
      required this.idempotencyReplayed})
      : super._();
  @override
  TrackingMediaBatchResponse rebuild(
          void Function(TrackingMediaBatchResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingMediaBatchResponseBuilder toBuilder() =>
      TrackingMediaBatchResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingMediaBatchResponse &&
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
    return (newBuiltValueToStringHelper(r'TrackingMediaBatchResponse')
          ..add('tripId', tripId)
          ..add('accepted', accepted)
          ..add('rejected', rejected)
          ..add('acceptedCount', acceptedCount)
          ..add('rejectedCount', rejectedCount)
          ..add('idempotencyReplayed', idempotencyReplayed))
        .toString();
  }
}

class TrackingMediaBatchResponseBuilder
    implements
        Builder<TrackingMediaBatchResponse, TrackingMediaBatchResponseBuilder> {
  _$TrackingMediaBatchResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  ListBuilder<TrackingMediaAcceptedResponse>? _accepted;
  ListBuilder<TrackingMediaAcceptedResponse> get accepted =>
      _$this._accepted ??= ListBuilder<TrackingMediaAcceptedResponse>();
  set accepted(ListBuilder<TrackingMediaAcceptedResponse>? accepted) =>
      _$this._accepted = accepted;

  ListBuilder<TrackingMediaRejectedResponse>? _rejected;
  ListBuilder<TrackingMediaRejectedResponse> get rejected =>
      _$this._rejected ??= ListBuilder<TrackingMediaRejectedResponse>();
  set rejected(ListBuilder<TrackingMediaRejectedResponse>? rejected) =>
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

  TrackingMediaBatchResponseBuilder() {
    TrackingMediaBatchResponse._defaults(this);
  }

  TrackingMediaBatchResponseBuilder get _$this {
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
  void replace(TrackingMediaBatchResponse other) {
    _$v = other as _$TrackingMediaBatchResponse;
  }

  @override
  void update(void Function(TrackingMediaBatchResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingMediaBatchResponse build() => _build();

  _$TrackingMediaBatchResponse _build() {
    _$TrackingMediaBatchResponse _$result;
    try {
      _$result = _$v ??
          _$TrackingMediaBatchResponse._(
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'TrackingMediaBatchResponse', 'tripId'),
            accepted: accepted.build(),
            rejected: rejected.build(),
            acceptedCount: BuiltValueNullFieldError.checkNotNull(
                acceptedCount, r'TrackingMediaBatchResponse', 'acceptedCount'),
            rejectedCount: BuiltValueNullFieldError.checkNotNull(
                rejectedCount, r'TrackingMediaBatchResponse', 'rejectedCount'),
            idempotencyReplayed: BuiltValueNullFieldError.checkNotNull(
                idempotencyReplayed,
                r'TrackingMediaBatchResponse',
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
            r'TrackingMediaBatchResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
