// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mapStateHash() => r'ee963560b33adc589168ba512acc45b2f4238af3';

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

/// See also [mapState].
@ProviderFor(mapState)
const mapStateProvider = MapStateFamily();

/// See also [mapState].
class MapStateFamily extends Family<MapState> {
  /// See also [mapState].
  const MapStateFamily();

  /// See also [mapState].
  MapStateProvider call(
    String tripId,
  ) {
    return MapStateProvider(
      tripId,
    );
  }

  @override
  MapStateProvider getProviderOverride(
    covariant MapStateProvider provider,
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
  String? get name => r'mapStateProvider';
}

/// See also [mapState].
class MapStateProvider extends AutoDisposeProvider<MapState> {
  /// See also [mapState].
  MapStateProvider(
    String tripId,
  ) : this._internal(
          (ref) => mapState(
            ref as MapStateRef,
            tripId,
          ),
          from: mapStateProvider,
          name: r'mapStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mapStateHash,
          dependencies: MapStateFamily._dependencies,
          allTransitiveDependencies: MapStateFamily._allTransitiveDependencies,
          tripId: tripId,
        );

  MapStateProvider._internal(
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
    MapState Function(MapStateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MapStateProvider._internal(
        (ref) => create(ref as MapStateRef),
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
  AutoDisposeProviderElement<MapState> createElement() {
    return _MapStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MapStateProvider && other.tripId == tripId;
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
mixin MapStateRef on AutoDisposeProviderRef<MapState> {
  /// The parameter `tripId` of this provider.
  String get tripId;
}

class _MapStateProviderElement extends AutoDisposeProviderElement<MapState>
    with MapStateRef {
  _MapStateProviderElement(super.provider);

  @override
  String get tripId => (origin as MapStateProvider).tripId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
