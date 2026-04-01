// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_register_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeviceTokenRegisterRequestPlatformEnum
    _$deviceTokenRegisterRequestPlatformEnum_ios =
    const DeviceTokenRegisterRequestPlatformEnum._('ios');
const DeviceTokenRegisterRequestPlatformEnum
    _$deviceTokenRegisterRequestPlatformEnum_android =
    const DeviceTokenRegisterRequestPlatformEnum._('android');
const DeviceTokenRegisterRequestPlatformEnum
    _$deviceTokenRegisterRequestPlatformEnum_web =
    const DeviceTokenRegisterRequestPlatformEnum._('web');

DeviceTokenRegisterRequestPlatformEnum
    _$deviceTokenRegisterRequestPlatformEnumValueOf(String name) {
  switch (name) {
    case 'ios':
      return _$deviceTokenRegisterRequestPlatformEnum_ios;
    case 'android':
      return _$deviceTokenRegisterRequestPlatformEnum_android;
    case 'web':
      return _$deviceTokenRegisterRequestPlatformEnum_web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeviceTokenRegisterRequestPlatformEnum>
    _$deviceTokenRegisterRequestPlatformEnumValues = BuiltSet<
        DeviceTokenRegisterRequestPlatformEnum>(const <DeviceTokenRegisterRequestPlatformEnum>[
  _$deviceTokenRegisterRequestPlatformEnum_ios,
  _$deviceTokenRegisterRequestPlatformEnum_android,
  _$deviceTokenRegisterRequestPlatformEnum_web,
]);

Serializer<DeviceTokenRegisterRequestPlatformEnum>
    _$deviceTokenRegisterRequestPlatformEnumSerializer =
    _$DeviceTokenRegisterRequestPlatformEnumSerializer();

class _$DeviceTokenRegisterRequestPlatformEnumSerializer
    implements PrimitiveSerializer<DeviceTokenRegisterRequestPlatformEnum> {
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
  final Iterable<Type> types = const <Type>[
    DeviceTokenRegisterRequestPlatformEnum
  ];
  @override
  final String wireName = 'DeviceTokenRegisterRequestPlatformEnum';

  @override
  Object serialize(Serializers serializers,
          DeviceTokenRegisterRequestPlatformEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeviceTokenRegisterRequestPlatformEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeviceTokenRegisterRequestPlatformEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeviceTokenRegisterRequest extends DeviceTokenRegisterRequest {
  @override
  final String clientEventId;
  @override
  final DeviceTokenRegisterRequestPlatformEnum platform;
  @override
  final String pushToken;
  @override
  final String? deviceId;
  @override
  final String? appVersion;
  @override
  final String? locale;
  @override
  final DateTime seenAt;

  factory _$DeviceTokenRegisterRequest(
          [void Function(DeviceTokenRegisterRequestBuilder)? updates]) =>
      (DeviceTokenRegisterRequestBuilder()..update(updates))._build();

  _$DeviceTokenRegisterRequest._(
      {required this.clientEventId,
      required this.platform,
      required this.pushToken,
      this.deviceId,
      this.appVersion,
      this.locale,
      required this.seenAt})
      : super._();
  @override
  DeviceTokenRegisterRequest rebuild(
          void Function(DeviceTokenRegisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceTokenRegisterRequestBuilder toBuilder() =>
      DeviceTokenRegisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceTokenRegisterRequest &&
        clientEventId == other.clientEventId &&
        platform == other.platform &&
        pushToken == other.pushToken &&
        deviceId == other.deviceId &&
        appVersion == other.appVersion &&
        locale == other.locale &&
        seenAt == other.seenAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientEventId.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, pushToken.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, locale.hashCode);
    _$hash = $jc(_$hash, seenAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceTokenRegisterRequest')
          ..add('clientEventId', clientEventId)
          ..add('platform', platform)
          ..add('pushToken', pushToken)
          ..add('deviceId', deviceId)
          ..add('appVersion', appVersion)
          ..add('locale', locale)
          ..add('seenAt', seenAt))
        .toString();
  }
}

class DeviceTokenRegisterRequestBuilder
    implements
        Builder<DeviceTokenRegisterRequest, DeviceTokenRegisterRequestBuilder> {
  _$DeviceTokenRegisterRequest? _$v;

  String? _clientEventId;
  String? get clientEventId => _$this._clientEventId;
  set clientEventId(String? clientEventId) =>
      _$this._clientEventId = clientEventId;

  DeviceTokenRegisterRequestPlatformEnum? _platform;
  DeviceTokenRegisterRequestPlatformEnum? get platform => _$this._platform;
  set platform(DeviceTokenRegisterRequestPlatformEnum? platform) =>
      _$this._platform = platform;

  String? _pushToken;
  String? get pushToken => _$this._pushToken;
  set pushToken(String? pushToken) => _$this._pushToken = pushToken;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _locale;
  String? get locale => _$this._locale;
  set locale(String? locale) => _$this._locale = locale;

  DateTime? _seenAt;
  DateTime? get seenAt => _$this._seenAt;
  set seenAt(DateTime? seenAt) => _$this._seenAt = seenAt;

  DeviceTokenRegisterRequestBuilder() {
    DeviceTokenRegisterRequest._defaults(this);
  }

  DeviceTokenRegisterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientEventId = $v.clientEventId;
      _platform = $v.platform;
      _pushToken = $v.pushToken;
      _deviceId = $v.deviceId;
      _appVersion = $v.appVersion;
      _locale = $v.locale;
      _seenAt = $v.seenAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceTokenRegisterRequest other) {
    _$v = other as _$DeviceTokenRegisterRequest;
  }

  @override
  void update(void Function(DeviceTokenRegisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceTokenRegisterRequest build() => _build();

  _$DeviceTokenRegisterRequest _build() {
    final _$result = _$v ??
        _$DeviceTokenRegisterRequest._(
          clientEventId: BuiltValueNullFieldError.checkNotNull(
              clientEventId, r'DeviceTokenRegisterRequest', 'clientEventId'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'DeviceTokenRegisterRequest', 'platform'),
          pushToken: BuiltValueNullFieldError.checkNotNull(
              pushToken, r'DeviceTokenRegisterRequest', 'pushToken'),
          deviceId: deviceId,
          appVersion: appVersion,
          locale: locale,
          seenAt: BuiltValueNullFieldError.checkNotNull(
              seenAt, r'DeviceTokenRegisterRequest', 'seenAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
