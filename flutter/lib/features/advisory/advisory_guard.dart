import 'package:dora/core/config/feature_flags.dart';

/// Central advisory feature gate.
///
/// Used by all advisory entry points (editor overflow menu, live capture
/// FAB, notification routing). Single place to gate — no scattered checks.
bool advisoryEnabled() => FeatureFlags.enableAdvisoryPipeline;
