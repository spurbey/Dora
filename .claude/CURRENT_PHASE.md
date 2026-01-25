# Current Phase: Phase 1C - Places + PostGIS

Phase: 1C | Status: In Progress

## Progress
- [x] Session 8: Place Models with PostGIS ✅ COMPLETE
- [x] Session 9: Place CRUD Endpoints ✅ COMPLETE
- [ ] Session 10: Geospatial Queries (NEXT)

## Session 10: Geospatial Queries (READY TO START)

Focus: Implement PostGIS spatial queries and expose them via API endpoints.

### Context from Previous Session (Session 9)
**Session 9 Complete:**
- ✅ Place API routes in `backend/app/api/v1/places.py`
- ✅ POST/GET list/GET detail/PATCH/DELETE endpoints
- ✅ Visibility-based access control for read operations
- ✅ Ownership validation for create/update/delete
- ✅ Geography conversion: SRID=4326;POINT(lng lat)
- ✅ Order management with order_in_trip
- ✅ Integration tests (25 tests, all passing)

### Tasks for Session 10
1. Add calculate_distance method to PlaceService (use ST_Distance)
2. Add calculate_trip_bounds to TripService (min/max lat/lng)
3. Add GET /api/v1/places/nearby endpoint (use existing get_places_near_location)
4. Add GET /api/v1/trips/{id}/bounds endpoint
5. Write spatial tests in `backend/tests/test_places_spatial.py`

### Required Files
- `backend/app/services/place_service.py`
- `backend/app/services/trip_service.py`
- `backend/app/api/v1/places.py`
- `backend/app/api/v1/trips.py`
- `backend/tests/test_places_spatial.py`

### Success Criteria
- Nearby query returns places within radius
- Distance calculation accurate
- Bounds calculation works
- Tests pass
- PostGIS functions work correctly

### Related PRD
`docs/phases/phase-1c-places.md`

Next: Phase 2A - Media Upload
