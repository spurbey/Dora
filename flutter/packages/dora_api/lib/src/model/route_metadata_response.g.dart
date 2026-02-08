// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_metadata_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RouteMetadataResponseRouteQualityEnum
    _$routeMetadataResponseRouteQualityEnum_scenic =
    const RouteMetadataResponseRouteQualityEnum._('scenic');
const RouteMetadataResponseRouteQualityEnum
    _$routeMetadataResponseRouteQualityEnum_fastest =
    const RouteMetadataResponseRouteQualityEnum._('fastest');
const RouteMetadataResponseRouteQualityEnum
    _$routeMetadataResponseRouteQualityEnum_offbeat =
    const RouteMetadataResponseRouteQualityEnum._('offbeat');

RouteMetadataResponseRouteQualityEnum
    _$routeMetadataResponseRouteQualityEnumValueOf(String name) {
  switch (name) {
    case 'scenic':
      return _$routeMetadataResponseRouteQualityEnum_scenic;
    case 'fastest':
      return _$routeMetadataResponseRouteQualityEnum_fastest;
    case 'offbeat':
      return _$routeMetadataResponseRouteQualityEnum_offbeat;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteMetadataResponseRouteQualityEnum>
    _$routeMetadataResponseRouteQualityEnumValues = BuiltSet<
        RouteMetadataResponseRouteQualityEnum>(const <RouteMetadataResponseRouteQualityEnum>[
  _$routeMetadataResponseRouteQualityEnum_scenic,
  _$routeMetadataResponseRouteQualityEnum_fastest,
  _$routeMetadataResponseRouteQualityEnum_offbeat,
]);

const RouteMetadataResponseRoadConditionEnum
    _$routeMetadataResponseRoadConditionEnum_excellent =
    const RouteMetadataResponseRoadConditionEnum._('excellent');
const RouteMetadataResponseRoadConditionEnum
    _$routeMetadataResponseRoadConditionEnum_good =
    const RouteMetadataResponseRoadConditionEnum._('good');
const RouteMetadataResponseRoadConditionEnum
    _$routeMetadataResponseRoadConditionEnum_poor =
    const RouteMetadataResponseRoadConditionEnum._('poor');
const RouteMetadataResponseRoadConditionEnum
    _$routeMetadataResponseRoadConditionEnum_offroad =
    const RouteMetadataResponseRoadConditionEnum._('offroad');

RouteMetadataResponseRoadConditionEnum
    _$routeMetadataResponseRoadConditionEnumValueOf(String name) {
  switch (name) {
    case 'excellent':
      return _$routeMetadataResponseRoadConditionEnum_excellent;
    case 'good':
      return _$routeMetadataResponseRoadConditionEnum_good;
    case 'poor':
      return _$routeMetadataResponseRoadConditionEnum_poor;
    case 'offroad':
      return _$routeMetadataResponseRoadConditionEnum_offroad;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteMetadataResponseRoadConditionEnum>
    _$routeMetadataResponseRoadConditionEnumValues = BuiltSet<
        RouteMetadataResponseRoadConditionEnum>(const <RouteMetadataResponseRoadConditionEnum>[
  _$routeMetadataResponseRoadConditionEnum_excellent,
  _$routeMetadataResponseRoadConditionEnum_good,
  _$routeMetadataResponseRoadConditionEnum_poor,
  _$routeMetadataResponseRoadConditionEnum_offroad,
]);

Serializer<RouteMetadataResponseRouteQualityEnum>
    _$routeMetadataResponseRouteQualityEnumSerializer =
    _$RouteMetadataResponseRouteQualityEnumSerializer();
Serializer<RouteMetadataResponseRoadConditionEnum>
    _$routeMetadataResponseRoadConditionEnumSerializer =
    _$RouteMetadataResponseRoadConditionEnumSerializer();

class _$RouteMetadataResponseRouteQualityEnumSerializer
    implements PrimitiveSerializer<RouteMetadataResponseRouteQualityEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'scenic': 'scenic',
    'fastest': 'fastest',
    'offbeat': 'offbeat',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'scenic': 'scenic',
    'fastest': 'fastest',
    'offbeat': 'offbeat',
  };

  @override
  final Iterable<Type> types = const <Type>[
    RouteMetadataResponseRouteQualityEnum
  ];
  @override
  final String wireName = 'RouteMetadataResponseRouteQualityEnum';

  @override
  Object serialize(
          Serializers serializers, RouteMetadataResponseRouteQualityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteMetadataResponseRouteQualityEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteMetadataResponseRouteQualityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteMetadataResponseRoadConditionEnumSerializer
    implements PrimitiveSerializer<RouteMetadataResponseRoadConditionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'excellent': 'excellent',
    'good': 'good',
    'poor': 'poor',
    'offroad': 'offroad',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'excellent': 'excellent',
    'good': 'good',
    'poor': 'poor',
    'offroad': 'offroad',
  };

  @override
  final Iterable<Type> types = const <Type>[
    RouteMetadataResponseRoadConditionEnum
  ];
  @override
  final String wireName = 'RouteMetadataResponseRoadConditionEnum';

  @override
  Object serialize(Serializers serializers,
          RouteMetadataResponseRoadConditionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteMetadataResponseRoadConditionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteMetadataResponseRoadConditionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteMetadataResponse extends RouteMetadataResponse {
  @override
  final RouteMetadataResponseRouteQualityEnum? routeQuality;
  @override
  final RouteMetadataResponseRoadConditionEnum? roadCondition;
  @override
  final int? scenicRating;
  @override
  final int? safetyRating;
  @override
  final bool? soloSafe;
  @override
  final String? fuelCost;
  @override
  final String? tollCost;
  @override
  final BuiltList<String>? highlights;
  @override
  final bool? isPublic;
  @override
  final String routeId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$RouteMetadataResponse(
          [void Function(RouteMetadataResponseBuilder)? updates]) =>
      (RouteMetadataResponseBuilder()..update(updates))._build();

  _$RouteMetadataResponse._(
      {this.routeQuality,
      this.roadCondition,
      this.scenicRating,
      this.safetyRating,
      this.soloSafe,
      this.fuelCost,
      this.tollCost,
      this.highlights,
      this.isPublic,
      required this.routeId,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  RouteMetadataResponse rebuild(
          void Function(RouteMetadataResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteMetadataResponseBuilder toBuilder() =>
      RouteMetadataResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteMetadataResponse &&
        routeQuality == other.routeQuality &&
        roadCondition == other.roadCondition &&
        scenicRating == other.scenicRating &&
        safetyRating == other.safetyRating &&
        soloSafe == other.soloSafe &&
        fuelCost == other.fuelCost &&
        tollCost == other.tollCost &&
        highlights == other.highlights &&
        isPublic == other.isPublic &&
        routeId == other.routeId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routeQuality.hashCode);
    _$hash = $jc(_$hash, roadCondition.hashCode);
    _$hash = $jc(_$hash, scenicRating.hashCode);
    _$hash = $jc(_$hash, safetyRating.hashCode);
    _$hash = $jc(_$hash, soloSafe.hashCode);
    _$hash = $jc(_$hash, fuelCost.hashCode);
    _$hash = $jc(_$hash, tollCost.hashCode);
    _$hash = $jc(_$hash, highlights.hashCode);
    _$hash = $jc(_$hash, isPublic.hashCode);
    _$hash = $jc(_$hash, routeId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteMetadataResponse')
          ..add('routeQuality', routeQuality)
          ..add('roadCondition', roadCondition)
          ..add('scenicRating', scenicRating)
          ..add('safetyRating', safetyRating)
          ..add('soloSafe', soloSafe)
          ..add('fuelCost', fuelCost)
          ..add('tollCost', tollCost)
          ..add('highlights', highlights)
          ..add('isPublic', isPublic)
          ..add('routeId', routeId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RouteMetadataResponseBuilder
    implements Builder<RouteMetadataResponse, RouteMetadataResponseBuilder> {
  _$RouteMetadataResponse? _$v;

  RouteMetadataResponseRouteQualityEnum? _routeQuality;
  RouteMetadataResponseRouteQualityEnum? get routeQuality =>
      _$this._routeQuality;
  set routeQuality(RouteMetadataResponseRouteQualityEnum? routeQuality) =>
      _$this._routeQuality = routeQuality;

  RouteMetadataResponseRoadConditionEnum? _roadCondition;
  RouteMetadataResponseRoadConditionEnum? get roadCondition =>
      _$this._roadCondition;
  set roadCondition(RouteMetadataResponseRoadConditionEnum? roadCondition) =>
      _$this._roadCondition = roadCondition;

  int? _scenicRating;
  int? get scenicRating => _$this._scenicRating;
  set scenicRating(int? scenicRating) => _$this._scenicRating = scenicRating;

  int? _safetyRating;
  int? get safetyRating => _$this._safetyRating;
  set safetyRating(int? safetyRating) => _$this._safetyRating = safetyRating;

  bool? _soloSafe;
  bool? get soloSafe => _$this._soloSafe;
  set soloSafe(bool? soloSafe) => _$this._soloSafe = soloSafe;

  String? _fuelCost;
  String? get fuelCost => _$this._fuelCost;
  set fuelCost(String? fuelCost) => _$this._fuelCost = fuelCost;

  String? _tollCost;
  String? get tollCost => _$this._tollCost;
  set tollCost(String? tollCost) => _$this._tollCost = tollCost;

  ListBuilder<String>? _highlights;
  ListBuilder<String> get highlights =>
      _$this._highlights ??= ListBuilder<String>();
  set highlights(ListBuilder<String>? highlights) =>
      _$this._highlights = highlights;

  bool? _isPublic;
  bool? get isPublic => _$this._isPublic;
  set isPublic(bool? isPublic) => _$this._isPublic = isPublic;

  String? _routeId;
  String? get routeId => _$this._routeId;
  set routeId(String? routeId) => _$this._routeId = routeId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RouteMetadataResponseBuilder() {
    RouteMetadataResponse._defaults(this);
  }

  RouteMetadataResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeQuality = $v.routeQuality;
      _roadCondition = $v.roadCondition;
      _scenicRating = $v.scenicRating;
      _safetyRating = $v.safetyRating;
      _soloSafe = $v.soloSafe;
      _fuelCost = $v.fuelCost;
      _tollCost = $v.tollCost;
      _highlights = $v.highlights?.toBuilder();
      _isPublic = $v.isPublic;
      _routeId = $v.routeId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteMetadataResponse other) {
    _$v = other as _$RouteMetadataResponse;
  }

  @override
  void update(void Function(RouteMetadataResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteMetadataResponse build() => _build();

  _$RouteMetadataResponse _build() {
    _$RouteMetadataResponse _$result;
    try {
      _$result = _$v ??
          _$RouteMetadataResponse._(
            routeQuality: routeQuality,
            roadCondition: roadCondition,
            scenicRating: scenicRating,
            safetyRating: safetyRating,
            soloSafe: soloSafe,
            fuelCost: fuelCost,
            tollCost: tollCost,
            highlights: _highlights?.build(),
            isPublic: isPublic,
            routeId: BuiltValueNullFieldError.checkNotNull(
                routeId, r'RouteMetadataResponse', 'routeId'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'RouteMetadataResponse', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'RouteMetadataResponse', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'highlights';
        _highlights?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RouteMetadataResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
