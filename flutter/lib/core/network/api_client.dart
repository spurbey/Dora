import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/auth_interceptor.dart';
import 'package:dora/core/network/retry_interceptor.dart';

class ApiClient {
  ApiClient({required String baseUrl, required AuthService authService}) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl));

    _dio.interceptors.addAll([
      AuthInterceptor(authService),
      RetryInterceptor(_dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
