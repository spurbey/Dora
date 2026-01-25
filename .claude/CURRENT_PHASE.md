# Current Phase: Phase 1C - Places + PostGIS

Phase: 1C | Status: Ready to Start

## Progress
- [ ] Session 8: Place Models with PostGIS (NEXT)
- [ ] Session 9: Place CRUD Endpoints
- [ ] Session 10: Geospatial Queries

## Session 8: Place Models with PostGIS (READY TO START)

Focus: Create TripPlace model with PostGIS Geography types, schemas, and service layer.

### Context from Previous Phase (Phase 1B - Complete)
**Phase 1B Complete:**
- ✅ Trip schemas and service layer (Session 5)
- ✅ Trip REST API endpoints (Session 6)
- ✅ 5 endpoints: POST, GET list, GET detail, PATCH, DELETE
- ✅ Free tier limit enforcement (3 trips)
- ✅ Visibility-based access control (private/unlisted/public)
- ✅ Pagination and views tracking
- ✅ 44 tests total (15 service + 29 integration)

### Tasks for Session 8
1. Review existing TripPlace model from Session 2
2. Verify PostGIS Geography type is used (not Geometry)
3. Create Place schemas (PlaceBase, PlaceCreate, PlaceUpdate, PlaceResponse, PlaceListResponse)
4. Create PlaceService with geospatial methods:
   - create_place (add place to trip with lat/lng)
   - list_trip_places (get all places for a trip)
   - update_place (update place details)
   - delete_place (remove from trip)
   - get_places_near_location (geospatial query with radius)
5. Write unit tests for PlaceService

### Required Files
- `backend/app/models/place.py` (review existing)
- `backend/app/schemas/place.py` (new)
- `backend/app/services/place_service.py` (new)
- `backend/tests/test_place_service.py` (new, small tests by Claude)

### Key Technical Requirements
- **PostGIS Geography:** Use `Geography(geometry_type='POINT', srid=4326)` for location field
- **Coordinates:** Store as (longitude, latitude) - NOT (lat, lng)
- **Distance queries:** Use `ST_DWithin` for radius searches (meters)
- **SRID 4326:** WGS84 coordinate system for GPS coordinates
- **JSONB:** Photos stored as JSONB array of URLs

### Success Criteria
- TripPlace model uses PostGIS Geography type correctly
- Schemas validate coordinates (lat: -90 to 90, lng: -180 to 180)
- Service layer can create places with coordinates
- Geospatial queries work (find places within radius)
- Unit tests pass

### Related PRD
`docs/phases/phase-1c-places.md`

Next: Session 9 - Place API Endpoints
