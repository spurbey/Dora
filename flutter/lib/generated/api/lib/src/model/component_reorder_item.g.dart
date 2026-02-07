// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'component_reorder_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ComponentReorderItemComponentTypeEnum
    _$componentReorderItemComponentTypeEnum_place =
    const ComponentReorderItemComponentTypeEnum._('place');
const ComponentReorderItemComponentTypeEnum
    _$componentReorderItemComponentTypeEnum_route =
    const ComponentReorderItemComponentTypeEnum._('route');

ComponentReorderItemComponentTypeEnum
    _$componentReorderItemComponentTypeEnumValueOf(String name) {
  switch (name) {
    case 'place':
      return _$componentReorderItemComponentTypeEnum_place;
    case 'route':
      return _$componentReorderItemComponentTypeEnum_route;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ComponentReorderItemComponentTypeEnum>
    _$componentReorderItemComponentTypeEnumValues = BuiltSet<
        ComponentReorderItemComponentTypeEnum>(const <ComponentReorderItemComponentTypeEnum>[
  _$componentReorderItemComponentTypeEnum_place,
  _$componentReorderItemComponentTypeEnum_route,
]);

Serializer<ComponentReorderItemComponentTypeEnum>
    _$componentReorderItemComponentTypeEnumSerializer =
    _$ComponentReorderItemComponentTypeEnumSerializer();

class _$ComponentReorderItemComponentTypeEnumSerializer
    implements PrimitiveSerializer<ComponentReorderItemComponentTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'place': 'place',
    'route': 'route',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'place': 'place',
    'route': 'route',
  };

  @override
  final Iterable<Type> types = const <Type>[
    ComponentReorderItemComponentTypeEnum
  ];
  @override
  final String wireName = 'ComponentReorderItemComponentTypeEnum';

  @override
  Object serialize(
          Serializers serializers, ComponentReorderItemComponentTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ComponentReorderItemComponentTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ComponentReorderItemComponentTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$ComponentReorderItem extends ComponentReorderItem {
  @override
  final String id;
  @override
  final ComponentReorderItemComponentTypeEnum componentType;
  @override
  final int newOrder;

  factory _$ComponentReorderItem(
          [void Function(ComponentReorderItemBuilder)? updates]) =>
      (ComponentReorderItemBuilder()..update(updates))._build();

  _$ComponentReorderItem._(
      {required this.id, required this.componentType, required this.newOrder})
      : super._();
  @override
  ComponentReorderItem rebuild(
          void Function(ComponentReorderItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ComponentReorderItemBuilder toBuilder() =>
      ComponentReorderItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ComponentReorderItem &&
        id == other.id &&
        componentType == other.componentType &&
        newOrder == other.newOrder;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, componentType.hashCode);
    _$hash = $jc(_$hash, newOrder.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ComponentReorderItem')
          ..add('id', id)
          ..add('componentType', componentType)
          ..add('newOrder', newOrder))
        .toString();
  }
}

class ComponentReorderItemBuilder
    implements Builder<ComponentReorderItem, ComponentReorderItemBuilder> {
  _$ComponentReorderItem? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ComponentReorderItemComponentTypeEnum? _componentType;
  ComponentReorderItemComponentTypeEnum? get componentType =>
      _$this._componentType;
  set componentType(ComponentReorderItemComponentTypeEnum? componentType) =>
      _$this._componentType = componentType;

  int? _newOrder;
  int? get newOrder => _$this._newOrder;
  set newOrder(int? newOrder) => _$this._newOrder = newOrder;

  ComponentReorderItemBuilder() {
    ComponentReorderItem._defaults(this);
  }

  ComponentReorderItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _componentType = $v.componentType;
      _newOrder = $v.newOrder;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ComponentReorderItem other) {
    _$v = other as _$ComponentReorderItem;
  }

  @override
  void update(void Function(ComponentReorderItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ComponentReorderItem build() => _build();

  _$ComponentReorderItem _build() {
    final _$result = _$v ??
        _$ComponentReorderItem._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ComponentReorderItem', 'id'),
          componentType: BuiltValueNullFieldError.checkNotNull(
              componentType, r'ComponentReorderItem', 'componentType'),
          newOrder: BuiltValueNullFieldError.checkNotNull(
              newOrder, r'ComponentReorderItem', 'newOrder'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
