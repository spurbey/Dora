// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toll_cost.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TollCost extends TollCost {
  @override
  final AnyOf anyOf;

  factory _$TollCost([void Function(TollCostBuilder)? updates]) =>
      (TollCostBuilder()..update(updates))._build();

  _$TollCost._({required this.anyOf}) : super._();
  @override
  TollCost rebuild(void Function(TollCostBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TollCostBuilder toBuilder() => TollCostBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TollCost && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TollCost')..add('anyOf', anyOf))
        .toString();
  }
}

class TollCostBuilder implements Builder<TollCost, TollCostBuilder> {
  _$TollCost? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  TollCostBuilder() {
    TollCost._defaults(this);
  }

  TollCostBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TollCost other) {
    _$v = other as _$TollCost;
  }

  @override
  void update(void Function(TollCostBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TollCost build() => _build();

  _$TollCost _build() {
    final _$result = _$v ??
        _$TollCost._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'TollCost', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
