# Current Phase: Phase 1C - Places + PostGIS

Phase: 1C | Status: In Progress

## Progress
- [x] Session 8: Place Models with PostGIS ✅ COMPLETE
- [ ] Session 9: Place CRUD Endpoints (NEXT)
- [ ] Session 10: Geospatial Queries

## Session 9: Place API Endpoints (READY TO START)

Focus: Create Place REST API endpoints and integrate with PlaceService.

### Context from Previous Session (Session 8)
**Session 8 Complete:**
- ✅ Place schemas with coordinate validation (lat/lng)
- ✅ PlaceService with PostGIS Geography conversion
- ✅ Geospatial query: get_places_near_location (ST_DWithin)
- ✅ Trip ownership validation
- ✅ Order management in trip itinerary
- ✅ 17 unit tests, all passing

**PostGIS Implementation:**
- Geography(POINT, 4326) for location column
- WKT format: SRID=4326;POINT(lng lat)
- ST_DWithin for radius searches
- ST_Distance for proximity ordering
- GIST spatial index (fast queries)

### Tasks for Session 9
1. Create Place API routes in `backend/app/api/v1/places.py`
2. Implement POST /api/v1/places (create place with Geography conversion)
3. Implement GET /api/v1/places?trip_id={id} (list trip places, ordered)
4. Implement GET /api/v1/places/{id} (get place detail with access control)
5. Implement PATCH /api/v1/places/{id} (update place, recalculate Geography if coords change)
6. Implement DELETE /api/v1/places/{id} (delete place with ownership check)
7. Register places router in main.py
8. Integration tests by Codex (complex tests with Geography validation)

### Required Files
- `backend/app/api/v1/places.py` (new)
- `backend/app/main.py` (modify to register router)
- `backend/tests/test_place_endpoints.py` (new, by Codex)

### Key Technical Requirements
- **Geography Conversion:** Convert lat/lng to WKT format: `SRID=4326;POINT(lng lat)`
- **Access Control:** Check trip visibility for GET operations (private/unlisted/public)
- **Ownership:** Only trip owner can create/update/delete places
- **Order Management:** Auto-set order_in_trip if not provided (max + 1)
- **Authentication:** All endpoints require `Depends(get_current_user)`

### Success Criteria
- All endpoints work with proper authentication
- Geography conversion works (lat/lng → PostGIS POINT)
- Trip access control enforced (visibility-based)
- Ownership checks prevent unauthorized modifications
- Order management works correctly
- Integration tests pass (by Codex)

### Related PRD
`docs/phases/phase-1c-places.md`

Next: Session 10 - Advanced Geospatial Queries
