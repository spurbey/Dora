/// Camera runtime timing constants.
///
/// Keep these centralized so we can tune behavior per device class without
/// changing state-machine logic.
const Duration kCameraInitTimeout = Duration(seconds: 5);
const Duration kCameraInitRetryDelay = Duration(milliseconds: 500);
const Duration kStartRecordingTimeout = Duration(seconds: 3);
const Duration kStopRecordingTimeout = Duration(seconds: 5);
const Duration kPersistTimeout = Duration(seconds: 10);
const Duration kBackgroundTier2Threshold = Duration(seconds: 10);
const Duration kInactivePromotionThreshold = Duration(seconds: 10);
const Duration kResumeFastPathProbeTimeout = Duration(milliseconds: 700);

const int kMinimumRecordingStorageBytes = 100 * 1024 * 1024; // 100 MB
const Duration kRecordingStoragePollInterval = Duration(seconds: 10);
const Duration kMinimumRecordingDuration = Duration(seconds: 1);
const Duration kDefaultRecordingMaxDuration = Duration(seconds: 60);
const Duration kTempCaptureTtl = Duration(hours: 24);
