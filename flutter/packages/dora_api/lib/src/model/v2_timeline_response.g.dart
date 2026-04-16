// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'v2_timeline_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$V2TimelineResponse extends V2TimelineResponse {
  @override
  final BuiltList<V2TimelineEntryResponse>? entries;
  @override
  final String? nextCursor;
  @override
  final bool hasMore;
  @override
  final DateTime? compiledAt;
  @override
  final int compilerVersion;

  factory _$V2TimelineResponse(
          [void Function(V2TimelineResponseBuilder)? updates]) =>
      (V2TimelineResponseBuilder()..update(updates))._build();

  _$V2TimelineResponse._(
      {this.entries,
      this.nextCursor,
      required this.hasMore,
      this.compiledAt,
      required this.compilerVersion})
      : super._();
  @override
  V2TimelineResponse rebuild(
          void Function(V2TimelineResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  V2TimelineResponseBuilder toBuilder() =>
      V2TimelineResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is V2TimelineResponse &&
        entries == other.entries &&
        nextCursor == other.nextCursor &&
        hasMore == other.hasMore &&
        compiledAt == other.compiledAt &&
        compilerVersion == other.compilerVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, entries.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, compiledAt.hashCode);
    _$hash = $jc(_$hash, compilerVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'V2TimelineResponse')
          ..add('entries', entries)
          ..add('nextCursor', nextCursor)
          ..add('hasMore', hasMore)
          ..add('compiledAt', compiledAt)
          ..add('compilerVersion', compilerVersion))
        .toString();
  }
}

class V2TimelineResponseBuilder
    implements Builder<V2TimelineResponse, V2TimelineResponseBuilder> {
  _$V2TimelineResponse? _$v;

  ListBuilder<V2TimelineEntryResponse>? _entries;
  ListBuilder<V2TimelineEntryResponse> get entries =>
      _$this._entries ??= ListBuilder<V2TimelineEntryResponse>();
  set entries(ListBuilder<V2TimelineEntryResponse>? entries) =>
      _$this._entries = entries;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  DateTime? _compiledAt;
  DateTime? get compiledAt => _$this._compiledAt;
  set compiledAt(DateTime? compiledAt) => _$this._compiledAt = compiledAt;

  int? _compilerVersion;
  int? get compilerVersion => _$this._compilerVersion;
  set compilerVersion(int? compilerVersion) =>
      _$this._compilerVersion = compilerVersion;

  V2TimelineResponseBuilder() {
    V2TimelineResponse._defaults(this);
  }

  V2TimelineResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _entries = $v.entries?.toBuilder();
      _nextCursor = $v.nextCursor;
      _hasMore = $v.hasMore;
      _compiledAt = $v.compiledAt;
      _compilerVersion = $v.compilerVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(V2TimelineResponse other) {
    _$v = other as _$V2TimelineResponse;
  }

  @override
  void update(void Function(V2TimelineResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  V2TimelineResponse build() => _build();

  _$V2TimelineResponse _build() {
    _$V2TimelineResponse _$result;
    try {
      _$result = _$v ??
          _$V2TimelineResponse._(
            entries: _entries?.build(),
            nextCursor: nextCursor,
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'V2TimelineResponse', 'hasMore'),
            compiledAt: compiledAt,
            compilerVersion: BuiltValueNullFieldError.checkNotNull(
                compilerVersion, r'V2TimelineResponse', 'compilerVersion'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'entries';
        _entries?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'V2TimelineResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
