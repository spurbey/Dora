import 'package:dio/dio.dart';

import 'package:dora/core/auth/auth_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._authTokenProvider);

  final Dio _dio;
  final AuthTokenProvider _authTokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authTokenProvider.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != 401) {
      return handler.next(err);
    }

    final request = err.requestOptions;
    final retried = request.extra['authRetried'] == true;
    if (retried) {
      return handler.next(err);
    }

    final refreshedToken =
        await _authTokenProvider.refreshAccessToken(force: true);
    if (refreshedToken == null || refreshedToken.isEmpty) {
      return handler.next(err);
    }

    final headers = Map<String, dynamic>.from(request.headers);
    headers['Authorization'] = 'Bearer $refreshedToken';
    headers['authorization'] = 'Bearer $refreshedToken';

    final retryOptions = request.copyWith(
      headers: headers,
      extra: <String, dynamic>{
        ...request.extra,
        'authRetried': true,
      },
    );

    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    } catch (_) {
      return handler.next(err);
    }
  }
}
