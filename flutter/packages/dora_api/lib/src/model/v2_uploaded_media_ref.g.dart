// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_uploaded_media_ref.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2UploadedMediaRef extends V2UploadedMediaRef {
  @override
  final String clientMediaId;
  @override
  final String storageRef;

  factory _$V2UploadedMediaRef(
          [void Function(V2UploadedMediaRefBuilder)? updates]) =>
      (V2UploadedMediaRefBuilder()..update(updates))._build();

  _$V2UploadedMediaRef._(
      {required this.clientMediaId, required this.storageRef})
      : super._();
  @override
  V2UploadedMediaRef rebuild(
          void Function(V2UploadedMediaRefBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2UploadedMediaRefBuilder toBuilder() =>
      V2UploadedMediaRefBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2UploadedMediaRef &&
        clientMediaId == other.clientMediaId &&
        storageRef == other.storageRef;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, storageRef.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2UploadedMediaRef')
          ..add('clientMediaId', clientMediaId)
          ..add('storageRef', storageRef))
        .toString();
  }
}

class V2UploadedMediaRefBuilder
    implements Builder<V2UploadedMediaRef, V2UploadedMediaRefBuilder> {
  _$V2UploadedMediaRef? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  String? _storageRef;
  String? get storageRef => _$this._storageRef;
  set storageRef(String? storageRef) => _$this._storageRef = storageRef;

  V2UploadedMediaRefBuilder() {
    V2UploadedMediaRef._defaults(this);
  }

  V2UploadedMediaRefBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _storageRef = $v.storageRef;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2UploadedMediaRef other) {
    _$v = other as _$V2UploadedMediaRef;
  }

  @override
  void update(void Function(V2UploadedMediaRefBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2UploadedMediaRef build() => _build();

  _$V2UploadedMediaRef _build() {
    final _$result = _$v ??
        _$V2UploadedMediaRef._(
          clientMediaId: BuiltValueNullFieldError.checkNotNull(
              clientMediaId, r'V2UploadedMediaRef', 'clientMediaId'),
          storageRef: BuiltValueNullFieldError.checkNotNull(
              storageRef, r'V2UploadedMediaRef', 'storageRef'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
