import 'dart:io';

import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/auth_interceptor.dart';
import 'package:dora/core/network/retry_interceptor.dart';

class ApiClient {
  ApiClient({required String baseUrl, required AuthService authService}) {
    _dio = Dio(BaseOptions(baseUrl: _resolveBaseUrl(baseUrl)));

    _dio.interceptors.addAll([
      AuthInterceptor(authService),
      RetryInterceptor(_dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  static String _resolveBaseUrl(String baseUrl) {
    final parsed = Uri.tryParse(baseUrl);
    if (parsed == null) {
      return baseUrl;
    }

    // Android emulator can't reach host machine via localhost.
    if (Platform.isAndroid &&
        (parsed.host == 'localhost' || parsed.host == '127.0.0.1')) {
      return parsed.replace(host: '10.0.2.2').toString();
    }

    return baseUrl;
  }
}
