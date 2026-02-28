import 'package:test/test.dart';
import 'package:dora_api/dora_api.dart';


/// tests for ExportsApi
void main() {
  final instance = DoraApi().getExportsApi();

  group(ExportsApi, () {
    // Cancel Export
    //
    //Future<ExportCancelResponse> cancelExportApiV1ExportsJobIdCancelPost(String jobId, String authorization) async
    test('test cancelExportApiV1ExportsJobIdCancelPost', () async {
      // TODO
    });

    // Create Export
    //
    //Future<ExportCreateResponse> createExportApiV1TripsTripIdExportPost(String tripId, String authorization, ExportCreateRequest exportCreateRequest) async
    test('test createExportApiV1TripsTripIdExportPost', () async {
      // TODO
    });

    // Get Export Download Url
    //
    //Future<ExportDownloadUrlResponse> getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet(String jobId, String authorization) async
    test('test getExportDownloadUrlApiV1ExportsJobIdDownloadUrlGet', () async {
      // TODO
    });

    // Get Export Share Url
    //
    //Future<ExportShareUrlResponse> getExportShareUrlApiV1ExportsJobIdShareGet(String jobId, String authorization) async
    test('test getExportShareUrlApiV1ExportsJobIdShareGet', () async {
      // TODO
    });

    // Get Export Status
    //
    //Future<ExportStatusResponse> getExportStatusApiV1ExportsJobIdGet(String jobId, String authorization) async
    test('test getExportStatusApiV1ExportsJobIdGet', () async {
      // TODO
    });

  });
}
