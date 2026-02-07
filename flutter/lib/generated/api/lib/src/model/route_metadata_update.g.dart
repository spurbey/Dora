// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_metadata_update.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RouteMetadataUpdateRouteQualityEnum
    _$routeMetadataUpdateRouteQualityEnum_scenic =
    const RouteMetadataUpdateRouteQualityEnum._('scenic');
const RouteMetadataUpdateRouteQualityEnum
    _$routeMetadataUpdateRouteQualityEnum_fastest =
    const RouteMetadataUpdateRouteQualityEnum._('fastest');
const RouteMetadataUpdateRouteQualityEnum
    _$routeMetadataUpdateRouteQualityEnum_offbeat =
    const RouteMetadataUpdateRouteQualityEnum._('offbeat');

RouteMetadataUpdateRouteQualityEnum
    _$routeMetadataUpdateRouteQualityEnumValueOf(String name) {
  switch (name) {
    case 'scenic':
      return _$routeMetadataUpdateRouteQualityEnum_scenic;
    case 'fastest':
      return _$routeMetadataUpdateRouteQualityEnum_fastest;
    case 'offbeat':
      return _$routeMetadataUpdateRouteQualityEnum_offbeat;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteMetadataUpdateRouteQualityEnum>
    _$routeMetadataUpdateRouteQualityEnumValues = BuiltSet<
        RouteMetadataUpdateRouteQualityEnum>(const <RouteMetadataUpdateRouteQualityEnum>[
  _$routeMetadataUpdateRouteQualityEnum_scenic,
  _$routeMetadataUpdateRouteQualityEnum_fastest,
  _$routeMetadataUpdateRouteQualityEnum_offbeat,
]);

const RouteMetadataUpdateRoadConditionEnum
    _$routeMetadataUpdateRoadConditionEnum_excellent =
    const RouteMetadataUpdateRoadConditionEnum._('excellent');
const RouteMetadataUpdateRoadConditionEnum
    _$routeMetadataUpdateRoadConditionEnum_good =
    const RouteMetadataUpdateRoadConditionEnum._('good');
const RouteMetadataUpdateRoadConditionEnum
    _$routeMetadataUpdateRoadConditionEnum_poor =
    const RouteMetadataUpdateRoadConditionEnum._('poor');
const RouteMetadataUpdateRoadConditionEnum
    _$routeMetadataUpdateRoadConditionEnum_offroad =
    const RouteMetadataUpdateRoadConditionEnum._('offroad');

RouteMetadataUpdateRoadConditionEnum
    _$routeMetadataUpdateRoadConditionEnumValueOf(String name) {
  switch (name) {
    case 'excellent':
      return _$routeMetadataUpdateRoadConditionEnum_excellent;
    case 'good':
      return _$routeMetadataUpdateRoadConditionEnum_good;
    case 'poor':
      return _$routeMetadataUpdateRoadConditionEnum_poor;
    case 'offroad':
      return _$routeMetadataUpdateRoadConditionEnum_offroad;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RouteMetadataUpdateRoadConditionEnum>
    _$routeMetadataUpdateRoadConditionEnumValues = BuiltSet<
        RouteMetadataUpdateRoadConditionEnum>(const <RouteMetadataUpdateRoadConditionEnum>[
  _$routeMetadataUpdateRoadConditionEnum_excellent,
  _$routeMetadataUpdateRoadConditionEnum_good,
  _$routeMetadataUpdateRoadConditionEnum_poor,
  _$routeMetadataUpdateRoadConditionEnum_offroad,
]);

Serializer<RouteMetadataUpdateRouteQualityEnum>
    _$routeMetadataUpdateRouteQualityEnumSerializer =
    _$RouteMetadataUpdateRouteQualityEnumSerializer();
Serializer<RouteMetadataUpdateRoadConditionEnum>
    _$routeMetadataUpdateRoadConditionEnumSerializer =
    _$RouteMetadataUpdateRoadConditionEnumSerializer();

class _$RouteMetadataUpdateRouteQualityEnumSerializer
    implements PrimitiveSerializer<RouteMetadataUpdateRouteQualityEnum> {
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
    RouteMetadataUpdateRouteQualityEnum
  ];
  @override
  final String wireName = 'RouteMetadataUpdateRouteQualityEnum';

  @override
  Object serialize(
          Serializers serializers, RouteMetadataUpdateRouteQualityEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteMetadataUpdateRouteQualityEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteMetadataUpdateRouteQualityEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteMetadataUpdateRoadConditionEnumSerializer
    implements PrimitiveSerializer<RouteMetadataUpdateRoadConditionEnum> {
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
    RouteMetadataUpdateRoadConditionEnum
  ];
  @override
  final String wireName = 'RouteMetadataUpdateRoadConditionEnum';

  @override
  Object serialize(
          Serializers serializers, RouteMetadataUpdateRoadConditionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RouteMetadataUpdateRoadConditionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RouteMetadataUpdateRoadConditionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RouteMetadataUpdate extends RouteMetadataUpdate {
  @override
  final RouteMetadataUpdateRouteQualityEnum? routeQuality;
  @override
  final RouteMetadataUpdateRoadConditionEnum? roadCondition;
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

  factory _$RouteMetadataUpdate(
          [void Function(RouteMetadataUpdateBuilder)? updates]) =>
      (RouteMetadataUpdateBuilder()..update(updates))._build();

  _$RouteMetadataUpdate._(
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
  RouteMetadataUpdate rebuild(
          void Function(RouteMetadataUpdateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteMetadataUpdateBuilder toBuilder() =>
      RouteMetadataUpdateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteMetadataUpdate &&
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
    return (newBuiltValueToStringHelper(r'RouteMetadataUpdate')
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

class RouteMetadataUpdateBuilder
    implements Builder<RouteMetadataUpdate, RouteMetadataUpdateBuilder> {
  _$RouteMetadataUpdate? _$v;

  RouteMetadataUpdateRouteQualityEnum? _routeQuality;
  RouteMetadataUpdateRouteQualityEnum? get routeQuality => _$this._routeQuality;
  set routeQuality(RouteMetadataUpdateRouteQualityEnum? routeQuality) =>
      _$this._routeQuality = routeQuality;

  RouteMetadataUpdateRoadConditionEnum? _roadCondition;
  RouteMetadataUpdateRoadConditionEnum? get roadCondition =>
      _$this._roadCondition;
  set roadCondition(RouteMetadataUpdateRoadConditionEnum? roadCondition) =>
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

  RouteMetadataUpdateBuilder() {
    RouteMetadataUpdate._defaults(this);
  }

  RouteMetadataUpdateBuilder get _$this {
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
  void replace(RouteMetadataUpdate other) {
    _$v = other as _$RouteMetadataUpdate;
  }

  @override
  void update(void Function(RouteMetadataUpdateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteMetadataUpdate build() => _build();

  _$RouteMetadataUpdate _build() {
    _$RouteMetadataUpdate _$result;
    try {
      _$result = _$v ??
          _$RouteMetadataUpdate._(
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
            r'RouteMetadataUpdate', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
