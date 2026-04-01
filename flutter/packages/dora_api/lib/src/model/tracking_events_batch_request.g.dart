// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_events_batch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingEventsBatchRequest extends TrackingEventsBatchRequest {
  @override
  final BuiltList<TrackingEventInput>? events;

  factory _$TrackingEventsBatchRequest(
          [void Function(TrackingEventsBatchRequestBuilder)? updates]) =>
      (TrackingEventsBatchRequestBuilder()..update(updates))._build();

  _$TrackingEventsBatchRequest._({this.events}) : super._();
  @override
  TrackingEventsBatchRequest rebuild(
          void Function(TrackingEventsBatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingEventsBatchRequestBuilder toBuilder() =>
      TrackingEventsBatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingEventsBatchRequest && events == other.events;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingEventsBatchRequest')
          ..add('events', events))
        .toString();
  }
}

class TrackingEventsBatchRequestBuilder
    implements
        Builder<TrackingEventsBatchRequest, TrackingEventsBatchRequestBuilder> {
  _$TrackingEventsBatchRequest? _$v;

  ListBuilder<TrackingEventInput>? _events;
  ListBuilder<TrackingEventInput> get events =>
      _$this._events ??= ListBuilder<TrackingEventInput>();
  set events(ListBuilder<TrackingEventInput>? events) =>
      _$this._events = events;

  TrackingEventsBatchRequestBuilder() {
    TrackingEventsBatchRequest._defaults(this);
  }

  TrackingEventsBatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _events = $v.events?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingEventsBatchRequest other) {
    _$v = other as _$TrackingEventsBatchRequest;
  }

  @override
  void update(void Function(TrackingEventsBatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingEventsBatchRequest build() => _build();

  _$TrackingEventsBatchRequest _build() {
    _$TrackingEventsBatchRequest _$result;
    try {
      _$result = _$v ??
          _$TrackingEventsBatchRequest._(
            events: _events?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'events';
        _events?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingEventsBatchRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
