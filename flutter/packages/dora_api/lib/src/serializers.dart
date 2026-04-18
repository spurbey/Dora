//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:dora_api/src/date_serializer.dart';
import 'package:dora_api/src/model/date.dart';

import 'package:dora_api/src/model/advisory_action_request.dart';
import 'package:dora_api/src/model/advisory_action_response.dart';
import 'package:dora_api/src/model/advisory_category.dart';
import 'package:dora_api/src/model/advisory_delivery_status.dart';
import 'package:dora_api/src/model/advisory_insight_list_response.dart';
import 'package:dora_api/src/model/advisory_insight_response.dart';
import 'package:dora_api/src/model/advisory_job_list_response.dart';
import 'package:dora_api/src/model/advisory_job_response.dart';
import 'package:dora_api/src/model/advisory_job_stage.dart';
import 'package:dora_api/src/model/advisory_job_status.dart';
import 'package:dora_api/src/model/advisory_job_type.dart';
import 'package:dora_api/src/model/advisory_query_request.dart';
import 'package:dora_api/src/model/advisory_source.dart';
import 'package:dora_api/src/model/advisory_start_request.dart';
import 'package:dora_api/src/model/app_schemas_auth_user_response.dart';
import 'package:dora_api/src/model/app_schemas_user_user_response.dart';
import 'package:dora_api/src/model/budget_per_person.dart';
import 'package:dora_api/src/model/component_reorder_item.dart';
import 'package:dora_api/src/model/component_reorder_request.dart';
import 'package:dora_api/src/model/component_reorder_response.dart';
import 'package:dora_api/src/model/export_aspect_ratio.dart';
import 'package:dora_api/src/model/export_cancel_response.dart';
import 'package:dora_api/src/model/export_create_request.dart';
import 'package:dora_api/src/model/export_create_response.dart';
import 'package:dora_api/src/model/export_download_url_response.dart';
import 'package:dora_api/src/model/export_job_list_response.dart';
import 'package:dora_api/src/model/export_job_summary_response.dart';
import 'package:dora_api/src/model/export_quality.dart';
import 'package:dora_api/src/model/export_share_url_response.dart';
import 'package:dora_api/src/model/export_stage.dart';
import 'package:dora_api/src/model/export_status.dart';
import 'package:dora_api/src/model/export_status_response.dart';
import 'package:dora_api/src/model/export_template.dart';
import 'package:dora_api/src/model/fuel_cost.dart';
import 'package:dora_api/src/model/http_validation_error.dart';
import 'package:dora_api/src/model/location_inner.dart';
import 'package:dora_api/src/model/me_response.dart';
import 'package:dora_api/src/model/media_response.dart';
import 'package:dora_api/src/model/place_create.dart';
import 'package:dora_api/src/model/place_list_response.dart';
import 'package:dora_api/src/model/place_metadata_create.dart';
import 'package:dora_api/src/model/place_metadata_response.dart';
import 'package:dora_api/src/model/place_metadata_update.dart';
import 'package:dora_api/src/model/place_response.dart';
import 'package:dora_api/src/model/place_update.dart';
import 'package:dora_api/src/model/route_create.dart';
import 'package:dora_api/src/model/route_generate_request.dart';
import 'package:dora_api/src/model/route_generate_response.dart';
import 'package:dora_api/src/model/route_list_response.dart';
import 'package:dora_api/src/model/route_metadata_create.dart';
import 'package:dora_api/src/model/route_metadata_response.dart';
import 'package:dora_api/src/model/route_metadata_update.dart';
import 'package:dora_api/src/model/route_response.dart';
import 'package:dora_api/src/model/route_update.dart';
import 'package:dora_api/src/model/search_response.dart';
import 'package:dora_api/src/model/search_result.dart';
import 'package:dora_api/src/model/search_result_debug.dart';
import 'package:dora_api/src/model/toll_cost.dart';
import 'package:dora_api/src/model/trip_component_detail_response.dart';
import 'package:dora_api/src/model/trip_component_list_response.dart';
import 'package:dora_api/src/model/trip_component_response.dart';
import 'package:dora_api/src/model/trip_create.dart';
import 'package:dora_api/src/model/trip_list_response.dart';
import 'package:dora_api/src/model/trip_metadata_create.dart';
import 'package:dora_api/src/model/trip_metadata_response.dart';
import 'package:dora_api/src/model/trip_metadata_update.dart';
import 'package:dora_api/src/model/trip_response.dart';
import 'package:dora_api/src/model/trip_update.dart';
import 'package:dora_api/src/model/user_action_type.dart';
import 'package:dora_api/src/model/user_profile_response.dart';
import 'package:dora_api/src/model/user_stats.dart';
import 'package:dora_api/src/model/user_update.dart';
import 'package:dora_api/src/model/v2_media_manifest_item.dart';
import 'package:dora_api/src/model/v2_publish_commit_request.dart';
import 'package:dora_api/src/model/v2_publish_commit_response.dart';
import 'package:dora_api/src/model/v2_publish_media_complete_request.dart';
import 'package:dora_api/src/model/v2_publish_media_complete_response.dart';
import 'package:dora_api/src/model/v2_publish_payload_chunk_request.dart';
import 'package:dora_api/src/model/v2_publish_payload_chunk_response.dart';
import 'package:dora_api/src/model/v2_publish_start_request.dart';
import 'package:dora_api/src/model/v2_publish_start_response.dart';
import 'package:dora_api/src/model/v2_publish_summary.dart';
import 'package:dora_api/src/model/v2_route_point_response.dart';
import 'package:dora_api/src/model/v2_route_response.dart';
import 'package:dora_api/src/model/v2_route_segment_response.dart';
import 'package:dora_api/src/model/v2_session_response.dart';
import 'package:dora_api/src/model/v2_session_start_request.dart';
import 'package:dora_api/src/model/v2_session_stop_request.dart';
import 'package:dora_api/src/model/v2_timeline_entry_response.dart';
import 'package:dora_api/src/model/v2_timeline_response.dart';
import 'package:dora_api/src/model/v2_upload_target.dart';
import 'package:dora_api/src/model/v2_uploaded_media_ref.dart';
import 'package:dora_api/src/model/validation_error.dart';
import 'package:dora_api/src/model/waypoint_create.dart';
import 'package:dora_api/src/model/waypoint_list_response.dart';
import 'package:dora_api/src/model/waypoint_response.dart';
import 'package:dora_api/src/model/waypoint_update.dart';

part 'serializers.g.dart';

@SerializersFor([
  AdvisoryActionRequest,
  AdvisoryActionResponse,
  AdvisoryCategory,
  AdvisoryDeliveryStatus,
  AdvisoryInsightListResponse,
  AdvisoryInsightResponse,
  AdvisoryJobListResponse,
  AdvisoryJobResponse,
  AdvisoryJobStage,
  AdvisoryJobStatus,
  AdvisoryJobType,
  AdvisoryQueryRequest,
  AdvisorySource,
  AdvisoryStartRequest,
  AppSchemasAuthUserResponse,
  AppSchemasUserUserResponse,
  BudgetPerPerson,
  ComponentReorderItem,
  ComponentReorderRequest,
  ComponentReorderResponse,
  ExportAspectRatio,
  ExportCancelResponse,
  ExportCreateRequest,
  ExportCreateResponse,
  ExportDownloadUrlResponse,
  ExportJobListResponse,
  ExportJobSummaryResponse,
  ExportQuality,
  ExportShareUrlResponse,
  ExportStage,
  ExportStatus,
  ExportStatusResponse,
  ExportTemplate,
  FuelCost,
  HTTPValidationError,
  LocationInner,
  MeResponse,
  MediaResponse,
  PlaceCreate,
  PlaceListResponse,
  PlaceMetadataCreate,
  PlaceMetadataResponse,
  PlaceMetadataUpdate,
  PlaceResponse,
  PlaceUpdate,
  RouteCreate,
  RouteGenerateRequest,
  RouteGenerateResponse,
  RouteListResponse,
  RouteMetadataCreate,
  RouteMetadataResponse,
  RouteMetadataUpdate,
  RouteResponse,
  RouteUpdate,
  SearchResponse,
  SearchResult,
  SearchResultDebug,
  TollCost,
  TripComponentDetailResponse,
  TripComponentListResponse,
  TripComponentResponse,
  TripCreate,
  TripListResponse,
  TripMetadataCreate,
  TripMetadataResponse,
  TripMetadataUpdate,
  TripResponse,
  TripUpdate,
  UserActionType,
  UserProfileResponse,
  UserStats,
  UserUpdate,
  V2MediaManifestItem,
  V2PublishCommitRequest,
  V2PublishCommitResponse,
  V2PublishMediaCompleteRequest,
  V2PublishMediaCompleteResponse,
  V2PublishPayloadChunkRequest,
  V2PublishPayloadChunkResponse,
  V2PublishStartRequest,
  V2PublishStartResponse,
  V2PublishSummary,
  V2RoutePointResponse,
  V2RouteResponse,
  V2RouteSegmentResponse,
  V2SessionResponse,
  V2SessionStartRequest,
  V2SessionStopRequest,
  V2TimelineEntryResponse,
  V2TimelineResponse,
  V2UploadTarget,
  V2UploadedMediaRef,
  ValidationError,
  WaypointCreate,
  WaypointListResponse,
  WaypointResponse,
  WaypointUpdate,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
