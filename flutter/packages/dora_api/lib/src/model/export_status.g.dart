// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ExportStatus _$queued = const ExportStatus._('queued');
const ExportStatus _$processing = const ExportStatus._('processing');
const ExportStatus _$cancelRequested = const ExportStatus._('cancelRequested');
const ExportStatus _$completed = const ExportStatus._('completed');
const ExportStatus _$failed = const ExportStatus._('failed');
const ExportStatus _$canceled = const ExportStatus._('canceled');
const ExportStatus _$blocked = const ExportStatus._('blocked');

ExportStatus _$valueOf(String name) {
  switch (name) {
    case 'queued':
      return _$queued;
    case 'processing':
      return _$processing;
    case 'cancelRequested':
      return _$cancelRequested;
    case 'completed':
      return _$completed;
    case 'failed':
      return _$failed;
    case 'canceled':
      return _$canceled;
    case 'blocked':
      return _$blocked;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ExportStatus> _$values =
    BuiltSet<ExportStatus>(const <ExportStatus>[
  _$queued,
  _$processing,
  _$cancelRequested,
  _$completed,
  _$failed,
  _$canceled,
  _$blocked,
]);

class _$ExportStatusMeta {
  const _$ExportStatusMeta();
  ExportStatus get queued => _$queued;
  ExportStatus get processing => _$processing;
  ExportStatus get cancelRequested => _$cancelRequested;
  ExportStatus get completed => _$completed;
  ExportStatus get failed => _$failed;
  ExportStatus get canceled => _$canceled;
  ExportStatus get blocked => _$blocked;
  ExportStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ExportStatus> get values => _$values;
}

abstract class _$ExportStatusMixin {
  // ignore: non_constant_identifier_names
  _$ExportStatusMeta get ExportStatus => const _$ExportStatusMeta();
}

Serializer<ExportStatus> _$exportStatusSerializer = _$ExportStatusSerializer();

class _$ExportStatusSerializer implements PrimitiveSerializer<ExportStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'queued': 'queued',
    'processing': 'processing',
    'cancelRequested': 'cancel_requested',
    'completed': 'completed',
    'failed': 'failed',
    'canceled': 'canceled',
    'blocked': 'blocked',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'queued': 'queued',
    'processing': 'processing',
    'cancel_requested': 'cancelRequested',
    'completed': 'completed',
    'failed': 'failed',
    'canceled': 'canceled',
    'blocked': 'blocked',
  };

  @override
  final Iterable<Type> types = const <Type>[ExportStatus];
  @override
  final String wireName = 'ExportStatus';

  @override
  Object serialize(Serializers serializers, ExportStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ExportStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ExportStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
