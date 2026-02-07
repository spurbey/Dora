// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_reorder_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ComponentReorderResponse extends ComponentReorderResponse {
  @override
  final String message;
  @override
  final int updatedCount;

  factory _$ComponentReorderResponse(
          [void Function(ComponentReorderResponseBuilder)? updates]) =>
      (ComponentReorderResponseBuilder()..update(updates))._build();

  _$ComponentReorderResponse._(
      {required this.message, required this.updatedCount})
      : super._();
  @override
  ComponentReorderResponse rebuild(
          void Function(ComponentReorderResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComponentReorderResponseBuilder toBuilder() =>
      ComponentReorderResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComponentReorderResponse &&
        message == other.message &&
        updatedCount == other.updatedCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, updatedCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComponentReorderResponse')
          ..add('message', message)
          ..add('updatedCount', updatedCount))
        .toString();
  }
}

class ComponentReorderResponseBuilder
    implements
        Builder<ComponentReorderResponse, ComponentReorderResponseBuilder> {
  _$ComponentReorderResponse? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  int? _updatedCount;
  int? get updatedCount => _$this._updatedCount;
  set updatedCount(int? updatedCount) => _$this._updatedCount = updatedCount;

  ComponentReorderResponseBuilder() {
    ComponentReorderResponse._defaults(this);
  }

  ComponentReorderResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _updatedCount = $v.updatedCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComponentReorderResponse other) {
    _$v = other as _$ComponentReorderResponse;
  }

  @override
  void update(void Function(ComponentReorderResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComponentReorderResponse build() => _build();

  _$ComponentReorderResponse _build() {
    final _$result = _$v ??
        _$ComponentReorderResponse._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'ComponentReorderResponse', 'message'),
          updatedCount: BuiltValueNullFieldError.checkNotNull(
              updatedCount, r'ComponentReorderResponse', 'updatedCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
