// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_mute_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StoryMuteResponse extends StoryMuteResponse {
  @override
  final String mutedAuthorId;
  @override
  final bool muted;

  factory _$StoryMuteResponse(
          [void Function(StoryMuteResponseBuilder)? updates]) =>
      (StoryMuteResponseBuilder()..update(updates))._build();

  _$StoryMuteResponse._({required this.mutedAuthorId, required this.muted})
      : super._();
  @override
  StoryMuteResponse rebuild(void Function(StoryMuteResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StoryMuteResponseBuilder toBuilder() =>
      StoryMuteResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StoryMuteResponse &&
        mutedAuthorId == other.mutedAuthorId &&
        muted == other.muted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutedAuthorId.hashCode);
    _$hash = $jc(_$hash, muted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StoryMuteResponse')
          ..add('mutedAuthorId', mutedAuthorId)
          ..add('muted', muted))
        .toString();
  }
}

class StoryMuteResponseBuilder
    implements Builder<StoryMuteResponse, StoryMuteResponseBuilder> {
  _$StoryMuteResponse? _$v;

  String? _mutedAuthorId;
  String? get mutedAuthorId => _$this._mutedAuthorId;
  set mutedAuthorId(String? mutedAuthorId) =>
      _$this._mutedAuthorId = mutedAuthorId;

  bool? _muted;
  bool? get muted => _$this._muted;
  set muted(bool? muted) => _$this._muted = muted;

  StoryMuteResponseBuilder() {
    StoryMuteResponse._defaults(this);
  }

  StoryMuteResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutedAuthorId = $v.mutedAuthorId;
      _muted = $v.muted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StoryMuteResponse other) {
    _$v = other as _$StoryMuteResponse;
  }

  @override
  void update(void Function(StoryMuteResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StoryMuteResponse build() => _build();

  _$StoryMuteResponse _build() {
    final _$result = _$v ??
        _$StoryMuteResponse._(
          mutedAuthorId: BuiltValueNullFieldError.checkNotNull(
              mutedAuthorId, r'StoryMuteResponse', 'mutedAuthorId'),
          muted: BuiltValueNullFieldError.checkNotNull(
              muted, r'StoryMuteResponse', 'muted'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
