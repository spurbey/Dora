// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_generate_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RouteGenerateRequestModeEnum _$routeGenerateRequestModeEnum_driving =
    const RouteGenerateRequestModeEnum._('driving');
const RouteGenerateRequestModeEnum _$routeGenerateRequestModeEnum_walking =
    const RouteGenerateRequestModeEnum._('walking');
const RouteGenerateRequestModeEnum _$routeGenerateRequestModeEnum_cycling =
    const RouteGenerateRequestModeEnum._('cycling');

RouteGenerateRequestModeEnum _$routeGenerateRequestModeEnumValueOf(
    String name) {
  switch (name) {
    case 'driving':
      return _$routeGenerateRequestModeEnum_driving;
    case 'walking':
      return _$routeGenerateRequestModeEnum_walking;
    case 'cycling':
      return _$routeGenerateRequestModeEnum_cycling;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteGenerateRequestModeEnum>
    _$routeGenerateRequestModeEnumValues =
    BuiltSet<RouteGenerateRequestModeEnum>(const <RouteGenerateRequestModeEnum>[
  _$routeGenerateRequestModeEnum_driving,
  _$routeGenerateRequestModeEnum_walking,
  _$routeGenerateRequestModeEnum_cycling,
]);

Serializer<RouteGenerateRequestModeEnum>
    _$routeGenerateRequestModeEnumSerializer =
    _$RouteGenerateRequestModeEnumSerializer();

class _$RouteGenerateRequestModeEnumSerializer
    implements PrimitiveSerializer<RouteGenerateRequestModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'driving': 'driving',
    'walking': 'walking',
    'cycling': 'cycling',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'driving': 'driving',
    'walking': 'walking',
    'cycling': 'cycling',
  };

  @override
  final Iterable<Type> types = const <Type>[RouteGenerateRequestModeEnum];
  @override
  final String wireName = 'RouteGenerateRequestModeEnum';

  @override
  Object serialize(Serializers serializers, RouteGenerateRequestModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteGenerateRequestModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteGenerateRequestModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteGenerateRequest extends RouteGenerateRequest {
  @override
  final BuiltList<BuiltList<JsonObject?>> coordinates;
  @override
  final RouteGenerateRequestModeEnum? mode;

  factory _$RouteGenerateRequest(
          [void Function(RouteGenerateRequestBuilder)? updates]) =>
      (RouteGenerateRequestBuilder()..update(updates))._build();

  _$RouteGenerateRequest._({required this.coordinates, this.mode}) : super._();
  @override
  RouteGenerateRequest rebuild(
          void Function(RouteGenerateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteGenerateRequestBuilder toBuilder() =>
      RouteGenerateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteGenerateRequest &&
        coordinates == other.coordinates &&
        mode == other.mode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, coordinates.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteGenerateRequest')
          ..add('coordinates', coordinates)
          ..add('mode', mode))
        .toString();
  }
}

class RouteGenerateRequestBuilder
    implements Builder<RouteGenerateRequest, RouteGenerateRequestBuilder> {
  _$RouteGenerateRequest? _$v;

  ListBuilder<BuiltList<JsonObject?>>? _coordinates;
  ListBuilder<BuiltList<JsonObject?>> get coordinates =>
      _$this._coordinates ??= ListBuilder<BuiltList<JsonObject?>>();
  set coordinates(ListBuilder<BuiltList<JsonObject?>>? coordinates) =>
      _$this._coordinates = coordinates;

  RouteGenerateRequestModeEnum? _mode;
  RouteGenerateRequestModeEnum? get mode => _$this._mode;
  set mode(RouteGenerateRequestModeEnum? mode) => _$this._mode = mode;

  RouteGenerateRequestBuilder() {
    RouteGenerateRequest._defaults(this);
  }

  RouteGenerateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _coordinates = $v.coordinates.toBuilder();
      _mode = $v.mode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteGenerateRequest other) {
    _$v = other as _$RouteGenerateRequest;
  }

  @override
  void update(void Function(RouteGenerateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteGenerateRequest build() => _build();

  _$RouteGenerateRequest _build() {
    _$RouteGenerateRequest _$result;
    try {
      _$result = _$v ??
          _$RouteGenerateRequest._(
            coordinates: coordinates.build(),
            mode: mode,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'coordinates';
        coordinates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RouteGenerateRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
