import 'package:dio/dio.dart';

/// Transport adapter for export control-plane endpoints.
///
/// This is a 6A bridge until `dora_api` is regenerated with typed exports APIs.
class ExportApi {
  ExportApi(this._dio);

  final Dio _dio;

  /// Creates an export job for the provided backend trip id.
  Future<Map<String, dynamic>> createExportJob({
    required String serverTripId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/trips/$serverTripId/export',
      data: payload,
    );
    return response.data ?? const <String, dynamic>{};
  }
}
