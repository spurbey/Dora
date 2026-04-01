// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_media_accepted_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TrackingMediaAcceptedResponse extends TrackingMediaAcceptedResponse {
  @override
  final String clientMediaId;
  @override
  final String mediaId;
  @override
  final bool duplicate;

  factory _$TrackingMediaAcceptedResponse(
          [void Function(TrackingMediaAcceptedResponseBuilder)? updates]) =>
      (TrackingMediaAcceptedResponseBuilder()..update(updates))._build();

  _$TrackingMediaAcceptedResponse._(
      {required this.clientMediaId,
      required this.mediaId,
      required this.duplicate})
      : super._();
  @override
  TrackingMediaAcceptedResponse rebuild(
          void Function(TrackingMediaAcceptedResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TrackingMediaAcceptedResponseBuilder toBuilder() =>
      TrackingMediaAcceptedResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TrackingMediaAcceptedResponse &&
        clientMediaId == other.clientMediaId &&
        mediaId == other.mediaId &&
        duplicate == other.duplicate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientMediaId.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, duplicate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TrackingMediaAcceptedResponse')
          ..add('clientMediaId', clientMediaId)
          ..add('mediaId', mediaId)
          ..add('duplicate', duplicate))
        .toString();
  }
}

class TrackingMediaAcceptedResponseBuilder
    implements
        Builder<TrackingMediaAcceptedResponse,
            TrackingMediaAcceptedResponseBuilder> {
  _$TrackingMediaAcceptedResponse? _$v;

  String? _clientMediaId;
  String? get clientMediaId => _$this._clientMediaId;
  set clientMediaId(String? clientMediaId) =>
      _$this._clientMediaId = clientMediaId;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  bool? _duplicate;
  bool? get duplicate => _$this._duplicate;
  set duplicate(bool? duplicate) => _$this._duplicate = duplicate;

  TrackingMediaAcceptedResponseBuilder() {
    TrackingMediaAcceptedResponse._defaults(this);
  }

  TrackingMediaAcceptedResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientMediaId = $v.clientMediaId;
      _mediaId = $v.mediaId;
      _duplicate = $v.duplicate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TrackingMediaAcceptedResponse other) {
    _$v = other as _$TrackingMediaAcceptedResponse;
  }

  @override
  void update(void Function(TrackingMediaAcceptedResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TrackingMediaAcceptedResponse build() => _build();

  _$TrackingMediaAcceptedResponse _build() {
    final _$result = _$v ??
        _$TrackingMediaAcceptedResponse._(
          clientMediaId: BuiltValueNullFieldError.checkNotNull(
              clientMediaId, r'TrackingMediaAcceptedResponse', 'clientMediaId'),
          mediaId: BuiltValueNullFieldError.checkNotNull(
              mediaId, r'TrackingMediaAcceptedResponse', 'mediaId'),
          duplicate: BuiltValueNullFieldError.checkNotNull(
              duplicate, r'TrackingMediaAcceptedResponse', 'duplicate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
