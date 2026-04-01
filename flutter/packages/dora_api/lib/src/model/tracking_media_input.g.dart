// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_media_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TrackingMediaInputMediaTypeEnum _$trackingMediaInputMediaTypeEnum_photo =
    const TrackingMediaInputMediaTypeEnum._('photo');
const TrackingMediaInputMediaTypeEnum _$trackingMediaInputMediaTypeEnum_media =
    const TrackingMediaInputMediaTypeEnum._('media');

TrackingMediaInputMediaTypeEnum _$trackingMediaInputMediaTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'photo':
      return _$trackingMediaInputMediaTypeEnum_photo;
    case 'media':
      return _$trackingMediaInputMediaTypeEnum_media;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackingMediaInputMediaTypeEnum>
    _$trackingMediaInputMediaTypeEnumValues = BuiltSet<
        TrackingMediaInputMediaTypeEnum>(const <TrackingMediaInputMediaTypeEnum>[
  _$trackingMediaInputMediaTypeEnum_photo,
  _$trackingMediaInputMediaTypeEnum_media,
]);

const TrackingMediaInputBindModeEnum _$trackingMediaInputBindModeEnum_place =
    const TrackingMediaInputBindModeEnum._('place');
const TrackingMediaInputBindModeEnum _$trackingMediaInputBindModeEnum_route =
    const TrackingMediaInputBindModeEnum._('route');

TrackingMediaInputBindModeEnum _$trackingMediaInputBindModeEnumValueOf(
    String name) {
  switch (name) {
    case 'place':
      return _$trackingMediaInputBindModeEnum_place;
    case 'route':
      return _$trackingMediaInputBindModeEnum_route;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TrackingMediaInputBindModeEnum>
    _$trackingMediaInputBindModeEnumValues = BuiltSet<
        TrackingMediaInputBindModeEnum>(const <TrackingMediaInputBindModeEnum>[
  _$trackingMediaInputBindModeEnum_place,
  _$trackingMediaInputBindModeEnum_route,
]);

Serializer<TrackingMediaInputMediaTypeEnum>
    _$trackingMediaInputMediaTypeEnumSerializer =
    _$TrackingMediaInputMediaTypeEnumSerializer();
Serializer<TrackingMediaInputBindModeEnum>
    _$trackingMediaInputBindModeEnumSerializer =
    _$TrackingMediaInputBindModeEnumSerializer();

class _$TrackingMediaInputMediaTypeEnumSerializer
    implements PrimitiveSerializer<TrackingMediaInputMediaTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'photo': 'photo',
    'media': 'media',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'photo': 'photo',
    'media': 'media',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackingMediaInputMediaTypeEnum];
  @override
  final String wireName = 'TrackingMediaInputMediaTypeEnum';

  @override
  Object serialize(
          Serializers serializers, TrackingMediaInputMediaTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackingMediaInputMediaTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackingMediaInputMediaTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackingMediaInputBindModeEnumSerializer
    implements PrimitiveSerializer<TrackingMediaInputBindModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'place': 'place',
    'route': 'route',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'place': 'place',
    'route': 'route',
  };

  @override
  final Iterable<Type> types = const <Type>[TrackingMediaInputBindModeEnum];
  @override
  final String wireName = 'TrackingMediaInputBindModeEnum';

  @override
  Object serialize(
          Serializers serializers, TrackingMediaInputBindModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TrackingMediaInputBindModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TrackingMediaInputBindModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TrackingMediaInput extends TrackingMediaInput {
  @override
  final String clientMediaId;
  @override
  final String clientEventId;
  @override
  final TrackingMediaInputMediaTypeEnum mediaType;
  @override
  final TrackingMediaInputBindModeEnum bindMode;
  @override
  final JsonObject? capturedAt;
  @override
  final String? tripPlaceId;
  @override
  final JsonObject? location;
  @override
  final String uploadRef;
  @override
  final String? mimeType;
  @override
  final int? fileSizeBytes;
  @override
  final JsonObject? payload;

  factory _$TrackingMediaInput(
          [void Function(TrackingMediaInputBuilder)? updates]) =>
      (TrackingMediaInputBuilder()..update(updates))._build();

  _$TrackingMediaInput._(
      {required this.clientMediaId,
      required this.clientEventId,
      required this.mediaType,
      required this.bindMode,
      this.capturedAt,
      this.tripPlaceId,
      this.location,
      required this.uploadRef,
      this.mimeType,
      this.fileSizeBytes,
      this.payload})
      : super._();
  @override
  TrackingMediaInput rebuild(
          void Function(TrackingMediaInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingMediaInputBuilder toBuilder() =>
      TrackingMediaInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingMediaInput &&
        clientMediaId == other.clientMediaId &&
        clientEventId == other.clientEventId &&
        mediaType == other.mediaType &&
        bindMode == other.bindMode &&
        capturedAt == other.capturedAt &&
        tripPlaceId == other.tripPlaceId &&
        location == other.location &&
        uploadRef == other.uploadRef &&
        mimeType == other.mimeType &&
        fileSizeBytes == other.fileSizeBytes &&
        payload == other.payload;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, mediaType.hashCode);
    _$hash = $jc(_$hash, bindMode.hashCode);
    _$hash = $jc(_$hash, capturedAt.hashCode);
    _$hash = $jc(_$hash, tripPlaceId.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, uploadRef.hashCode);
    _$hash = $jc(_$hash, mimeType.hashCode);
    _$hash = $jc(_$hash, fileSizeBytes.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingMediaInput')
          ..add('clientMediaId', clientMediaId)
          ..add('clientEventId', clientEventId)
          ..add('mediaType', mediaType)
          ..add('bindMode', bindMode)
          ..add('capturedAt', capturedAt)
          ..add('tripPlaceId', tripPlaceId)
          ..add('location', location)
          ..add('uploadRef', uploadRef)
          ..add('mimeType', mimeType)
          ..add('fileSizeBytes', fileSizeBytes)
          ..add('payload', payload))
        .toString();
  }
}

class TrackingMediaInputBuilder
    implements Builder<TrackingMediaInput, TrackingMediaInputBuilder> {
  _$TrackingMediaInput? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  TrackingMediaInputMediaTypeEnum? _mediaType;
  TrackingMediaInputMediaTypeEnum? get mediaType => _$this._mediaType;
  set mediaType(TrackingMediaInputMediaTypeEnum? mediaType) =>
      _$this._mediaType = mediaType;

  TrackingMediaInputBindModeEnum? _bindMode;
  TrackingMediaInputBindModeEnum? get bindMode => _$this._bindMode;
  set bindMode(TrackingMediaInputBindModeEnum? bindMode) =>
      _$this._bindMode = bindMode;

  JsonObject? _capturedAt;
  JsonObject? get capturedAt => _$this._capturedAt;
  set capturedAt(JsonObject? capturedAt) => _$this._capturedAt = capturedAt;

  String? _tripPlaceId;
  String? get tripPlaceId => _$this._tripPlaceId;
  set tripPlaceId(String? tripPlaceId) => _$this._tripPlaceId = tripPlaceId;

  JsonObject? _location;
  JsonObject? get location => _$this._location;
  set location(JsonObject? location) => _$this._location = location;

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

  JsonObject? _payload;
  JsonObject? get payload => _$this._payload;
  set payload(JsonObject? payload) => _$this._payload = payload;

  TrackingMediaInputBuilder() {
    TrackingMediaInput._defaults(this);
  }

  TrackingMediaInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _clientEventId = $v.clientEventId;
      _mediaType = $v.mediaType;
      _bindMode = $v.bindMode;
      _capturedAt = $v.capturedAt;
      _tripPlaceId = $v.tripPlaceId;
      _location = $v.location;
      _uploadRef = $v.uploadRef;
      _mimeType = $v.mimeType;
      _fileSizeBytes = $v.fileSizeBytes;
      _payload = $v.payload;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingMediaInput other) {
    _$v = other as _$TrackingMediaInput;
  }

  @override
  void update(void Function(TrackingMediaInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingMediaInput build() => _build();

  _$TrackingMediaInput _build() {
    final _$result = _$v ??
        _$TrackingMediaInput._(
          clientMediaId: BuiltValueNullFieldError.checkNotNull(
              clientMediaId, r'TrackingMediaInput', 'clientMediaId'),
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'TrackingMediaInput', 'clientEventId'),
          mediaType: BuiltValueNullFieldError.checkNotNull(
              mediaType, r'TrackingMediaInput', 'mediaType'),
          bindMode: BuiltValueNullFieldError.checkNotNull(
              bindMode, r'TrackingMediaInput', 'bindMode'),
          capturedAt: capturedAt,
          tripPlaceId: tripPlaceId,
          location: location,
          uploadRef: BuiltValueNullFieldError.checkNotNull(
              uploadRef, r'TrackingMediaInput', 'uploadRef'),
          mimeType: mimeType,
          fileSizeBytes: fileSizeBytes,
          payload: payload,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
