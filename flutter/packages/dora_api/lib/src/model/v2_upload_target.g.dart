// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_upload_target.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2UploadTarget extends V2UploadTarget {
  @override
  final String clientMediaId;
  @override
  final String storageProvider;
  @override
  final String storageRef;
  @override
  final String bucket;
  @override
  final String objectKey;

  factory _$V2UploadTarget([void Function(V2UploadTargetBuilder)? updates]) =>
      (V2UploadTargetBuilder()..update(updates))._build();

  _$V2UploadTarget._(
      {required this.clientMediaId,
      required this.storageProvider,
      required this.storageRef,
      required this.bucket,
      required this.objectKey})
      : super._();
  @override
  V2UploadTarget rebuild(void Function(V2UploadTargetBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2UploadTargetBuilder toBuilder() => V2UploadTargetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2UploadTarget &&
        clientMediaId == other.clientMediaId &&
        storageProvider == other.storageProvider &&
        storageRef == other.storageRef &&
        bucket == other.bucket &&
        objectKey == other.objectKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, storageProvider.hashCode);
    _$hash = $jc(_$hash, storageRef.hashCode);
    _$hash = $jc(_$hash, bucket.hashCode);
    _$hash = $jc(_$hash, objectKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2UploadTarget')
          ..add('clientMediaId', clientMediaId)
          ..add('storageProvider', storageProvider)
          ..add('storageRef', storageRef)
          ..add('bucket', bucket)
          ..add('objectKey', objectKey))
        .toString();
  }
}

class V2UploadTargetBuilder
    implements Builder<V2UploadTarget, V2UploadTargetBuilder> {
  _$V2UploadTarget? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  String? _storageProvider;
  String? get storageProvider => _$this._storageProvider;
  set storageProvider(String? storageProvider) =>
      _$this._storageProvider = storageProvider;

  String? _storageRef;
  String? get storageRef => _$this._storageRef;
  set storageRef(String? storageRef) => _$this._storageRef = storageRef;

  String? _bucket;
  String? get bucket => _$this._bucket;
  set bucket(String? bucket) => _$this._bucket = bucket;

  String? _objectKey;
  String? get objectKey => _$this._objectKey;
  set objectKey(String? objectKey) => _$this._objectKey = objectKey;

  V2UploadTargetBuilder() {
    V2UploadTarget._defaults(this);
  }

  V2UploadTargetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _storageProvider = $v.storageProvider;
      _storageRef = $v.storageRef;
      _bucket = $v.bucket;
      _objectKey = $v.objectKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2UploadTarget other) {
    _$v = other as _$V2UploadTarget;
  }

  @override
  void update(void Function(V2UploadTargetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2UploadTarget build() => _build();

  _$V2UploadTarget _build() {
    final _$result = _$v ??
        _$V2UploadTarget._(
          clientMediaId: BuiltValueNullFieldError.checkNotNull(
              clientMediaId, r'V2UploadTarget', 'clientMediaId'),
          storageProvider: BuiltValueNullFieldError.checkNotNull(
              storageProvider, r'V2UploadTarget', 'storageProvider'),
          storageRef: BuiltValueNullFieldError.checkNotNull(
              storageRef, r'V2UploadTarget', 'storageRef'),
          bucket: BuiltValueNullFieldError.checkNotNull(
              bucket, r'V2UploadTarget', 'bucket'),
          objectKey: BuiltValueNullFieldError.checkNotNull(
              objectKey, r'V2UploadTarget', 'objectKey'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
