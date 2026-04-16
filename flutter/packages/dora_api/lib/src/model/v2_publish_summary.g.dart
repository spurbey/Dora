// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_publish_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2PublishSummary extends V2PublishSummary {
  @override
  final String snapshotHash;
  @override
  final int? sessionCount;
  @override
  final int eventCount;
  @override
  final int mediaCount;
  @override
  final int pointCount;
  @override
  final int payloadBytes;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;

  factory _$V2PublishSummary(
          [void Function(V2PublishSummaryBuilder)? updates]) =>
      (V2PublishSummaryBuilder()..update(updates))._build();

  _$V2PublishSummary._(
      {required this.snapshotHash,
      this.sessionCount,
      required this.eventCount,
      required this.mediaCount,
      required this.pointCount,
      required this.payloadBytes,
      this.startedAt,
      this.endedAt})
      : super._();
  @override
  V2PublishSummary rebuild(void Function(V2PublishSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2PublishSummaryBuilder toBuilder() =>
      V2PublishSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2PublishSummary &&
        snapshotHash == other.snapshotHash &&
        sessionCount == other.sessionCount &&
        eventCount == other.eventCount &&
        mediaCount == other.mediaCount &&
        pointCount == other.pointCount &&
        payloadBytes == other.payloadBytes &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, snapshotHash.hashCode);
    _$hash = $jc(_$hash, sessionCount.hashCode);
    _$hash = $jc(_$hash, eventCount.hashCode);
    _$hash = $jc(_$hash, mediaCount.hashCode);
    _$hash = $jc(_$hash, pointCount.hashCode);
    _$hash = $jc(_$hash, payloadBytes.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2PublishSummary')
          ..add('snapshotHash', snapshotHash)
          ..add('sessionCount', sessionCount)
          ..add('eventCount', eventCount)
          ..add('mediaCount', mediaCount)
          ..add('pointCount', pointCount)
          ..add('payloadBytes', payloadBytes)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt))
        .toString();
  }
}

class V2PublishSummaryBuilder
    implements Builder<V2PublishSummary, V2PublishSummaryBuilder> {
  _$V2PublishSummary? _$v;

  String? _snapshotHash;
  String? get snapshotHash => _$this._snapshotHash;
  set snapshotHash(String? snapshotHash) => _$this._snapshotHash = snapshotHash;

  int? _sessionCount;
  int? get sessionCount => _$this._sessionCount;
  set sessionCount(int? sessionCount) => _$this._sessionCount = sessionCount;

  int? _eventCount;
  int? get eventCount => _$this._eventCount;
  set eventCount(int? eventCount) => _$this._eventCount = eventCount;

  int? _mediaCount;
  int? get mediaCount => _$this._mediaCount;
  set mediaCount(int? mediaCount) => _$this._mediaCount = mediaCount;

  int? _pointCount;
  int? get pointCount => _$this._pointCount;
  set pointCount(int? pointCount) => _$this._pointCount = pointCount;

  int? _payloadBytes;
  int? get payloadBytes => _$this._payloadBytes;
  set payloadBytes(int? payloadBytes) => _$this._payloadBytes = payloadBytes;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  V2PublishSummaryBuilder() {
    V2PublishSummary._defaults(this);
  }

  V2PublishSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _snapshotHash = $v.snapshotHash;
      _sessionCount = $v.sessionCount;
      _eventCount = $v.eventCount;
      _mediaCount = $v.mediaCount;
      _pointCount = $v.pointCount;
      _payloadBytes = $v.payloadBytes;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2PublishSummary other) {
    _$v = other as _$V2PublishSummary;
  }

  @override
  void update(void Function(V2PublishSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2PublishSummary build() => _build();

  _$V2PublishSummary _build() {
    final _$result = _$v ??
        _$V2PublishSummary._(
          snapshotHash: BuiltValueNullFieldError.checkNotNull(
              snapshotHash, r'V2PublishSummary', 'snapshotHash'),
          sessionCount: sessionCount,
          eventCount: BuiltValueNullFieldError.checkNotNull(
              eventCount, r'V2PublishSummary', 'eventCount'),
          mediaCount: BuiltValueNullFieldError.checkNotNull(
              mediaCount, r'V2PublishSummary', 'mediaCount'),
          pointCount: BuiltValueNullFieldError.checkNotNull(
              pointCount, r'V2PublishSummary', 'pointCount'),
          payloadBytes: BuiltValueNullFieldError.checkNotNull(
              payloadBytes, r'V2PublishSummary', 'payloadBytes'),
          startedAt: startedAt,
          endedAt: endedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
