import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._authService);

  final AuthService _authService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
