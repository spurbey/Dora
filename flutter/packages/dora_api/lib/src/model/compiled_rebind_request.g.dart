// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compiled_rebind_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompiledRebindRequest extends CompiledRebindRequest {
  @override
  final String? sourceEventId;
  @override
  final String? sourceMediaId;
  @override
  final String? sourceKind;
  @override
  final String action;
  @override
  final String? tripPlaceId;

  factory _$CompiledRebindRequest(
          [void Function(CompiledRebindRequestBuilder)? updates]) =>
      (CompiledRebindRequestBuilder()..update(updates))._build();

  _$CompiledRebindRequest._(
      {this.sourceEventId,
      this.sourceMediaId,
      this.sourceKind,
      required this.action,
      this.tripPlaceId})
      : super._();
  @override
  CompiledRebindRequest rebuild(
          void Function(CompiledRebindRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompiledRebindRequestBuilder toBuilder() =>
      CompiledRebindRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompiledRebindRequest &&
        sourceEventId == other.sourceEventId &&
        sourceMediaId == other.sourceMediaId &&
        sourceKind == other.sourceKind &&
        action == other.action &&
        tripPlaceId == other.tripPlaceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, sourceEventId.hashCode);
    _$hash = $jc(_$hash, sourceMediaId.hashCode);
    _$hash = $jc(_$hash, sourceKind.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, tripPlaceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompiledRebindRequest')
          ..add('sourceEventId', sourceEventId)
          ..add('sourceMediaId', sourceMediaId)
          ..add('sourceKind', sourceKind)
          ..add('action', action)
          ..add('tripPlaceId', tripPlaceId))
        .toString();
  }
}

class CompiledRebindRequestBuilder
    implements Builder<CompiledRebindRequest, CompiledRebindRequestBuilder> {
  _$CompiledRebindRequest? _$v;

  String? _sourceEventId;
  String? get sourceEventId => _$this._sourceEventId;
  set sourceEventId(String? sourceEventId) =>
      _$this._sourceEventId = sourceEventId;

  String? _sourceMediaId;
  String? get sourceMediaId => _$this._sourceMediaId;
  set sourceMediaId(String? sourceMediaId) =>
      _$this._sourceMediaId = sourceMediaId;

  String? _sourceKind;
  String? get sourceKind => _$this._sourceKind;
  set sourceKind(String? sourceKind) => _$this._sourceKind = sourceKind;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _tripPlaceId;
  String? get tripPlaceId => _$this._tripPlaceId;
  set tripPlaceId(String? tripPlaceId) => _$this._tripPlaceId = tripPlaceId;

  CompiledRebindRequestBuilder() {
    CompiledRebindRequest._defaults(this);
  }

  CompiledRebindRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _sourceEventId = $v.sourceEventId;
      _sourceMediaId = $v.sourceMediaId;
      _sourceKind = $v.sourceKind;
      _action = $v.action;
      _tripPlaceId = $v.tripPlaceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompiledRebindRequest other) {
    _$v = other as _$CompiledRebindRequest;
  }

  @override
  void update(void Function(CompiledRebindRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompiledRebindRequest build() => _build();

  _$CompiledRebindRequest _build() {
    final _$result = _$v ??
        _$CompiledRebindRequest._(
          sourceEventId: sourceEventId,
          sourceMediaId: sourceMediaId,
          sourceKind: sourceKind,
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'CompiledRebindRequest', 'action'),
          tripPlaceId: tripPlaceId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
