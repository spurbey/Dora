// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_media_upload_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingMediaUploadResponse extends TrackingMediaUploadResponse {
  @override
  final String tripId;
  @override
  final String uploadRef;
  @override
  final String? mimeType;
  @override
  final int fileSizeBytes;

  factory _$TrackingMediaUploadResponse(
          [void Function(TrackingMediaUploadResponseBuilder)? updates]) =>
      (TrackingMediaUploadResponseBuilder()..update(updates))._build();

  _$TrackingMediaUploadResponse._(
      {required this.tripId,
      required this.uploadRef,
      this.mimeType,
      required this.fileSizeBytes})
      : super._();
  @override
  TrackingMediaUploadResponse rebuild(
          void Function(TrackingMediaUploadResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingMediaUploadResponseBuilder toBuilder() =>
      TrackingMediaUploadResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingMediaUploadResponse &&
        tripId == other.tripId &&
        uploadRef == other.uploadRef &&
        mimeType == other.mimeType &&
        fileSizeBytes == other.fileSizeBytes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, uploadRef.hashCode);
    _$hash = $jc(_$hash, mimeType.hashCode);
    _$hash = $jc(_$hash, fileSizeBytes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingMediaUploadResponse')
          ..add('tripId', tripId)
          ..add('uploadRef', uploadRef)
          ..add('mimeType', mimeType)
          ..add('fileSizeBytes', fileSizeBytes))
        .toString();
  }
}

class TrackingMediaUploadResponseBuilder
    implements
        Builder<TrackingMediaUploadResponse,
            TrackingMediaUploadResponseBuilder> {
  _$TrackingMediaUploadResponse? _$v;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _uploadRef;
  String? get uploadRef => _$this._uploadRef;
  set uploadRef(String? uploadRef) => _$this._uploadRef = uploadRef;

  String? _mimeType;
  String? get mimeType => _$this._mimeType;
  set mimeType(String? mimeType) => _$this._mimeType = mimeType;

  int? _fileSizeBytes;
  int? get fileSizeBytes => _$this._fileSizeBytes;
  set fileSizeBytes(int? fileSizeBytes) =>
      _$this._fileSizeBytes = fileSizeBytes;

  TrackingMediaUploadResponseBuilder() {
    TrackingMediaUploadResponse._defaults(this);
  }

  TrackingMediaUploadResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _tripId = $v.tripId;
      _uploadRef = $v.uploadRef;
      _mimeType = $v.mimeType;
      _fileSizeBytes = $v.fileSizeBytes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingMediaUploadResponse other) {
    _$v = other as _$TrackingMediaUploadResponse;
  }

  @override
  void update(void Function(TrackingMediaUploadResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingMediaUploadResponse build() => _build();

  _$TrackingMediaUploadResponse _build() {
    final _$result = _$v ??
        _$TrackingMediaUploadResponse._(
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'TrackingMediaUploadResponse', 'tripId'),
          uploadRef: BuiltValueNullFieldError.checkNotNull(
              uploadRef, r'TrackingMediaUploadResponse', 'uploadRef'),
          mimeType: mimeType,
          fileSizeBytes: BuiltValueNullFieldError.checkNotNull(
              fileSizeBytes, r'TrackingMediaUploadResponse', 'fileSizeBytes'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
