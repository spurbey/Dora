// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_reorder_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ComponentReorderRequest extends ComponentReorderRequest {
  @override
  final BuiltList<ComponentReorderItem> items;

  factory _$ComponentReorderRequest(
          [void Function(ComponentReorderRequestBuilder)? updates]) =>
      (ComponentReorderRequestBuilder()..update(updates))._build();

  _$ComponentReorderRequest._({required this.items}) : super._();
  @override
  ComponentReorderRequest rebuild(
          void Function(ComponentReorderRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComponentReorderRequestBuilder toBuilder() =>
      ComponentReorderRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComponentReorderRequest && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComponentReorderRequest')
          ..add('items', items))
        .toString();
  }
}

class ComponentReorderRequestBuilder
    implements
        Builder<ComponentReorderRequest, ComponentReorderRequestBuilder> {
  _$ComponentReorderRequest? _$v;

  ListBuilder<ComponentReorderItem>? _items;
  ListBuilder<ComponentReorderItem> get items =>
      _$this._items ??= ListBuilder<ComponentReorderItem>();
  set items(ListBuilder<ComponentReorderItem>? items) => _$this._items = items;

  ComponentReorderRequestBuilder() {
    ComponentReorderRequest._defaults(this);
  }

  ComponentReorderRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComponentReorderRequest other) {
    _$v = other as _$ComponentReorderRequest;
  }

  @override
  void update(void Function(ComponentReorderRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComponentReorderRequest build() => _build();

  _$ComponentReorderRequest _build() {
    _$ComponentReorderRequest _$result;
    try {
      _$result = _$v ??
          _$ComponentReorderRequest._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ComponentReorderRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
