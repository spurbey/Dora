// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(AdvisoryActionRequest.serializer)
      ..add(AdvisoryActionResponse.serializer)
      ..add(AdvisoryCategory.serializer)
      ..add(AdvisoryDeliveryStatus.serializer)
      ..add(AdvisoryInsightListResponse.serializer)
      ..add(AdvisoryInsightResponse.serializer)
      ..add(AdvisoryJobListResponse.serializer)
      ..add(AdvisoryJobResponse.serializer)
      ..add(AdvisoryJobStage.serializer)
      ..add(AdvisoryJobStatus.serializer)
      ..add(AdvisoryJobType.serializer)
      ..add(AdvisoryQueryRequest.serializer)
      ..add(AdvisorySource.serializer)
      ..add(AdvisoryStartRequest.serializer)
      ..add(AppSchemasAuthUserResponse.serializer)
      ..add(AppSchemasUserUserResponse.serializer)
      ..add(AutoFinalizeCommitRequest.serializer)
      ..add(AutoFinalizeCommitResponse.serializer)
      ..add(AutoFinalizeCommitResponseStatusEnum.serializer)
      ..add(BudgetPerPerson.serializer)
      ..add(CheckinActionResponse.serializer)
      ..add(CheckinCandidateResponse.serializer)
      ..add(CheckinCandidateResponseStatusEnum.serializer)
      ..add(CheckinConfirmRequest.serializer)
      ..add(CheckinPlaceOverride.serializer)
      ..add(CheckinRejectRequest.serializer)
      ..add(CheckinSnoozeRequest.serializer)
      ..add(CompiledProjectionResponse.serializer)
      ..add(CompiledProjectionStats.serializer)
      ..add(CompiledRebindRequest.serializer)
      ..add(CompiledRouteSegment.serializer)
      ..add(CompiledTimelineDayGroup.serializer)
      ..add(CompiledTimelineEntry.serializer)
      ..add(ComponentReorderItem.serializer)
      ..add(ComponentReorderItemComponentTypeEnum.serializer)
      ..add(ComponentReorderRequest.serializer)
      ..add(ComponentReorderResponse.serializer)
      ..add(DeviceTokenActionResponse.serializer)
      ..add(DeviceTokenDeactivateRequest.serializer)
      ..add(DeviceTokenRegisterRequest.serializer)
      ..add(DeviceTokenRegisterRequestPlatformEnum.serializer)
      ..add(DeviceTokenResponse.serializer)
      ..add(DeviceTokenResponsePlatformEnum.serializer)
      ..add(ExportAspectRatio.serializer)
      ..add(ExportCancelResponse.serializer)
      ..add(ExportCreateRequest.serializer)
      ..add(ExportCreateResponse.serializer)
      ..add(ExportDownloadUrlResponse.serializer)
      ..add(ExportJobListResponse.serializer)
      ..add(ExportJobSummaryResponse.serializer)
      ..add(ExportQuality.serializer)
      ..add(ExportShareUrlResponse.serializer)
      ..add(ExportStage.serializer)
      ..add(ExportStatus.serializer)
      ..add(ExportStatusResponse.serializer)
      ..add(ExportTemplate.serializer)
      ..add(FuelCost.serializer)
      ..add(HTTPValidationError.serializer)
      ..add(LocationInner.serializer)
      ..add(MeResponse.serializer)
      ..add(MediaResponse.serializer)
      ..add(MomentCreateRequest.serializer)
      ..add(MomentListResponse.serializer)
      ..add(MomentLocation.serializer)
      ..add(MomentResponse.serializer)
      ..add(MomentResponseSource_Enum.serializer)
      ..add(MomentUpdateRequest.serializer)
      ..add(PendingCheckinsResponse.serializer)
      ..add(PlaceCreate.serializer)
      ..add(PlaceListResponse.serializer)
      ..add(PlaceMetadataCreate.serializer)
      ..add(PlaceMetadataResponse.serializer)
      ..add(PlaceMetadataUpdate.serializer)
      ..add(PlaceResponse.serializer)
      ..add(PlaceUpdate.serializer)
      ..add(RouteCreate.serializer)
      ..add(RouteCreateRouteCategoryEnum.serializer)
      ..add(RouteCreateTransportModeEnum.serializer)
      ..add(RouteGenerateRequest.serializer)
      ..add(RouteGenerateRequestModeEnum.serializer)
      ..add(RouteGenerateResponse.serializer)
      ..add(RouteListResponse.serializer)
      ..add(RouteMetadataCreate.serializer)
      ..add(RouteMetadataCreateRoadConditionEnum.serializer)
      ..add(RouteMetadataCreateRouteQualityEnum.serializer)
      ..add(RouteMetadataResponse.serializer)
      ..add(RouteMetadataResponseRoadConditionEnum.serializer)
      ..add(RouteMetadataResponseRouteQualityEnum.serializer)
      ..add(RouteMetadataUpdate.serializer)
      ..add(RouteMetadataUpdateRoadConditionEnum.serializer)
      ..add(RouteMetadataUpdateRouteQualityEnum.serializer)
      ..add(RouteResponse.serializer)
      ..add(RouteResponseRouteCategoryEnum.serializer)
      ..add(RouteResponseTransportModeEnum.serializer)
      ..add(RouteUpdate.serializer)
      ..add(SearchResponse.serializer)
      ..add(SearchResult.serializer)
      ..add(SearchResultDebug.serializer)
      ..add(TollCost.serializer)
      ..add(TrackingEventAcceptedResponse.serializer)
      ..add(TrackingEventInput.serializer)
      ..add(TrackingEventRejectedResponse.serializer)
      ..add(TrackingEventsBatchRequest.serializer)
      ..add(TrackingEventsBatchResponse.serializer)
      ..add(TrackingMediaAcceptedResponse.serializer)
      ..add(TrackingMediaBatchRequest.serializer)
      ..add(TrackingMediaBatchResponse.serializer)
      ..add(TrackingMediaInput.serializer)
      ..add(TrackingMediaInputBindModeEnum.serializer)
      ..add(TrackingMediaInputMediaTypeEnum.serializer)
      ..add(TrackingMediaRejectedResponse.serializer)
      ..add(TrackingMediaUploadResponse.serializer)
      ..add(TrackingPathPointResponse.serializer)
      ..add(TrackingPathResponse.serializer)
      ..add(TrackingPauseRequest.serializer)
      ..add(TrackingPointInput.serializer)
      ..add(TrackingPointsBatchRequest.serializer)
      ..add(TrackingPointsBatchResponse.serializer)
      ..add(TrackingResumeRequest.serializer)
      ..add(TrackingSessionResponse.serializer)
      ..add(TrackingSessionResponseStateEnum.serializer)
      ..add(TrackingSessionResponseTripStatusEnum.serializer)
      ..add(TrackingStartRequest.serializer)
      ..add(TrackingStopRequest.serializer)
      ..add(TripComponentDetailResponse.serializer)
      ..add(TripComponentDetailResponseComponentTypeEnum.serializer)
      ..add(TripComponentListResponse.serializer)
      ..add(TripComponentResponse.serializer)
      ..add(TripComponentResponseComponentTypeEnum.serializer)
      ..add(TripCreate.serializer)
      ..add(TripListResponse.serializer)
      ..add(TripMetadataCreate.serializer)
      ..add(TripMetadataResponse.serializer)
      ..add(TripMetadataUpdate.serializer)
      ..add(TripResponse.serializer)
      ..add(TripUpdate.serializer)
      ..add(UserActionType.serializer)
      ..add(UserProfileResponse.serializer)
      ..add(UserStats.serializer)
      ..add(UserUpdate.serializer)
      ..add(V2MediaManifestItem.serializer)
      ..add(V2PublishCommitRequest.serializer)
      ..add(V2PublishCommitResponse.serializer)
      ..add(V2PublishCommitResponseManifestPhaseEnum.serializer)
      ..add(V2PublishCommitResponseManifestStatusEnum.serializer)
      ..add(V2PublishMediaCompleteRequest.serializer)
      ..add(V2PublishMediaCompleteResponse.serializer)
      ..add(V2PublishMediaCompleteResponseManifestPhaseEnum.serializer)
      ..add(V2PublishMediaCompleteResponseManifestStatusEnum.serializer)
      ..add(V2PublishPayloadChunkRequest.serializer)
      ..add(V2PublishPayloadChunkResponse.serializer)
      ..add(V2PublishPayloadChunkResponseManifestPhaseEnum.serializer)
      ..add(V2PublishPayloadChunkResponseManifestStatusEnum.serializer)
      ..add(V2PublishStartRequest.serializer)
      ..add(V2PublishStartResponse.serializer)
      ..add(V2PublishStartResponseManifestPhaseEnum.serializer)
      ..add(V2PublishStartResponseManifestStatusEnum.serializer)
      ..add(V2PublishSummary.serializer)
      ..add(V2RoutePointResponse.serializer)
      ..add(V2RouteResponse.serializer)
      ..add(V2RouteSegmentResponse.serializer)
      ..add(V2SessionResponse.serializer)
      ..add(V2SessionStartRequest.serializer)
      ..add(V2SessionStopRequest.serializer)
      ..add(V2TimelineEntryResponse.serializer)
      ..add(V2TimelineResponse.serializer)
      ..add(V2UploadTarget.serializer)
      ..add(V2UploadedMediaRef.serializer)
      ..add(ValidationError.serializer)
      ..add(WaypointCreate.serializer)
      ..add(WaypointCreateWaypointTypeEnum.serializer)
      ..add(WaypointListResponse.serializer)
      ..add(WaypointResponse.serializer)
      ..add(WaypointResponseWaypointTypeEnum.serializer)
      ..add(WaypointUpdate.serializer)
      ..add(WaypointUpdateWaypointTypeEnum.serializer)
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(AdvisoryInsightResponse)]),
          () => ListBuilder<AdvisoryInsightResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(AdvisoryJobResponse)]),
          () => ListBuilder<AdvisoryJobResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                BuiltList, const [const FullType.nullable(JsonObject)])
          ]),
          () => ListBuilder<BuiltList<JsonObject?>>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject)
            ])
          ]),
          () => ListBuilder<BuiltMap<String, JsonObject?>>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject)
            ])
          ]),
          () => ListBuilder<BuiltMap<String, JsonObject?>>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject)
            ])
          ]),
          () => ListBuilder<BuiltMap<String, JsonObject?>>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CheckinCandidateResponse)]),
          () => ListBuilder<CheckinCandidateResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompiledTimelineEntry)]),
          () => ListBuilder<CompiledTimelineEntry>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompiledTimelineDayGroup)]),
          () => ListBuilder<CompiledTimelineDayGroup>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompiledRouteSegment)]),
          () => ListBuilder<CompiledRouteSegment>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompiledTimelineEntry)]),
          () => ListBuilder<CompiledTimelineEntry>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(CompiledTimelineEntry)]),
          () => ListBuilder<CompiledTimelineEntry>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ComponentReorderItem)]),
          () => ListBuilder<ComponentReorderItem>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(ExportJobSummaryResponse)]),
          () => ListBuilder<ExportJobSummaryResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(LocationInner)]),
          () => ListBuilder<LocationInner>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MediaResponse)]),
          () => ListBuilder<MediaResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltMap, const [
              const FullType(String),
              const FullType.nullable(JsonObject)
            ])
          ]),
          () => ListBuilder<BuiltMap<String, JsonObject?>>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MomentResponse)]),
          () => ListBuilder<MomentResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlaceResponse)]),
          () => ListBuilder<PlaceResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(RouteResponse)]),
          () => ListBuilder<RouteResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SearchResult)]),
          () => ListBuilder<SearchResult>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TrackingEventAcceptedResponse)]),
          () => ListBuilder<TrackingEventAcceptedResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TrackingEventRejectedResponse)]),
          () => ListBuilder<TrackingEventRejectedResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrackingEventInput)]),
          () => ListBuilder<TrackingEventInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TrackingMediaAcceptedResponse)]),
          () => ListBuilder<TrackingMediaAcceptedResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TrackingMediaRejectedResponse)]),
          () => ListBuilder<TrackingMediaRejectedResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrackingMediaInput)]),
          () => ListBuilder<TrackingMediaInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TrackingPathPointResponse)]),
          () => ListBuilder<TrackingPathPointResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrackingPointInput)]),
          () => ListBuilder<TrackingPointInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(TripComponentResponse)]),
          () => ListBuilder<TripComponentResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TripResponse)]),
          () => ListBuilder<TripResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(V2MediaManifestItem)]),
          () => ListBuilder<V2MediaManifestItem>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(V2RoutePointResponse)]),
          () => ListBuilder<V2RoutePointResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(V2RouteSegmentResponse)]),
          () => ListBuilder<V2RouteSegmentResponse>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(V2TimelineEntryResponse)]),
          () => ListBuilder<V2TimelineEntryResponse>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(V2UploadTarget)]),
          () => ListBuilder<V2UploadTarget>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(V2UploadedMediaRef)]),
          () => ListBuilder<V2UploadedMediaRef>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ValidationError)]),
          () => ListBuilder<ValidationError>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(WaypointResponse)]),
          () => ListBuilder<WaypointResponse>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
