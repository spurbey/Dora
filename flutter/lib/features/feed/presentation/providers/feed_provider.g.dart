// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedRepositoryHash() => r'bbd5c0cae91864cb07f8193f071132eb397ee5b7';

/// See also [feedRepository].
@ProviderFor(feedRepository)
final feedRepositoryProvider = AutoDisposeProvider<FeedRepository>.internal(
  feedRepository,
  name: r'feedRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedRepositoryRef = AutoDisposeProviderRef<FeedRepository>;
String _$feedApiHash() => r'11582688d4205c608f1b5d3e8e32498d23900612';

/// See also [feedApi].
@ProviderFor(feedApi)
final feedApiProvider = AutoDisposeProvider<FeedApi>.internal(
  feedApi,
  name: r'feedApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$feedApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedApiRef = AutoDisposeProviderRef<FeedApi>;
String _$feedControllerHash() => r'10cc39dd5a33d9f106364f5602c0975d36f34edc';

/// See also [FeedController].
@ProviderFor(FeedController)
final feedControllerProvider =
    AutoDisposeAsyncNotifierProvider<FeedController, FeedState>.internal(
  FeedController.new,
  name: r'feedControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FeedController = AutoDisposeAsyncNotifier<FeedState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
