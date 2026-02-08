import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dora/core/config/env_config.dart';
import 'package:dora/core/network/api_client.dart';
import 'package:dora/features/auth/presentation/providers/auth_provider.dart';
import 'package:dora_api/dora_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiClient(baseUrl: Env.apiBaseUrl, authService: authService);
});

final tripsApiProvider = Provider<TripsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return TripsApi(client.dio, standardSerializers);
});

final placesApiProvider = Provider<PlacesApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return PlacesApi(client.dio, standardSerializers);
});

final routesApiProvider = Provider<RoutesApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return RoutesApi(client.dio, standardSerializers);
});

final componentsApiProvider = Provider<ComponentsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return ComponentsApi(client.dio, standardSerializers);
});

final searchApiProvider = Provider<SearchApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return SearchApi(client.dio, standardSerializers);
});
