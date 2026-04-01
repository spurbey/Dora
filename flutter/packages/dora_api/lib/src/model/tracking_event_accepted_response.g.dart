// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_event_accepted_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingEventAcceptedResponse extends TrackingEventAcceptedResponse {
  @override
  final String clientEventId;
  @override
  final String eventId;
  @override
  final bool duplicate;

  factory _$TrackingEventAcceptedResponse(
          [void Function(TrackingEventAcceptedResponseBuilder)? updates]) =>
      (TrackingEventAcceptedResponseBuilder()..update(updates))._build();

  _$TrackingEventAcceptedResponse._(
      {required this.clientEventId,
      required this.eventId,
      required this.duplicate})
      : super._();
  @override
  TrackingEventAcceptedResponse rebuild(
          void Function(TrackingEventAcceptedResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingEventAcceptedResponseBuilder toBuilder() =>
      TrackingEventAcceptedResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingEventAcceptedResponse &&
        clientEventId == other.clientEventId &&
        eventId == other.eventId &&
        duplicate == other.duplicate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, eventId.hashCode);
    _$hash = $jc(_$hash, duplicate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingEventAcceptedResponse')
          ..add('clientEventId', clientEventId)
          ..add('eventId', eventId)
          ..add('duplicate', duplicate))
        .toString();
  }
}

class TrackingEventAcceptedResponseBuilder
    implements
        Builder<TrackingEventAcceptedResponse,
            TrackingEventAcceptedResponseBuilder> {
  _$TrackingEventAcceptedResponse? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  String? _eventId;
  String? get eventId => _$this._eventId;
  set eventId(String? eventId) => _$this._eventId = eventId;

  bool? _duplicate;
  bool? get duplicate => _$this._duplicate;
  set duplicate(bool? duplicate) => _$this._duplicate = duplicate;

  TrackingEventAcceptedResponseBuilder() {
    TrackingEventAcceptedResponse._defaults(this);
  }

  TrackingEventAcceptedResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _eventId = $v.eventId;
      _duplicate = $v.duplicate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingEventAcceptedResponse other) {
    _$v = other as _$TrackingEventAcceptedResponse;
  }

  @override
  void update(void Function(TrackingEventAcceptedResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingEventAcceptedResponse build() => _build();

  _$TrackingEventAcceptedResponse _build() {
    final _$result = _$v ??
        _$TrackingEventAcceptedResponse._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'TrackingEventAcceptedResponse', 'clientEventId'),
          eventId: BuiltValueNullFieldError.checkNotNull(
              eventId, r'TrackingEventAcceptedResponse', 'eventId'),
          duplicate: BuiltValueNullFieldError.checkNotNull(
              duplicate, r'TrackingEventAcceptedResponse', 'duplicate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
