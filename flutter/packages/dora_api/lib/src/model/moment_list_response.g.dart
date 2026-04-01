// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MomentListResponse extends MomentListResponse {
  @override
  final BuiltList<MomentResponse> moments;
  @override
  final int total;

  factory _$MomentListResponse(
          [void Function(MomentListResponseBuilder)? updates]) =>
      (MomentListResponseBuilder()..update(updates))._build();

  _$MomentListResponse._({required this.moments, required this.total})
      : super._();
  @override
  MomentListResponse rebuild(
          void Function(MomentListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MomentListResponseBuilder toBuilder() =>
      MomentListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MomentListResponse &&
        moments == other.moments &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, moments.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MomentListResponse')
          ..add('moments', moments)
          ..add('total', total))
        .toString();
  }
}

class MomentListResponseBuilder
    implements Builder<MomentListResponse, MomentListResponseBuilder> {
  _$MomentListResponse? _$v;

  ListBuilder<MomentResponse>? _moments;
  ListBuilder<MomentResponse> get moments =>
      _$this._moments ??= ListBuilder<MomentResponse>();
  set moments(ListBuilder<MomentResponse>? moments) =>
      _$this._moments = moments;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  MomentListResponseBuilder() {
    MomentListResponse._defaults(this);
  }

  MomentListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _moments = $v.moments.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MomentListResponse other) {
    _$v = other as _$MomentListResponse;
  }

  @override
  void update(void Function(MomentListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MomentListResponse build() => _build();

  _$MomentListResponse _build() {
    _$MomentListResponse _$result;
    try {
      _$result = _$v ??
          _$MomentListResponse._(
            moments: moments.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'MomentListResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'moments';
        moments.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MomentListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
