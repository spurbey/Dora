// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripDetailControllerHash() =>
    r'4944c61c58da2e526fc69b1a0060c0f9512dde9c';

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

abstract class _$TripDetailController
    extends BuildlessAutoDisposeAsyncNotifier<TripDetailState> {
  late final String tripId;

  FutureOr<TripDetailState> build(
    String tripId,
  );
}

/// See also [TripDetailController].
@ProviderFor(TripDetailController)
const tripDetailControllerProvider = TripDetailControllerFamily();

/// See also [TripDetailController].
class TripDetailControllerFamily extends Family<AsyncValue<TripDetailState>> {
  /// See also [TripDetailController].
  const TripDetailControllerFamily();

  /// See also [TripDetailController].
  TripDetailControllerProvider call(
    String tripId,
  ) {
    return TripDetailControllerProvider(
      tripId,
    );
  }

  @override
  TripDetailControllerProvider getProviderOverride(
    covariant TripDetailControllerProvider provider,
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
  String? get name => r'tripDetailControllerProvider';
}

/// See also [TripDetailController].
class TripDetailControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    TripDetailController, TripDetailState> {
  /// See also [TripDetailController].
  TripDetailControllerProvider(
    String tripId,
  ) : this._internal(
          () => TripDetailController()..tripId = tripId,
          from: tripDetailControllerProvider,
          name: r'tripDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tripDetailControllerHash,
          dependencies: TripDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              TripDetailControllerFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  TripDetailControllerProvider._internal(
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
  FutureOr<TripDetailState> runNotifierBuild(
    covariant TripDetailController notifier,
  ) {
    return notifier.build(
      tripId,
    );
  }

  @override
  Override overrideWith(TripDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TripDetailControllerProvider._internal(
        () => create()..tripId = tripId,
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
  AutoDisposeAsyncNotifierProviderElement<TripDetailController, TripDetailState>
      createElement() {
    return _TripDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TripDetailControllerProvider && other.tripId == tripId;
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
mixin TripDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<TripDetailState> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _TripDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<TripDetailController,
        TripDetailState> with TripDetailControllerRef {
  _TripDetailControllerProviderElement(super.provider);

  @override
  String get tripId => (origin as TripDetailControllerProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
