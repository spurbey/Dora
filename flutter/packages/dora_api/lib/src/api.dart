//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart';
import 'package:dora_api/src/serializers.dart';
import 'package:dora_api/src/auth/api_key_auth.dart';
import 'package:dora_api/src/auth/basic_auth.dart';
import 'package:dora_api/src/auth/bearer_auth.dart';
import 'package:dora_api/src/auth/oauth.dart';
import 'package:dora_api/src/api/authentication_api.dart';
import 'package:dora_api/src/api/components_api.dart';
import 'package:dora_api/src/api/default_api.dart';
import 'package:dora_api/src/api/media_api.dart';
import 'package:dora_api/src/api/metadata_api.dart';
import 'package:dora_api/src/api/places_api.dart';
import 'package:dora_api/src/api/routes_api.dart';
import 'package:dora_api/src/api/search_api.dart';
import 'package:dora_api/src/api/trips_api.dart';
import 'package:dora_api/src/api/users_api.dart';

class DoraApi {
  static const String basePath = r'http://localhost';

  final Dio dio;
  final Serializers serializers;

  DoraApi({
    Dio? dio,
    Serializers? serializers,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : this.serializers = serializers ?? standardSerializers,
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get AuthenticationApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthenticationApi getAuthenticationApi() {
    return AuthenticationApi(dio, serializers);
  }

  /// Get ComponentsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ComponentsApi getComponentsApi() {
    return ComponentsApi(dio, serializers);
  }

  /// Get DefaultApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  DefaultApi getDefaultApi() {
    return DefaultApi(dio, serializers);
  }

  /// Get MediaApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MediaApi getMediaApi() {
    return MediaApi(dio, serializers);
  }

  /// Get MetadataApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MetadataApi getMetadataApi() {
    return MetadataApi(dio, serializers);
  }

  /// Get PlacesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PlacesApi getPlacesApi() {
    return PlacesApi(dio, serializers);
  }

  /// Get RoutesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RoutesApi getRoutesApi() {
    return RoutesApi(dio, serializers);
  }

  /// Get SearchApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SearchApi getSearchApi() {
    return SearchApi(dio, serializers);
  }

  /// Get TripsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  TripsApi getTripsApi() {
    return TripsApi(dio, serializers);
  }

  /// Get UsersApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  UsersApi getUsersApi() {
    return UsersApi(dio, serializers);
  }
}
