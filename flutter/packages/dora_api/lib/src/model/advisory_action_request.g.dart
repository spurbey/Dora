// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_action_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryActionRequest extends AdvisoryActionRequest {
  @override
  final UserActionType action;
  @override
  final BuiltMap<String, JsonObject?>? actionMetadata;

  factory _$AdvisoryActionRequest(
          [void Function(AdvisoryActionRequestBuilder)? updates]) =>
      (AdvisoryActionRequestBuilder()..update(updates))._build();

  _$AdvisoryActionRequest._({required this.action, this.actionMetadata})
      : super._();
  @override
  AdvisoryActionRequest rebuild(
          void Function(AdvisoryActionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryActionRequestBuilder toBuilder() =>
      AdvisoryActionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryActionRequest &&
        action == other.action &&
        actionMetadata == other.actionMetadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, actionMetadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryActionRequest')
          ..add('action', action)
          ..add('actionMetadata', actionMetadata))
        .toString();
  }
}

class AdvisoryActionRequestBuilder
    implements Builder<AdvisoryActionRequest, AdvisoryActionRequestBuilder> {
  _$AdvisoryActionRequest? _$v;

  UserActionType? _action;
  UserActionType? get action => _$this._action;
  set action(UserActionType? action) => _$this._action = action;

  MapBuilder<String, JsonObject?>? _actionMetadata;
  MapBuilder<String, JsonObject?> get actionMetadata =>
      _$this._actionMetadata ??= MapBuilder<String, JsonObject?>();
  set actionMetadata(MapBuilder<String, JsonObject?>? actionMetadata) =>
      _$this._actionMetadata = actionMetadata;

  AdvisoryActionRequestBuilder() {
    AdvisoryActionRequest._defaults(this);
  }

  AdvisoryActionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _action = $v.action;
      _actionMetadata = $v.actionMetadata?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryActionRequest other) {
    _$v = other as _$AdvisoryActionRequest;
  }

  @override
  void update(void Function(AdvisoryActionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryActionRequest build() => _build();

  _$AdvisoryActionRequest _build() {
    _$AdvisoryActionRequest _$result;
    try {
      _$result = _$v ??
          _$AdvisoryActionRequest._(
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'AdvisoryActionRequest', 'action'),
            actionMetadata: _actionMetadata?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'actionMetadata';
        _actionMetadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdvisoryActionRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
