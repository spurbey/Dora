// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MediaResponse extends MediaResponse {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String tripPlaceId;
  @override
  final String tripId;
  @override
  final String fileUrl;
  @override
  final String fileType;
  @override
  final int? fileSizeBytes;
  @override
  final String? mimeType;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final String? thumbnailUrl;
  @override
  final String? caption;
  @override
  final DateTime? takenAt;
  @override
  final DateTime createdAt;

  factory _$MediaResponse([void Function(MediaResponseBuilder)? updates]) =>
      (MediaResponseBuilder()..update(updates))._build();

  _$MediaResponse._(
      {required this.id,
      required this.userId,
      required this.tripPlaceId,
      required this.tripId,
      required this.fileUrl,
      required this.fileType,
      this.fileSizeBytes,
      this.mimeType,
      this.width,
      this.height,
      this.thumbnailUrl,
      this.caption,
      this.takenAt,
      required this.createdAt})
      : super._();
  @override
  MediaResponse rebuild(void Function(MediaResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MediaResponseBuilder toBuilder() => MediaResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MediaResponse &&
        id == other.id &&
        userId == other.userId &&
        tripPlaceId == other.tripPlaceId &&
        tripId == other.tripId &&
        fileUrl == other.fileUrl &&
        fileType == other.fileType &&
        fileSizeBytes == other.fileSizeBytes &&
        mimeType == other.mimeType &&
        width == other.width &&
        height == other.height &&
        thumbnailUrl == other.thumbnailUrl &&
        caption == other.caption &&
        takenAt == other.takenAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, tripPlaceId.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, fileUrl.hashCode);
    _$hash = $jc(_$hash, fileType.hashCode);
    _$hash = $jc(_$hash, fileSizeBytes.hashCode);
    _$hash = $jc(_$hash, mimeType.hashCode);
    _$hash = $jc(_$hash, width.hashCode);
    _$hash = $jc(_$hash, height.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, caption.hashCode);
    _$hash = $jc(_$hash, takenAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MediaResponse')
          ..add('id', id)
          ..add('userId', userId)
          ..add('tripPlaceId', tripPlaceId)
          ..add('tripId', tripId)
          ..add('fileUrl', fileUrl)
          ..add('fileType', fileType)
          ..add('fileSizeBytes', fileSizeBytes)
          ..add('mimeType', mimeType)
          ..add('width', width)
          ..add('height', height)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('caption', caption)
          ..add('takenAt', takenAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class MediaResponseBuilder
    implements Builder<MediaResponse, MediaResponseBuilder> {
  _$MediaResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _tripPlaceId;
  String? get tripPlaceId => _$this._tripPlaceId;
  set tripPlaceId(String? tripPlaceId) => _$this._tripPlaceId = tripPlaceId;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _fileUrl;
  String? get fileUrl => _$this._fileUrl;
  set fileUrl(String? fileUrl) => _$this._fileUrl = fileUrl;

  String? _fileType;
  String? get fileType => _$this._fileType;
  set fileType(String? fileType) => _$this._fileType = fileType;

  int? _fileSizeBytes;
  int? get fileSizeBytes => _$this._fileSizeBytes;
  set fileSizeBytes(int? fileSizeBytes) =>
      _$this._fileSizeBytes = fileSizeBytes;

  String? _mimeType;
  String? get mimeType => _$this._mimeType;
  set mimeType(String? mimeType) => _$this._mimeType = mimeType;

  int? _width;
  int? get width => _$this._width;
  set width(int? width) => _$this._width = width;

  int? _height;
  int? get height => _$this._height;
  set height(int? height) => _$this._height = height;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  String? _caption;
  String? get caption => _$this._caption;
  set caption(String? caption) => _$this._caption = caption;

  DateTime? _takenAt;
  DateTime? get takenAt => _$this._takenAt;
  set takenAt(DateTime? takenAt) => _$this._takenAt = takenAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  MediaResponseBuilder() {
    MediaResponse._defaults(this);
  }

  MediaResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _tripPlaceId = $v.tripPlaceId;
      _tripId = $v.tripId;
      _fileUrl = $v.fileUrl;
      _fileType = $v.fileType;
      _fileSizeBytes = $v.fileSizeBytes;
      _mimeType = $v.mimeType;
      _width = $v.width;
      _height = $v.height;
      _thumbnailUrl = $v.thumbnailUrl;
      _caption = $v.caption;
      _takenAt = $v.takenAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MediaResponse other) {
    _$v = other as _$MediaResponse;
  }

  @override
  void update(void Function(MediaResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MediaResponse build() => _build();

  _$MediaResponse _build() {
    final _$result = _$v ??
        _$MediaResponse._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'MediaResponse', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'MediaResponse', 'userId'),
          tripPlaceId: BuiltValueNullFieldError.checkNotNull(
              tripPlaceId, r'MediaResponse', 'tripPlaceId'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'MediaResponse', 'tripId'),
          fileUrl: BuiltValueNullFieldError.checkNotNull(
              fileUrl, r'MediaResponse', 'fileUrl'),
          fileType: BuiltValueNullFieldError.checkNotNull(
              fileType, r'MediaResponse', 'fileType'),
          fileSizeBytes: fileSizeBytes,
          mimeType: mimeType,
          width: width,
          height: height,
          thumbnailUrl: thumbnailUrl,
          caption: caption,
          takenAt: takenAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'MediaResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
