// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlaceResponse extends PlaceResponse {
  @override
  final String id;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? placeType;
  @override
  final num lat;
  @override
  final num lng;
  @override
  final String? userNotes;
  @override
  final int? userRating;
  @override
  final Date? visitDate;
  @override
  final BuiltList<MediaResponse>? photos;
  @override
  final BuiltList<JsonObject>? videos;
  @override
  final JsonObject? externalData;
  @override
  final int? orderInTrip;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PlaceResponse([void Function(PlaceResponseBuilder)? updates]) =>
      (PlaceResponseBuilder()..update(updates))._build();

  _$PlaceResponse._(
      {required this.id,
      required this.tripId,
      required this.userId,
      required this.name,
      this.placeType,
      required this.lat,
      required this.lng,
      this.userNotes,
      this.userRating,
      this.visitDate,
      this.photos,
      this.videos,
      this.externalData,
      this.orderInTrip,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PlaceResponse rebuild(void Function(PlaceResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlaceResponseBuilder toBuilder() => PlaceResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlaceResponse &&
        id == other.id &&
        tripId == other.tripId &&
        userId == other.userId &&
        name == other.name &&
        placeType == other.placeType &&
        lat == other.lat &&
        lng == other.lng &&
        userNotes == other.userNotes &&
        userRating == other.userRating &&
        visitDate == other.visitDate &&
        photos == other.photos &&
        videos == other.videos &&
        externalData == other.externalData &&
        orderInTrip == other.orderInTrip &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, placeType.hashCode);
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, userNotes.hashCode);
    _$hash = $jc(_$hash, userRating.hashCode);
    _$hash = $jc(_$hash, visitDate.hashCode);
    _$hash = $jc(_$hash, photos.hashCode);
    _$hash = $jc(_$hash, videos.hashCode);
    _$hash = $jc(_$hash, externalData.hashCode);
    _$hash = $jc(_$hash, orderInTrip.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlaceResponse')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('name', name)
          ..add('placeType', placeType)
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('userNotes', userNotes)
          ..add('userRating', userRating)
          ..add('visitDate', visitDate)
          ..add('photos', photos)
          ..add('videos', videos)
          ..add('externalData', externalData)
          ..add('orderInTrip', orderInTrip)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PlaceResponseBuilder
    implements Builder<PlaceResponse, PlaceResponseBuilder> {
  _$PlaceResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _placeType;
  String? get placeType => _$this._placeType;
  set placeType(String? placeType) => _$this._placeType = placeType;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  String? _userNotes;
  String? get userNotes => _$this._userNotes;
  set userNotes(String? userNotes) => _$this._userNotes = userNotes;

  int? _userRating;
  int? get userRating => _$this._userRating;
  set userRating(int? userRating) => _$this._userRating = userRating;

  Date? _visitDate;
  Date? get visitDate => _$this._visitDate;
  set visitDate(Date? visitDate) => _$this._visitDate = visitDate;

  ListBuilder<MediaResponse>? _photos;
  ListBuilder<MediaResponse> get photos =>
      _$this._photos ??= ListBuilder<MediaResponse>();
  set photos(ListBuilder<MediaResponse>? photos) => _$this._photos = photos;

  ListBuilder<JsonObject>? _videos;
  ListBuilder<JsonObject> get videos =>
      _$this._videos ??= ListBuilder<JsonObject>();
  set videos(ListBuilder<JsonObject>? videos) => _$this._videos = videos;

  JsonObject? _externalData;
  JsonObject? get externalData => _$this._externalData;
  set externalData(JsonObject? externalData) =>
      _$this._externalData = externalData;

  int? _orderInTrip;
  int? get orderInTrip => _$this._orderInTrip;
  set orderInTrip(int? orderInTrip) => _$this._orderInTrip = orderInTrip;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PlaceResponseBuilder() {
    PlaceResponse._defaults(this);
  }

  PlaceResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _name = $v.name;
      _placeType = $v.placeType;
      _lat = $v.lat;
      _lng = $v.lng;
      _userNotes = $v.userNotes;
      _userRating = $v.userRating;
      _visitDate = $v.visitDate;
      _photos = $v.photos?.toBuilder();
      _videos = $v.videos?.toBuilder();
      _externalData = $v.externalData;
      _orderInTrip = $v.orderInTrip;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlaceResponse other) {
    _$v = other as _$PlaceResponse;
  }

  @override
  void update(void Function(PlaceResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlaceResponse build() => _build();

  _$PlaceResponse _build() {
    _$PlaceResponse _$result;
    try {
      _$result = _$v ??
          _$PlaceResponse._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PlaceResponse', 'id'),
            tripId: BuiltValueNullFieldError.checkNotNull(
                tripId, r'PlaceResponse', 'tripId'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'PlaceResponse', 'userId'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'PlaceResponse', 'name'),
            placeType: placeType,
            lat: BuiltValueNullFieldError.checkNotNull(
                lat, r'PlaceResponse', 'lat'),
            lng: BuiltValueNullFieldError.checkNotNull(
                lng, r'PlaceResponse', 'lng'),
            userNotes: userNotes,
            userRating: userRating,
            visitDate: visitDate,
            photos: _photos?.build(),
            videos: _videos?.build(),
            externalData: externalData,
            orderInTrip: orderInTrip,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'PlaceResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'PlaceResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'photos';
        _photos?.build();
        _$failedField = 'videos';
        _videos?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PlaceResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
