// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_media_batch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingMediaBatchRequest extends TrackingMediaBatchRequest {
  @override
  final BuiltList<TrackingMediaInput>? media;

  factory _$TrackingMediaBatchRequest(
          [void Function(TrackingMediaBatchRequestBuilder)? updates]) =>
      (TrackingMediaBatchRequestBuilder()..update(updates))._build();

  _$TrackingMediaBatchRequest._({this.media}) : super._();
  @override
  TrackingMediaBatchRequest rebuild(
          void Function(TrackingMediaBatchRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingMediaBatchRequestBuilder toBuilder() =>
      TrackingMediaBatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingMediaBatchRequest && media == other.media;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, media.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingMediaBatchRequest')
          ..add('media', media))
        .toString();
  }
}

class TrackingMediaBatchRequestBuilder
    implements
        Builder<TrackingMediaBatchRequest, TrackingMediaBatchRequestBuilder> {
  _$TrackingMediaBatchRequest? _$v;

  ListBuilder<TrackingMediaInput>? _media;
  ListBuilder<TrackingMediaInput> get media =>
      _$this._media ??= ListBuilder<TrackingMediaInput>();
  set media(ListBuilder<TrackingMediaInput>? media) => _$this._media = media;

  TrackingMediaBatchRequestBuilder() {
    TrackingMediaBatchRequest._defaults(this);
  }

  TrackingMediaBatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _media = $v.media?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingMediaBatchRequest other) {
    _$v = other as _$TrackingMediaBatchRequest;
  }

  @override
  void update(void Function(TrackingMediaBatchRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingMediaBatchRequest build() => _build();

  _$TrackingMediaBatchRequest _build() {
    _$TrackingMediaBatchRequest _$result;
    try {
      _$result = _$v ??
          _$TrackingMediaBatchRequest._(
            media: _media?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'media';
        _media?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TrackingMediaBatchRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
