// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_cancel_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExportCancelResponse extends ExportCancelResponse {
  @override
  final ExportStatus status;

  factory _$ExportCancelResponse(
          [void Function(ExportCancelResponseBuilder)? updates]) =>
      (ExportCancelResponseBuilder()..update(updates))._build();

  _$ExportCancelResponse._({required this.status}) : super._();
  @override
  ExportCancelResponse rebuild(
          void Function(ExportCancelResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExportCancelResponseBuilder toBuilder() =>
      ExportCancelResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExportCancelResponse && status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExportCancelResponse')
          ..add('status', status))
        .toString();
  }
}

class ExportCancelResponseBuilder
    implements Builder<ExportCancelResponse, ExportCancelResponseBuilder> {
  _$ExportCancelResponse? _$v;

  ExportStatus? _status;
  ExportStatus? get status => _$this._status;
  set status(ExportStatus? status) => _$this._status = status;

  ExportCancelResponseBuilder() {
    ExportCancelResponse._defaults(this);
  }

  ExportCancelResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExportCancelResponse other) {
    _$v = other as _$ExportCancelResponse;
  }

  @override
  void update(void Function(ExportCancelResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExportCancelResponse build() => _build();

  _$ExportCancelResponse _build() {
    final _$result = _$v ??
        _$ExportCancelResponse._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'ExportCancelResponse', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
