import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/config/feature_flags.dart';

void main() {
  group('FeatureFlags V2 defaults', () {
    test('all V2 flags are disabled by default', () {
      expect(FeatureFlags.enableLiveSystemV2, isFalse);
      expect(FeatureFlags.enableV2LocalJournal, isFalse);
      expect(FeatureFlags.enableV2LocalCompiler, isFalse);
      expect(FeatureFlags.enableV2SessionCommitWorker, isFalse);
      expect(FeatureFlags.enableV2TripPublishWorker, isFalse);
      expect(FeatureFlags.enableV2BackendIngest, isFalse);
      expect(FeatureFlags.enableV2LiveEditorUiContract, isFalse);
    });
  });
}
