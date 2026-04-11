const String v2CommitStatePending = 'commit_pending';
const String v2CommitStateCommitting = 'committing';
const String v2CommitStateFailedRetryable = 'commit_failed_retryable';
const String v2CommitStateCommitted = 'committed';

const String v2CommitPhasePrepare = 'prepare';
const String v2CommitPhaseMediaUpload = 'media_upload';
const String v2CommitPhasePayloadUpload = 'payload_upload';
const String v2CommitPhaseFinalizeAck = 'finalize_ack';
const String v2CommitPhaseDone = 'done';

const Duration v2CommitLeaseTtl = Duration(minutes: 5);
const int v2CommitAutoRetryMaxAttempts = 3;
const List<Duration> v2CommitRetryBackoff = <Duration>[
  Duration(seconds: 15),
  Duration(seconds: 60),
  Duration(seconds: 180),
];

enum V2CommitTriggerSource {
  stop('stop'),
  resumed('resumed'),
  liveOpen('live_open'),
  editorOpen('editor_open'),
  manualRetry('manual_retry');

  const V2CommitTriggerSource(this.wireValue);
  final String wireValue;
}

class V2CommitSyncSnapshot {
  const V2CommitSyncSnapshot({
    required this.pendingJobs,
    required this.committingJobs,
    required this.failedJobs,
    required this.committedJobs,
  });

  final int pendingJobs;
  final int committingJobs;
  final int failedJobs;
  final int committedJobs;
}
