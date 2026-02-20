import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:dora/core/map/directions/app_directions_service.dart';
import 'package:dora/core/map/directions/backend_directions_adapter.dart';
import 'package:dora/core/network/api_providers.dart';

part 'directions_provider.g.dart';

@riverpod
AppDirectionsService directionsService(DirectionsServiceRef ref) {
  final dio = ref.watch(apiClientProvider).dio;
  return BackendDirectionsAdapter(dio);
}
