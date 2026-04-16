// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advisory_job_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AdvisoryJobStatus _$queued = const AdvisoryJobStatus._('queued');
const AdvisoryJobStatus _$processing = const AdvisoryJobStatus._('processing');
const AdvisoryJobStatus _$cancelRequested =
    const AdvisoryJobStatus._('cancelRequested');
const AdvisoryJobStatus _$completed = const AdvisoryJobStatus._('completed');
const AdvisoryJobStatus _$failed = const AdvisoryJobStatus._('failed');
const AdvisoryJobStatus _$canceled = const AdvisoryJobStatus._('canceled');
const AdvisoryJobStatus _$blocked = const AdvisoryJobStatus._('blocked');

AdvisoryJobStatus _$valueOf(String name) {
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

final BuiltSet<AdvisoryJobStatus> _$values =
    BuiltSet<AdvisoryJobStatus>(const <AdvisoryJobStatus>[
  _$queued,
  _$processing,
  _$cancelRequested,
  _$completed,
  _$failed,
  _$canceled,
  _$blocked,
]);

class _$AdvisoryJobStatusMeta {
  const _$AdvisoryJobStatusMeta();
  AdvisoryJobStatus get queued => _$queued;
  AdvisoryJobStatus get processing => _$processing;
  AdvisoryJobStatus get cancelRequested => _$cancelRequested;
  AdvisoryJobStatus get completed => _$completed;
  AdvisoryJobStatus get failed => _$failed;
  AdvisoryJobStatus get canceled => _$canceled;
  AdvisoryJobStatus get blocked => _$blocked;
  AdvisoryJobStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<AdvisoryJobStatus> get values => _$values;
}

abstract class _$AdvisoryJobStatusMixin {
  // ignore: non_constant_identifier_names
  _$AdvisoryJobStatusMeta get AdvisoryJobStatus =>
      const _$AdvisoryJobStatusMeta();
}

Serializer<AdvisoryJobStatus> _$advisoryJobStatusSerializer =
    _$AdvisoryJobStatusSerializer();

class _$AdvisoryJobStatusSerializer
    implements PrimitiveSerializer<AdvisoryJobStatus> {
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
  final Iterable<Type> types = const <Type>[AdvisoryJobStatus];
  @override
  final String wireName = 'AdvisoryJobStatus';

  @override
  Object serialize(Serializers serializers, AdvisoryJobStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AdvisoryJobStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AdvisoryJobStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
