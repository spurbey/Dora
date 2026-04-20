// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_feed_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StoryFeedResponse extends StoryFeedResponse {
  @override
  final BuiltList<StoryResponse> stories;
  @override
  final String? nextCursor;

  factory _$StoryFeedResponse(
          [void Function(StoryFeedResponseBuilder)? updates]) =>
      (StoryFeedResponseBuilder()..update(updates))._build();

  _$StoryFeedResponse._({required this.stories, this.nextCursor}) : super._();
  @override
  StoryFeedResponse rebuild(void Function(StoryFeedResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StoryFeedResponseBuilder toBuilder() =>
      StoryFeedResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StoryFeedResponse &&
        stories == other.stories &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stories.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StoryFeedResponse')
          ..add('stories', stories)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class StoryFeedResponseBuilder
    implements Builder<StoryFeedResponse, StoryFeedResponseBuilder> {
  _$StoryFeedResponse? _$v;

  ListBuilder<StoryResponse>? _stories;
  ListBuilder<StoryResponse> get stories =>
      _$this._stories ??= ListBuilder<StoryResponse>();
  set stories(ListBuilder<StoryResponse>? stories) => _$this._stories = stories;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  StoryFeedResponseBuilder() {
    StoryFeedResponse._defaults(this);
  }

  StoryFeedResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stories = $v.stories.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StoryFeedResponse other) {
    _$v = other as _$StoryFeedResponse;
  }

  @override
  void update(void Function(StoryFeedResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StoryFeedResponse build() => _build();

  _$StoryFeedResponse _build() {
    _$StoryFeedResponse _$result;
    try {
      _$result = _$v ??
          _$StoryFeedResponse._(
            stories: stories.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'stories';
        stories.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'StoryFeedResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
