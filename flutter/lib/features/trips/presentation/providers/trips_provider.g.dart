// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trips_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userTripsApiHash() => r'0a66d8073b01c6f3712e2dc7a92bcf311c57a72c';

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
String _$tripsRepositoryHash() => r'e53087286bc79e566ee6d8cd8432ef9a39f7fff9';

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
String _$tripsControllerHash() => r'ef5050e2b8018ad620d318b02085e03b831899f3';

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
