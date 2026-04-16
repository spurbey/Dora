// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_media_manifest_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2MediaManifestItem extends V2MediaManifestItem {
  @override
  final String clientMediaId;
  @override
  final String? mimeType;
  @override
  final int? sizeBytes;
  @override
  final String mediaContentHash;

  factory _$V2MediaManifestItem(
          [void Function(V2MediaManifestItemBuilder)? updates]) =>
      (V2MediaManifestItemBuilder()..update(updates))._build();

  _$V2MediaManifestItem._(
      {required this.clientMediaId,
      this.mimeType,
      this.sizeBytes,
      required this.mediaContentHash})
      : super._();
  @override
  V2MediaManifestItem rebuild(
          void Function(V2MediaManifestItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2MediaManifestItemBuilder toBuilder() =>
      V2MediaManifestItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2MediaManifestItem &&
        clientMediaId == other.clientMediaId &&
        mimeType == other.mimeType &&
        sizeBytes == other.sizeBytes &&
        mediaContentHash == other.mediaContentHash;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, mimeType.hashCode);
    _$hash = $jc(_$hash, sizeBytes.hashCode);
    _$hash = $jc(_$hash, mediaContentHash.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2MediaManifestItem')
          ..add('clientMediaId', clientMediaId)
          ..add('mimeType', mimeType)
          ..add('sizeBytes', sizeBytes)
          ..add('mediaContentHash', mediaContentHash))
        .toString();
  }
}

class V2MediaManifestItemBuilder
    implements Builder<V2MediaManifestItem, V2MediaManifestItemBuilder> {
  _$V2MediaManifestItem? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  String? _mimeType;
  String? get mimeType => _$this._mimeType;
  set mimeType(String? mimeType) => _$this._mimeType = mimeType;

  int? _sizeBytes;
  int? get sizeBytes => _$this._sizeBytes;
  set sizeBytes(int? sizeBytes) => _$this._sizeBytes = sizeBytes;

  String? _mediaContentHash;
  String? get mediaContentHash => _$this._mediaContentHash;
  set mediaContentHash(String? mediaContentHash) =>
      _$this._mediaContentHash = mediaContentHash;

  V2MediaManifestItemBuilder() {
    V2MediaManifestItem._defaults(this);
  }

  V2MediaManifestItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _mimeType = $v.mimeType;
      _sizeBytes = $v.sizeBytes;
      _mediaContentHash = $v.mediaContentHash;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2MediaManifestItem other) {
    _$v = other as _$V2MediaManifestItem;
  }

  @override
  void update(void Function(V2MediaManifestItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2MediaManifestItem build() => _build();

  _$V2MediaManifestItem _build() {
    final _$result = _$v ??
        _$V2MediaManifestItem._(
          clientMediaId: BuiltValueNullFieldError.checkNotNull(
              clientMediaId, r'V2MediaManifestItem', 'clientMediaId'),
          mimeType: mimeType,
          sizeBytes: sizeBytes,
          mediaContentHash: BuiltValueNullFieldError.checkNotNull(
              mediaContentHash, r'V2MediaManifestItem', 'mediaContentHash'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
