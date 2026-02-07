// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_cost.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FuelCost extends FuelCost {
  @override
  final AnyOf anyOf;

  factory _$FuelCost([void Function(FuelCostBuilder)? updates]) =>
      (FuelCostBuilder()..update(updates))._build();

  _$FuelCost._({required this.anyOf}) : super._();
  @override
  FuelCost rebuild(void Function(FuelCostBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FuelCostBuilder toBuilder() => FuelCostBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FuelCost && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'FuelCost')..add('anyOf', anyOf))
        .toString();
  }
}

class FuelCostBuilder implements Builder<FuelCost, FuelCostBuilder> {
  _$FuelCost? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  FuelCostBuilder() {
    FuelCost._defaults(this);
  }

  FuelCostBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FuelCost other) {
    _$v = other as _$FuelCost;
  }

  @override
  void update(void Function(FuelCostBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FuelCost build() => _build();

  _$FuelCost _build() {
    final _$result = _$v ??
        _$FuelCost._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'FuelCost', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
