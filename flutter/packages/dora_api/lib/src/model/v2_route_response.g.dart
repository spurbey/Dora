// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_route_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2RouteResponse extends V2RouteResponse {
  @override
  final BuiltList<V2RouteSegmentResponse>? segments;
  @override
  final bool hasMore;
  @override
  final String? nextCursor;
  @override
  final DateTime? compiledAt;
  @override
  final int compilerVersion;

  factory _$V2RouteResponse([void Function(V2RouteResponseBuilder)? updates]) =>
      (V2RouteResponseBuilder()..update(updates))._build();

  _$V2RouteResponse._(
      {this.segments,
      required this.hasMore,
      this.nextCursor,
      this.compiledAt,
      required this.compilerVersion})
      : super._();
  @override
  V2RouteResponse rebuild(void Function(V2RouteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2RouteResponseBuilder toBuilder() => V2RouteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2RouteResponse &&
        segments == other.segments &&
        hasMore == other.hasMore &&
        nextCursor == other.nextCursor &&
        compiledAt == other.compiledAt &&
        compilerVersion == other.compilerVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, segments.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, compiledAt.hashCode);
    _$hash = $jc(_$hash, compilerVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2RouteResponse')
          ..add('segments', segments)
          ..add('hasMore', hasMore)
          ..add('nextCursor', nextCursor)
          ..add('compiledAt', compiledAt)
          ..add('compilerVersion', compilerVersion))
        .toString();
  }
}

class V2RouteResponseBuilder
    implements Builder<V2RouteResponse, V2RouteResponseBuilder> {
  _$V2RouteResponse? _$v;

  ListBuilder<V2RouteSegmentResponse>? _segments;
  ListBuilder<V2RouteSegmentResponse> get segments =>
      _$this._segments ??= ListBuilder<V2RouteSegmentResponse>();
  set segments(ListBuilder<V2RouteSegmentResponse>? segments) =>
      _$this._segments = segments;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  DateTime? _compiledAt;
  DateTime? get compiledAt => _$this._compiledAt;
  set compiledAt(DateTime? compiledAt) => _$this._compiledAt = compiledAt;

  int? _compilerVersion;
  int? get compilerVersion => _$this._compilerVersion;
  set compilerVersion(int? compilerVersion) =>
      _$this._compilerVersion = compilerVersion;

  V2RouteResponseBuilder() {
    V2RouteResponse._defaults(this);
  }

  V2RouteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _segments = $v.segments?.toBuilder();
      _hasMore = $v.hasMore;
      _nextCursor = $v.nextCursor;
      _compiledAt = $v.compiledAt;
      _compilerVersion = $v.compilerVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2RouteResponse other) {
    _$v = other as _$V2RouteResponse;
  }

  @override
  void update(void Function(V2RouteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2RouteResponse build() => _build();

  _$V2RouteResponse _build() {
    _$V2RouteResponse _$result;
    try {
      _$result = _$v ??
          _$V2RouteResponse._(
            segments: _segments?.build(),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'V2RouteResponse', 'hasMore'),
            nextCursor: nextCursor,
            compiledAt: compiledAt,
            compilerVersion: BuiltValueNullFieldError.checkNotNull(
                compilerVersion, r'V2RouteResponse', 'compilerVersion'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'segments';
        _segments?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'V2RouteResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
