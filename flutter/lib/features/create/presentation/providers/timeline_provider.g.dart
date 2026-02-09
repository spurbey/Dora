// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timelineStateHash() => r'48e84b4a97450d250f322c8000fc6eb9890e1ff9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [timelineState].
@ProviderFor(timelineState)
const timelineStateProvider = TimelineStateFamily();

/// See also [timelineState].
class TimelineStateFamily extends Family<TimelineState> {
  /// See also [timelineState].
  const TimelineStateFamily();

  /// See also [timelineState].
  TimelineStateProvider call(
    String tripId,
  ) {
    return TimelineStateProvider(
      tripId,
    );
  }

  @override
  TimelineStateProvider getProviderOverride(
    covariant TimelineStateProvider provider,
  ) {
    return call(
      provider.tripId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timelineStateProvider';
}

/// See also [timelineState].
class TimelineStateProvider extends AutoDisposeProvider<TimelineState> {
  /// See also [timelineState].
  TimelineStateProvider(
    String tripId,
  ) : this._internal(
          (ref) => timelineState(
            ref as TimelineStateRef,
            tripId,
          ),
          from: timelineStateProvider,
          name: r'timelineStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$timelineStateHash,
          dependencies: TimelineStateFamily._dependencies,
          allTransitiveDependencies:
              TimelineStateFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  TimelineStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tripId,
  }) : super.internal();

  final String tripId;

  @override
  Override overrideWith(
    TimelineState Function(TimelineStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimelineStateProvider._internal(
        (ref) => create(ref as TimelineStateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tripId: tripId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<TimelineState> createElement() {
    return _TimelineStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimelineStateProvider && other.tripId == tripId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tripId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimelineStateRef on AutoDisposeProviderRef<TimelineState> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _TimelineStateProviderElement
    extends AutoDisposeProviderElement<TimelineState> with TimelineStateRef {
  _TimelineStateProviderElement(super.provider);

  @override
  String get tripId => (origin as TimelineStateProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
