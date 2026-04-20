// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StoryResponse extends StoryResponse {
  @override
  final String id;
  @override
  final String clientStoryId;
  @override
  final String authorUserId;
  @override
  final String mediaType;
  @override
  final String? mediaUrl;
  @override
  final String? thumbnailUrl;
  @override
  final int? durationMs;
  @override
  final num centerLat;
  @override
  final num centerLng;
  @override
  final String status;
  @override
  final DateTime? publishedAt;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime? deletedAt;
  @override
  final int? viewCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final num? distanceKm;
  @override
  final bool? isOwn;

  factory _$StoryResponse([void Function(StoryResponseBuilder)? updates]) =>
      (StoryResponseBuilder()..update(updates))._build();

  _$StoryResponse._(
      {required this.id,
      required this.clientStoryId,
      required this.authorUserId,
      required this.mediaType,
      this.mediaUrl,
      this.thumbnailUrl,
      this.durationMs,
      required this.centerLat,
      required this.centerLng,
      required this.status,
      this.publishedAt,
      this.expiresAt,
      this.deletedAt,
      this.viewCount,
      required this.createdAt,
      required this.updatedAt,
      this.distanceKm,
      this.isOwn})
      : super._();
  @override
  StoryResponse rebuild(void Function(StoryResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StoryResponseBuilder toBuilder() => StoryResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StoryResponse &&
        id == other.id &&
        clientStoryId == other.clientStoryId &&
        authorUserId == other.authorUserId &&
        mediaType == other.mediaType &&
        mediaUrl == other.mediaUrl &&
        thumbnailUrl == other.thumbnailUrl &&
        durationMs == other.durationMs &&
        centerLat == other.centerLat &&
        centerLng == other.centerLng &&
        status == other.status &&
        publishedAt == other.publishedAt &&
        expiresAt == other.expiresAt &&
        deletedAt == other.deletedAt &&
        viewCount == other.viewCount &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        distanceKm == other.distanceKm &&
        isOwn == other.isOwn;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, clientStoryId.hashCode);
    _$hash = $jc(_$hash, authorUserId.hashCode);
    _$hash = $jc(_$hash, mediaType.hashCode);
    _$hash = $jc(_$hash, mediaUrl.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, durationMs.hashCode);
    _$hash = $jc(_$hash, centerLat.hashCode);
    _$hash = $jc(_$hash, centerLng.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, publishedAt.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, viewCount.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, distanceKm.hashCode);
    _$hash = $jc(_$hash, isOwn.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StoryResponse')
          ..add('id', id)
          ..add('clientStoryId', clientStoryId)
          ..add('authorUserId', authorUserId)
          ..add('mediaType', mediaType)
          ..add('mediaUrl', mediaUrl)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('durationMs', durationMs)
          ..add('centerLat', centerLat)
          ..add('centerLng', centerLng)
          ..add('status', status)
          ..add('publishedAt', publishedAt)
          ..add('expiresAt', expiresAt)
          ..add('deletedAt', deletedAt)
          ..add('viewCount', viewCount)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('distanceKm', distanceKm)
          ..add('isOwn', isOwn))
        .toString();
  }
}

class StoryResponseBuilder
    implements Builder<StoryResponse, StoryResponseBuilder> {
  _$StoryResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _clientStoryId;
  String? get clientStoryId => _$this._clientStoryId;
  set clientStoryId(String? clientStoryId) =>
      _$this._clientStoryId = clientStoryId;

  String? _authorUserId;
  String? get authorUserId => _$this._authorUserId;
  set authorUserId(String? authorUserId) => _$this._authorUserId = authorUserId;

  String? _mediaType;
  String? get mediaType => _$this._mediaType;
  set mediaType(String? mediaType) => _$this._mediaType = mediaType;

  String? _mediaUrl;
  String? get mediaUrl => _$this._mediaUrl;
  set mediaUrl(String? mediaUrl) => _$this._mediaUrl = mediaUrl;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  int? _durationMs;
  int? get durationMs => _$this._durationMs;
  set durationMs(int? durationMs) => _$this._durationMs = durationMs;

  num? _centerLat;
  num? get centerLat => _$this._centerLat;
  set centerLat(num? centerLat) => _$this._centerLat = centerLat;

  num? _centerLng;
  num? get centerLng => _$this._centerLng;
  set centerLng(num? centerLng) => _$this._centerLng = centerLng;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  DateTime? _publishedAt;
  DateTime? get publishedAt => _$this._publishedAt;
  set publishedAt(DateTime? publishedAt) => _$this._publishedAt = publishedAt;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  int? _viewCount;
  int? get viewCount => _$this._viewCount;
  set viewCount(int? viewCount) => _$this._viewCount = viewCount;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  num? _distanceKm;
  num? get distanceKm => _$this._distanceKm;
  set distanceKm(num? distanceKm) => _$this._distanceKm = distanceKm;

  bool? _isOwn;
  bool? get isOwn => _$this._isOwn;
  set isOwn(bool? isOwn) => _$this._isOwn = isOwn;

  StoryResponseBuilder() {
    StoryResponse._defaults(this);
  }

  StoryResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _clientStoryId = $v.clientStoryId;
      _authorUserId = $v.authorUserId;
      _mediaType = $v.mediaType;
      _mediaUrl = $v.mediaUrl;
      _thumbnailUrl = $v.thumbnailUrl;
      _durationMs = $v.durationMs;
      _centerLat = $v.centerLat;
      _centerLng = $v.centerLng;
      _status = $v.status;
      _publishedAt = $v.publishedAt;
      _expiresAt = $v.expiresAt;
      _deletedAt = $v.deletedAt;
      _viewCount = $v.viewCount;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _distanceKm = $v.distanceKm;
      _isOwn = $v.isOwn;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StoryResponse other) {
    _$v = other as _$StoryResponse;
  }

  @override
  void update(void Function(StoryResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StoryResponse build() => _build();

  _$StoryResponse _build() {
    final _$result = _$v ??
        _$StoryResponse._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'StoryResponse', 'id'),
          clientStoryId: BuiltValueNullFieldError.checkNotNull(
              clientStoryId, r'StoryResponse', 'clientStoryId'),
          authorUserId: BuiltValueNullFieldError.checkNotNull(
              authorUserId, r'StoryResponse', 'authorUserId'),
          mediaType: BuiltValueNullFieldError.checkNotNull(
              mediaType, r'StoryResponse', 'mediaType'),
          mediaUrl: mediaUrl,
          thumbnailUrl: thumbnailUrl,
          durationMs: durationMs,
          centerLat: BuiltValueNullFieldError.checkNotNull(
              centerLat, r'StoryResponse', 'centerLat'),
          centerLng: BuiltValueNullFieldError.checkNotNull(
              centerLng, r'StoryResponse', 'centerLng'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'StoryResponse', 'status'),
          publishedAt: publishedAt,
          expiresAt: expiresAt,
          deletedAt: deletedAt,
          viewCount: viewCount,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'StoryResponse', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'StoryResponse', 'updatedAt'),
          distanceKm: distanceKm,
          isOwn: isOwn,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
