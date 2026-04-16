// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_action_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdvisoryActionResponse extends AdvisoryActionResponse {
  @override
  final String id;
  @override
  final UserActionType action;
  @override
  final DateTime createdAt;

  factory _$AdvisoryActionResponse(
          [void Function(AdvisoryActionResponseBuilder)? updates]) =>
      (AdvisoryActionResponseBuilder()..update(updates))._build();

  _$AdvisoryActionResponse._(
      {required this.id, required this.action, required this.createdAt})
      : super._();
  @override
  AdvisoryActionResponse rebuild(
          void Function(AdvisoryActionResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdvisoryActionResponseBuilder toBuilder() =>
      AdvisoryActionResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdvisoryActionResponse &&
        id == other.id &&
        action == other.action &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdvisoryActionResponse')
          ..add('id', id)
          ..add('action', action)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class AdvisoryActionResponseBuilder
    implements Builder<AdvisoryActionResponse, AdvisoryActionResponseBuilder> {
  _$AdvisoryActionResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  UserActionType? _action;
  UserActionType? get action => _$this._action;
  set action(UserActionType? action) => _$this._action = action;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdvisoryActionResponseBuilder() {
    AdvisoryActionResponse._defaults(this);
  }

  AdvisoryActionResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _action = $v.action;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdvisoryActionResponse other) {
    _$v = other as _$AdvisoryActionResponse;
  }

  @override
  void update(void Function(AdvisoryActionResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdvisoryActionResponse build() => _build();

  _$AdvisoryActionResponse _build() {
    final _$result = _$v ??
        _$AdvisoryActionResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdvisoryActionResponse', 'id'),
          action: BuiltValueNullFieldError.checkNotNull(
              action, r'AdvisoryActionResponse', 'action'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AdvisoryActionResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
