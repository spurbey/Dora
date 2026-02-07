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

import 'package:dora_api/src/model/app_schemas_auth_user_response.dart';
import 'package:dora_api/src/model/app_schemas_user_user_response.dart';
import 'package:dora_api/src/model/budget_per_person.dart';
import 'package:dora_api/src/model/component_reorder_item.dart';
import 'package:dora_api/src/model/component_reorder_request.dart';
import 'package:dora_api/src/model/component_reorder_response.dart';
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
import 'package:dora_api/src/model/user_profile_response.dart';
import 'package:dora_api/src/model/user_stats.dart';
import 'package:dora_api/src/model/user_update.dart';
import 'package:dora_api/src/model/validation_error.dart';
import 'package:dora_api/src/model/waypoint_create.dart';
import 'package:dora_api/src/model/waypoint_list_response.dart';
import 'package:dora_api/src/model/waypoint_response.dart';
import 'package:dora_api/src/model/waypoint_update.dart';

part 'serializers.g.dart';

@SerializersFor([
  AppSchemasAuthUserResponse,
  AppSchemasUserUserResponse,
  BudgetPerPerson,
  ComponentReorderItem,
  ComponentReorderRequest,
  ComponentReorderResponse,
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
  UserProfileResponse,
  UserStats,
  UserUpdate,
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
