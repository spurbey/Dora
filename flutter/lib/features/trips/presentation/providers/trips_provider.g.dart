// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userTripsApiHash() => r'69ce23c58cae3f97ca1209161ecb225f2a5cac9e';

/// See also [userTripsApi].
@ProviderFor(userTripsApi)
final userTripsApiProvider = AutoDisposeProvider<TripsApi>.internal(
  userTripsApi,
  name: r'userTripsApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userTripsApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserTripsApiRef = AutoDisposeProviderRef<TripsApi>;
String _$tripsRepositoryHash() => r'eeb8086e9ea56cb8ce38356121667785a6cd5298';

/// See also [tripsRepository].
@ProviderFor(tripsRepository)
final tripsRepositoryProvider = AutoDisposeProvider<TripsRepository>.internal(
  tripsRepository,
  name: r'tripsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TripsRepositoryRef = AutoDisposeProviderRef<TripsRepository>;
String _$tripsControllerHash() => r'9a9e2e2f44cf10005a90d8dda3de8a700e24c6c1';

/// See also [TripsController].
@ProviderFor(TripsController)
final tripsControllerProvider =
    AutoDisposeAsyncNotifierProvider<TripsController, TripsState>.internal(
  TripsController.new,
  name: r'tripsControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tripsControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TripsController = AutoDisposeAsyncNotifier<TripsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
