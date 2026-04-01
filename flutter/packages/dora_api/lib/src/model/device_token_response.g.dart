// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceTokenResponsePlatformEnum _$deviceTokenResponsePlatformEnum_ios =
    const DeviceTokenResponsePlatformEnum._('ios');
const DeviceTokenResponsePlatformEnum
    _$deviceTokenResponsePlatformEnum_android =
    const DeviceTokenResponsePlatformEnum._('android');
const DeviceTokenResponsePlatformEnum _$deviceTokenResponsePlatformEnum_web =
    const DeviceTokenResponsePlatformEnum._('web');

DeviceTokenResponsePlatformEnum _$deviceTokenResponsePlatformEnumValueOf(
    String name) {
  switch (name) {
    case 'ios':
      return _$deviceTokenResponsePlatformEnum_ios;
    case 'android':
      return _$deviceTokenResponsePlatformEnum_android;
    case 'web':
      return _$deviceTokenResponsePlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceTokenResponsePlatformEnum>
    _$deviceTokenResponsePlatformEnumValues = BuiltSet<
        DeviceTokenResponsePlatformEnum>(const <DeviceTokenResponsePlatformEnum>[
  _$deviceTokenResponsePlatformEnum_ios,
  _$deviceTokenResponsePlatformEnum_android,
  _$deviceTokenResponsePlatformEnum_web,
]);

Serializer<DeviceTokenResponsePlatformEnum>
    _$deviceTokenResponsePlatformEnumSerializer =
    _$DeviceTokenResponsePlatformEnumSerializer();

class _$DeviceTokenResponsePlatformEnumSerializer
    implements PrimitiveSerializer<DeviceTokenResponsePlatformEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ios': 'ios',
    'android': 'android',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ios': 'ios',
    'android': 'android',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[DeviceTokenResponsePlatformEnum];
  @override
  final String wireName = 'DeviceTokenResponsePlatformEnum';

  @override
  Object serialize(
          Serializers serializers, DeviceTokenResponsePlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceTokenResponsePlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceTokenResponsePlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceTokenResponse extends DeviceTokenResponse {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DeviceTokenResponsePlatformEnum platform;
  @override
  final String? deviceId;
  @override
  final String? appVersion;
  @override
  final String? locale;
  @override
  final String? tokenHint;
  @override
  final bool isActive;
  @override
  final int failureCount;
  @override
  final DateTime lastSeenAt;
  @override
  final DateTime? lastSentAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$DeviceTokenResponse(
          [void Function(DeviceTokenResponseBuilder)? updates]) =>
      (DeviceTokenResponseBuilder()..update(updates))._build();

  _$DeviceTokenResponse._(
      {required this.id,
      required this.userId,
      required this.platform,
      this.deviceId,
      this.appVersion,
      this.locale,
      this.tokenHint,
      required this.isActive,
      required this.failureCount,
      required this.lastSeenAt,
      this.lastSentAt,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  DeviceTokenResponse rebuild(
          void Function(DeviceTokenResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceTokenResponseBuilder toBuilder() =>
      DeviceTokenResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceTokenResponse &&
        id == other.id &&
        userId == other.userId &&
        platform == other.platform &&
        deviceId == other.deviceId &&
        appVersion == other.appVersion &&
        locale == other.locale &&
        tokenHint == other.tokenHint &&
        isActive == other.isActive &&
        failureCount == other.failureCount &&
        lastSeenAt == other.lastSeenAt &&
        lastSentAt == other.lastSentAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, tokenHint.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, failureCount.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, lastSentAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceTokenResponse')
          ..add('id', id)
          ..add('userId', userId)
          ..add('platform', platform)
          ..add('deviceId', deviceId)
          ..add('appVersion', appVersion)
          ..add('locale', locale)
          ..add('tokenHint', tokenHint)
          ..add('isActive', isActive)
          ..add('failureCount', failureCount)
          ..add('lastSeenAt', lastSeenAt)
          ..add('lastSentAt', lastSentAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class DeviceTokenResponseBuilder
    implements Builder<DeviceTokenResponse, DeviceTokenResponseBuilder> {
  _$DeviceTokenResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DeviceTokenResponsePlatformEnum? _platform;
  DeviceTokenResponsePlatformEnum? get platform => _$this._platform;
  set platform(DeviceTokenResponsePlatformEnum? platform) =>
      _$this._platform = platform;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  String? _tokenHint;
  String? get tokenHint => _$this._tokenHint;
  set tokenHint(String? tokenHint) => _$this._tokenHint = tokenHint;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  int? _failureCount;
  int? get failureCount => _$this._failureCount;
  set failureCount(int? failureCount) => _$this._failureCount = failureCount;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DateTime? _lastSentAt;
  DateTime? get lastSentAt => _$this._lastSentAt;
  set lastSentAt(DateTime? lastSentAt) => _$this._lastSentAt = lastSentAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DeviceTokenResponseBuilder() {
    DeviceTokenResponse._defaults(this);
  }

  DeviceTokenResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _platform = $v.platform;
      _deviceId = $v.deviceId;
      _appVersion = $v.appVersion;
      _locale = $v.locale;
      _tokenHint = $v.tokenHint;
      _isActive = $v.isActive;
      _failureCount = $v.failureCount;
      _lastSeenAt = $v.lastSeenAt;
      _lastSentAt = $v.lastSentAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceTokenResponse other) {
    _$v = other as _$DeviceTokenResponse;
  }

  @override
  void update(void Function(DeviceTokenResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceTokenResponse build() => _build();

  _$DeviceTokenResponse _build() {
    final _$result = _$v ??
        _$DeviceTokenResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'DeviceTokenResponse', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'DeviceTokenResponse', 'userId'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'DeviceTokenResponse', 'platform'),
          deviceId: deviceId,
          appVersion: appVersion,
          locale: locale,
          tokenHint: tokenHint,
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'DeviceTokenResponse', 'isActive'),
          failureCount: BuiltValueNullFieldError.checkNotNull(
              failureCount, r'DeviceTokenResponse', 'failureCount'),
          lastSeenAt: BuiltValueNullFieldError.checkNotNull(
              lastSeenAt, r'DeviceTokenResponse', 'lastSeenAt'),
          lastSentAt: lastSentAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'DeviceTokenResponse', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'DeviceTokenResponse', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
