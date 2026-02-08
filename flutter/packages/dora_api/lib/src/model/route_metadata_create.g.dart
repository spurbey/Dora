// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_metadata_create.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RouteMetadataCreateRouteQualityEnum
    _$routeMetadataCreateRouteQualityEnum_scenic =
    const RouteMetadataCreateRouteQualityEnum._('scenic');
const RouteMetadataCreateRouteQualityEnum
    _$routeMetadataCreateRouteQualityEnum_fastest =
    const RouteMetadataCreateRouteQualityEnum._('fastest');
const RouteMetadataCreateRouteQualityEnum
    _$routeMetadataCreateRouteQualityEnum_offbeat =
    const RouteMetadataCreateRouteQualityEnum._('offbeat');

RouteMetadataCreateRouteQualityEnum
    _$routeMetadataCreateRouteQualityEnumValueOf(String name) {
  switch (name) {
    case 'scenic':
      return _$routeMetadataCreateRouteQualityEnum_scenic;
    case 'fastest':
      return _$routeMetadataCreateRouteQualityEnum_fastest;
    case 'offbeat':
      return _$routeMetadataCreateRouteQualityEnum_offbeat;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteMetadataCreateRouteQualityEnum>
    _$routeMetadataCreateRouteQualityEnumValues = BuiltSet<
        RouteMetadataCreateRouteQualityEnum>(const <RouteMetadataCreateRouteQualityEnum>[
  _$routeMetadataCreateRouteQualityEnum_scenic,
  _$routeMetadataCreateRouteQualityEnum_fastest,
  _$routeMetadataCreateRouteQualityEnum_offbeat,
]);

const RouteMetadataCreateRoadConditionEnum
    _$routeMetadataCreateRoadConditionEnum_excellent =
    const RouteMetadataCreateRoadConditionEnum._('excellent');
const RouteMetadataCreateRoadConditionEnum
    _$routeMetadataCreateRoadConditionEnum_good =
    const RouteMetadataCreateRoadConditionEnum._('good');
const RouteMetadataCreateRoadConditionEnum
    _$routeMetadataCreateRoadConditionEnum_poor =
    const RouteMetadataCreateRoadConditionEnum._('poor');
const RouteMetadataCreateRoadConditionEnum
    _$routeMetadataCreateRoadConditionEnum_offroad =
    const RouteMetadataCreateRoadConditionEnum._('offroad');

RouteMetadataCreateRoadConditionEnum
    _$routeMetadataCreateRoadConditionEnumValueOf(String name) {
  switch (name) {
    case 'excellent':
      return _$routeMetadataCreateRoadConditionEnum_excellent;
    case 'good':
      return _$routeMetadataCreateRoadConditionEnum_good;
    case 'poor':
      return _$routeMetadataCreateRoadConditionEnum_poor;
    case 'offroad':
      return _$routeMetadataCreateRoadConditionEnum_offroad;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteMetadataCreateRoadConditionEnum>
    _$routeMetadataCreateRoadConditionEnumValues = BuiltSet<
        RouteMetadataCreateRoadConditionEnum>(const <RouteMetadataCreateRoadConditionEnum>[
  _$routeMetadataCreateRoadConditionEnum_excellent,
  _$routeMetadataCreateRoadConditionEnum_good,
  _$routeMetadataCreateRoadConditionEnum_poor,
  _$routeMetadataCreateRoadConditionEnum_offroad,
]);

Serializer<RouteMetadataCreateRouteQualityEnum>
    _$routeMetadataCreateRouteQualityEnumSerializer =
    _$RouteMetadataCreateRouteQualityEnumSerializer();
Serializer<RouteMetadataCreateRoadConditionEnum>
    _$routeMetadataCreateRoadConditionEnumSerializer =
    _$RouteMetadataCreateRoadConditionEnumSerializer();

class _$RouteMetadataCreateRouteQualityEnumSerializer
    implements PrimitiveSerializer<RouteMetadataCreateRouteQualityEnum> {
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
    RouteMetadataCreateRouteQualityEnum
  ];
  @override
  final String wireName = 'RouteMetadataCreateRouteQualityEnum';

  @override
  Object serialize(
          Serializers serializers, RouteMetadataCreateRouteQualityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteMetadataCreateRouteQualityEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteMetadataCreateRouteQualityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteMetadataCreateRoadConditionEnumSerializer
    implements PrimitiveSerializer<RouteMetadataCreateRoadConditionEnum> {
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
    RouteMetadataCreateRoadConditionEnum
  ];
  @override
  final String wireName = 'RouteMetadataCreateRoadConditionEnum';

  @override
  Object serialize(
          Serializers serializers, RouteMetadataCreateRoadConditionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteMetadataCreateRoadConditionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteMetadataCreateRoadConditionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteMetadataCreate extends RouteMetadataCreate {
  @override
  final RouteMetadataCreateRouteQualityEnum? routeQuality;
  @override
  final RouteMetadataCreateRoadConditionEnum? roadCondition;
  @override
  final int? scenicRating;
  @override
  final int? safetyRating;
  @override
  final bool? soloSafe;
  @override
  final FuelCost? fuelCost;
  @override
  final TollCost? tollCost;
  @override
  final BuiltList<String>? highlights;
  @override
  final bool? isPublic;

  factory _$RouteMetadataCreate(
          [void Function(RouteMetadataCreateBuilder)? updates]) =>
      (RouteMetadataCreateBuilder()..update(updates))._build();

  _$RouteMetadataCreate._(
      {this.routeQuality,
      this.roadCondition,
      this.scenicRating,
      this.safetyRating,
      this.soloSafe,
      this.fuelCost,
      this.tollCost,
      this.highlights,
      this.isPublic})
      : super._();
  @override
  RouteMetadataCreate rebuild(
          void Function(RouteMetadataCreateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteMetadataCreateBuilder toBuilder() =>
      RouteMetadataCreateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteMetadataCreate &&
        routeQuality == other.routeQuality &&
        roadCondition == other.roadCondition &&
        scenicRating == other.scenicRating &&
        safetyRating == other.safetyRating &&
        soloSafe == other.soloSafe &&
        fuelCost == other.fuelCost &&
        tollCost == other.tollCost &&
        highlights == other.highlights &&
        isPublic == other.isPublic;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteMetadataCreate')
          ..add('routeQuality', routeQuality)
          ..add('roadCondition', roadCondition)
          ..add('scenicRating', scenicRating)
          ..add('safetyRating', safetyRating)
          ..add('soloSafe', soloSafe)
          ..add('fuelCost', fuelCost)
          ..add('tollCost', tollCost)
          ..add('highlights', highlights)
          ..add('isPublic', isPublic))
        .toString();
  }
}

class RouteMetadataCreateBuilder
    implements Builder<RouteMetadataCreate, RouteMetadataCreateBuilder> {
  _$RouteMetadataCreate? _$v;

  RouteMetadataCreateRouteQualityEnum? _routeQuality;
  RouteMetadataCreateRouteQualityEnum? get routeQuality => _$this._routeQuality;
  set routeQuality(RouteMetadataCreateRouteQualityEnum? routeQuality) =>
      _$this._routeQuality = routeQuality;

  RouteMetadataCreateRoadConditionEnum? _roadCondition;
  RouteMetadataCreateRoadConditionEnum? get roadCondition =>
      _$this._roadCondition;
  set roadCondition(RouteMetadataCreateRoadConditionEnum? roadCondition) =>
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

  FuelCostBuilder? _fuelCost;
  FuelCostBuilder get fuelCost => _$this._fuelCost ??= FuelCostBuilder();
  set fuelCost(FuelCostBuilder? fuelCost) => _$this._fuelCost = fuelCost;

  TollCostBuilder? _tollCost;
  TollCostBuilder get tollCost => _$this._tollCost ??= TollCostBuilder();
  set tollCost(TollCostBuilder? tollCost) => _$this._tollCost = tollCost;

  ListBuilder<String>? _highlights;
  ListBuilder<String> get highlights =>
      _$this._highlights ??= ListBuilder<String>();
  set highlights(ListBuilder<String>? highlights) =>
      _$this._highlights = highlights;

  bool? _isPublic;
  bool? get isPublic => _$this._isPublic;
  set isPublic(bool? isPublic) => _$this._isPublic = isPublic;

  RouteMetadataCreateBuilder() {
    RouteMetadataCreate._defaults(this);
  }

  RouteMetadataCreateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routeQuality = $v.routeQuality;
      _roadCondition = $v.roadCondition;
      _scenicRating = $v.scenicRating;
      _safetyRating = $v.safetyRating;
      _soloSafe = $v.soloSafe;
      _fuelCost = $v.fuelCost?.toBuilder();
      _tollCost = $v.tollCost?.toBuilder();
      _highlights = $v.highlights?.toBuilder();
      _isPublic = $v.isPublic;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteMetadataCreate other) {
    _$v = other as _$RouteMetadataCreate;
  }

  @override
  void update(void Function(RouteMetadataCreateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteMetadataCreate build() => _build();

  _$RouteMetadataCreate _build() {
    _$RouteMetadataCreate _$result;
    try {
      _$result = _$v ??
          _$RouteMetadataCreate._(
            routeQuality: routeQuality,
            roadCondition: roadCondition,
            scenicRating: scenicRating,
            safetyRating: safetyRating,
            soloSafe: soloSafe,
            fuelCost: _fuelCost?.build(),
            tollCost: _tollCost?.build(),
            highlights: _highlights?.build(),
            isPublic: isPublic,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fuelCost';
        _fuelCost?.build();
        _$failedField = 'tollCost';
        _tollCost?.build();
        _$failedField = 'highlights';
        _highlights?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RouteMetadataCreate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
