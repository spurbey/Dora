import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dora/core/auth/auth_service.dart';
import 'package:dora/core/network/auth_interceptor.dart';

class _FakeAuthTokenProvider implements AuthTokenProvider {
  _FakeAuthTokenProvider({
    required this.token,
    required this.refreshedToken,
  });

  String? token;
  final String? refreshedToken;
  int getCalls = 0;
  int refreshCalls = 0;

  @override
  Future<String?> getAccessToken() async {
    getCalls += 1;
    return token;
  }

  @override
  Future<String?> refreshAccessToken({bool force = false}) async {
    refreshCalls += 1;
    if (refreshedToken != null && refreshedToken!.isNotEmpty) {
      token = refreshedToken;
    }
    return refreshedToken;
  }
}

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this.statuses, {this.body = '{"ok": true}'});

  final List<int> statuses;
  final String body;
  final List<RequestOptions> captured = <RequestOptions>[];
  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured.add(options);
    final status = statuses[
        _index < statuses.length ? _index : statuses.length - 1];
    _index += 1;
    return ResponseBody.fromString(
      body,
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('AuthInterceptor', () {
    test('retries once on 401 after token refresh', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final adapter = _QueueAdapter(<int>[401, 200]);
      final tokenProvider = _FakeAuthTokenProvider(
        token: 'old-token',
        refreshedToken: 'new-token',
      );
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(dio, tokenProvider));

      final response = await dio.get<dynamic>('/api/v1/trips');

      expect(response.statusCode, 200);
      expect(tokenProvider.refreshCalls, 1);
      expect(adapter.captured.length, 2);
      expect(adapter.captured.first.headers['Authorization'], 'Bearer old-token');
      expect(adapter.captured.last.headers['Authorization'], 'Bearer new-token');
      expect(adapter.captured.last.extra['authRetried'], true);
    });

    test('does not loop when retry request is still unauthorized', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final adapter = _QueueAdapter(<int>[401, 401]);
      final tokenProvider = _FakeAuthTokenProvider(
        token: 'old-token',
        refreshedToken: 'new-token',
      );
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(dio, tokenProvider));

      await expectLater(
        dio.get<dynamic>('/api/v1/trips'),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status',
            401,
          ),
        ),
      );

      expect(tokenProvider.refreshCalls, 1);
      expect(adapter.captured.length, 2);
    });

    test('does not retry when token refresh fails', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      final adapter = _QueueAdapter(<int>[401]);
      final tokenProvider = _FakeAuthTokenProvider(
        token: 'old-token',
        refreshedToken: null,
      );
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(dio, tokenProvider));

      await expectLater(
        dio.get<dynamic>('/api/v1/trips'),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status',
            401,
          ),
        ),
      );

      expect(tokenProvider.refreshCalls, 1);
      expect(adapter.captured.length, 1);
    });
  });
}
