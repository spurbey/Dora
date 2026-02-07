// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_per_person.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BudgetPerPerson extends BudgetPerPerson {
  @override
  final AnyOf anyOf;

  factory _$BudgetPerPerson([void Function(BudgetPerPersonBuilder)? updates]) =>
      (BudgetPerPersonBuilder()..update(updates))._build();

  _$BudgetPerPerson._({required this.anyOf}) : super._();
  @override
  BudgetPerPerson rebuild(void Function(BudgetPerPersonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BudgetPerPersonBuilder toBuilder() => BudgetPerPersonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BudgetPerPerson && anyOf == other.anyOf;
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
    return (newBuiltValueToStringHelper(r'BudgetPerPerson')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class BudgetPerPersonBuilder
    implements Builder<BudgetPerPerson, BudgetPerPersonBuilder> {
  _$BudgetPerPerson? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  BudgetPerPersonBuilder() {
    BudgetPerPerson._defaults(this);
  }

  BudgetPerPersonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BudgetPerPerson other) {
    _$v = other as _$BudgetPerPerson;
  }

  @override
  void update(void Function(BudgetPerPersonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BudgetPerPerson build() => _build();

  _$BudgetPerPerson _build() {
    final _$result = _$v ??
        _$BudgetPerPerson._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'BudgetPerPerson', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
