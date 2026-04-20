import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRouteObserverProvider =
    Provider<RouteObserver<PageRoute<dynamic>>>((ref) {
  return RouteObserver<PageRoute<dynamic>>();
});
