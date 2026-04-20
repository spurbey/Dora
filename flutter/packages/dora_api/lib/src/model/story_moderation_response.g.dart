// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_moderation_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StoryModerationResponse extends StoryModerationResponse {
  @override
  final String storyId;
  @override
  final String status;

  factory _$StoryModerationResponse(
          [void Function(StoryModerationResponseBuilder)? updates]) =>
      (StoryModerationResponseBuilder()..update(updates))._build();

  _$StoryModerationResponse._({required this.storyId, required this.status})
      : super._();
  @override
  StoryModerationResponse rebuild(
          void Function(StoryModerationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StoryModerationResponseBuilder toBuilder() =>
      StoryModerationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StoryModerationResponse &&
        storyId == other.storyId &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, storyId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StoryModerationResponse')
          ..add('storyId', storyId)
          ..add('status', status))
        .toString();
  }
}

class StoryModerationResponseBuilder
    implements
        Builder<StoryModerationResponse, StoryModerationResponseBuilder> {
  _$StoryModerationResponse? _$v;

  String? _storyId;
  String? get storyId => _$this._storyId;
  set storyId(String? storyId) => _$this._storyId = storyId;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  StoryModerationResponseBuilder() {
    StoryModerationResponse._defaults(this);
  }

  StoryModerationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _storyId = $v.storyId;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StoryModerationResponse other) {
    _$v = other as _$StoryModerationResponse;
  }

  @override
  void update(void Function(StoryModerationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StoryModerationResponse build() => _build();

  _$StoryModerationResponse _build() {
    final _$result = _$v ??
        _$StoryModerationResponse._(
          storyId: BuiltValueNullFieldError.checkNotNull(
              storyId, r'StoryModerationResponse', 'storyId'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'StoryModerationResponse', 'status'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
