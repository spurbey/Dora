// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_list_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RouteListResponse extends RouteListResponse {
  @override
  final BuiltList<RouteResponse> routes;
  @override
  final int total;

  factory _$RouteListResponse(
          [void Function(RouteListResponseBuilder)? updates]) =>
      (RouteListResponseBuilder()..update(updates))._build();

  _$RouteListResponse._({required this.routes, required this.total})
      : super._();
  @override
  RouteListResponse rebuild(void Function(RouteListResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RouteListResponseBuilder toBuilder() =>
      RouteListResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RouteListResponse &&
        routes == other.routes &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, routes.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RouteListResponse')
          ..add('routes', routes)
          ..add('total', total))
        .toString();
  }
}

class RouteListResponseBuilder
    implements Builder<RouteListResponse, RouteListResponseBuilder> {
  _$RouteListResponse? _$v;

  ListBuilder<RouteResponse>? _routes;
  ListBuilder<RouteResponse> get routes =>
      _$this._routes ??= ListBuilder<RouteResponse>();
  set routes(ListBuilder<RouteResponse>? routes) => _$this._routes = routes;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  RouteListResponseBuilder() {
    RouteListResponse._defaults(this);
  }

  RouteListResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _routes = $v.routes.toBuilder();
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RouteListResponse other) {
    _$v = other as _$RouteListResponse;
  }

  @override
  void update(void Function(RouteListResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RouteListResponse build() => _build();

  _$RouteListResponse _build() {
    _$RouteListResponse _$result;
    try {
      _$result = _$v ??
          _$RouteListResponse._(
            routes: routes.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'RouteListResponse', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'routes';
        routes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RouteListResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
