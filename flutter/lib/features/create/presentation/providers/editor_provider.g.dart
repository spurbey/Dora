// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tripRepositoryHash() => r'06698f5048a4cc221361756a4b2aa9cac24e44d8';

/// See also [tripRepository].
@ProviderFor(tripRepository)
final tripRepositoryProvider = AutoDisposeProvider<TripRepository>.internal(
  tripRepository,
  name: r'tripRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripRepositoryRef = AutoDisposeProviderRef<TripRepository>;
String _$placeRepositoryHash() => r'8d35e0e7073e1fe18c6daab5f31f2fbefb322d67';

/// See also [placeRepository].
@ProviderFor(placeRepository)
final placeRepositoryProvider = AutoDisposeProvider<PlaceRepository>.internal(
  placeRepository,
  name: r'placeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$placeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlaceRepositoryRef = AutoDisposeProviderRef<PlaceRepository>;
String _$routeRepositoryHash() => r'325e6479d3f11f54d3c5c4b558057ee01534c75c';

/// See also [routeRepository].
@ProviderFor(routeRepository)
final routeRepositoryProvider = AutoDisposeProvider<RouteRepository>.internal(
  routeRepository,
  name: r'routeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouteRepositoryRef = AutoDisposeProviderRef<RouteRepository>;
String _$editorControllerHash() => r'c129bbde2c32812a1a1613c2e544b373f9b49887';

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

abstract class _$EditorController
    extends BuildlessAutoDisposeAsyncNotifier<EditorState> {
  late final String tripId;

  FutureOr<EditorState> build(
    String tripId,
  );
}

/// See also [EditorController].
@ProviderFor(EditorController)
const editorControllerProvider = EditorControllerFamily();

/// See also [EditorController].
class EditorControllerFamily extends Family<AsyncValue<EditorState>> {
  /// See also [EditorController].
  const EditorControllerFamily();

  /// See also [EditorController].
  EditorControllerProvider call(
    String tripId,
  ) {
    return EditorControllerProvider(
      tripId,
    );
  }

  @override
  EditorControllerProvider getProviderOverride(
    covariant EditorControllerProvider provider,
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
  String? get name => r'editorControllerProvider';
}

/// See also [EditorController].
class EditorControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    EditorController, EditorState> {
  /// See also [EditorController].
  EditorControllerProvider(
    String tripId,
  ) : this._internal(
          () => EditorController()..tripId = tripId,
          from: editorControllerProvider,
          name: r'editorControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$editorControllerHash,
          dependencies: EditorControllerFamily._dependencies,
          allTransitiveDependencies:
              EditorControllerFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  EditorControllerProvider._internal(
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
  FutureOr<EditorState> runNotifierBuild(
    covariant EditorController notifier,
  ) {
    return notifier.build(
      tripId,
    );
  }

  @override
  Override overrideWith(EditorController Function() create) {
    return ProviderOverride(
      origin: this,
      override: EditorControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<EditorController, EditorState>
      createElement() {
    return _EditorControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditorControllerProvider && other.tripId == tripId;
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
mixin EditorControllerRef on AutoDisposeAsyncNotifierProviderRef<EditorState> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _EditorControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<EditorController,
        EditorState> with EditorControllerRef {
  _EditorControllerProviderElement(super.provider);

  @override
  String get tripId => (origin as EditorControllerProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
