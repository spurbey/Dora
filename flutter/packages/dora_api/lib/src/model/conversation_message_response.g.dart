// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationMessageResponse extends ConversationMessageResponse {
  @override
  final String id;
  @override
  final String tripId;
  @override
  final String userId;
  @override
  final String role;
  @override
  final String messageType;
  @override
  final String? content;
  @override
  final JsonObject? messageMetadata;
  @override
  final String? advisoryJobId;
  @override
  final String? advisoryId;
  @override
  final DateTime createdAt;

  factory _$ConversationMessageResponse(
          [void Function(ConversationMessageResponseBuilder)? updates]) =>
      (ConversationMessageResponseBuilder()..update(updates))._build();

  _$ConversationMessageResponse._(
      {required this.id,
      required this.tripId,
      required this.userId,
      required this.role,
      required this.messageType,
      this.content,
      this.messageMetadata,
      this.advisoryJobId,
      this.advisoryId,
      required this.createdAt})
      : super._();
  @override
  ConversationMessageResponse rebuild(
          void Function(ConversationMessageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationMessageResponseBuilder toBuilder() =>
      ConversationMessageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationMessageResponse &&
        id == other.id &&
        tripId == other.tripId &&
        userId == other.userId &&
        role == other.role &&
        messageType == other.messageType &&
        content == other.content &&
        messageMetadata == other.messageMetadata &&
        advisoryJobId == other.advisoryJobId &&
        advisoryId == other.advisoryId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, tripId.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, messageType.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, messageMetadata.hashCode);
    _$hash = $jc(_$hash, advisoryJobId.hashCode);
    _$hash = $jc(_$hash, advisoryId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConversationMessageResponse')
          ..add('id', id)
          ..add('tripId', tripId)
          ..add('userId', userId)
          ..add('role', role)
          ..add('messageType', messageType)
          ..add('content', content)
          ..add('messageMetadata', messageMetadata)
          ..add('advisoryJobId', advisoryJobId)
          ..add('advisoryId', advisoryId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class ConversationMessageResponseBuilder
    implements
        Builder<ConversationMessageResponse,
            ConversationMessageResponseBuilder> {
  _$ConversationMessageResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _tripId;
  String? get tripId => _$this._tripId;
  set tripId(String? tripId) => _$this._tripId = tripId;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _role;
  String? get role => _$this._role;
  set role(String? role) => _$this._role = role;

  String? _messageType;
  String? get messageType => _$this._messageType;
  set messageType(String? messageType) => _$this._messageType = messageType;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  JsonObject? _messageMetadata;
  JsonObject? get messageMetadata => _$this._messageMetadata;
  set messageMetadata(JsonObject? messageMetadata) =>
      _$this._messageMetadata = messageMetadata;

  String? _advisoryJobId;
  String? get advisoryJobId => _$this._advisoryJobId;
  set advisoryJobId(String? advisoryJobId) =>
      _$this._advisoryJobId = advisoryJobId;

  String? _advisoryId;
  String? get advisoryId => _$this._advisoryId;
  set advisoryId(String? advisoryId) => _$this._advisoryId = advisoryId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  ConversationMessageResponseBuilder() {
    ConversationMessageResponse._defaults(this);
  }

  ConversationMessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _tripId = $v.tripId;
      _userId = $v.userId;
      _role = $v.role;
      _messageType = $v.messageType;
      _content = $v.content;
      _messageMetadata = $v.messageMetadata;
      _advisoryJobId = $v.advisoryJobId;
      _advisoryId = $v.advisoryId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationMessageResponse other) {
    _$v = other as _$ConversationMessageResponse;
  }

  @override
  void update(void Function(ConversationMessageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationMessageResponse build() => _build();

  _$ConversationMessageResponse _build() {
    final _$result = _$v ??
        _$ConversationMessageResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ConversationMessageResponse', 'id'),
          tripId: BuiltValueNullFieldError.checkNotNull(
              tripId, r'ConversationMessageResponse', 'tripId'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'ConversationMessageResponse', 'userId'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'ConversationMessageResponse', 'role'),
          messageType: BuiltValueNullFieldError.checkNotNull(
              messageType, r'ConversationMessageResponse', 'messageType'),
          content: content,
          messageMetadata: messageMetadata,
          advisoryJobId: advisoryJobId,
          advisoryId: advisoryId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ConversationMessageResponse', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
