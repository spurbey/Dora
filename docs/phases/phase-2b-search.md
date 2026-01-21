# Phase 2B: Multi-Source Search

Duration: 3 sessions, Week 6-7
Goal: Search places from local DB + Foursquare + Mapbox

## Session 14: Search Service Architecture

### Objective
Design and implement multi-source search service structure.

### Tasks
1. Install httpx for async HTTP
```bash
   pip install httpx
```
   
2. Create search service
   File: backend/app/services/search_service.py
   
3. Implement _search_local method
```python
   def _search_local(self, query: str, lat: float, lng: float, radius_km: float):
       return self.db.query(TripPlace).filter(
           func.to_tsvector('english', TripPlace.name).match(query),
           func.ST_DWithin(
               TripPlace.location,
               func.ST_SetSRID(func.ST_MakePoint(lng, lat), 4326).cast(Geography),
               radius_km * 1000
           )
       ).limit(10).all()
```
   
4. Implement _search_foursquare method
```python
   async def _search_foursquare(self, query: str, lat: float, lng: float, radius_km: float):
       async with httpx.AsyncClient() as client:
           response = await client.get(
               "https://api.foursquare.com/v3/places/search",
               headers={"Authorization": settings.FOURSQUARE_API_KEY},
               params={
                   "query": query,
                   "ll": f"{lat},{lng}",
                   "radius": int(radius_km * 1000),
                   "limit": 10
               }
           )
           return response.json().get("results", [])
```
   
5. Implement _search_mapbox method
```python
   async def _search_mapbox(self, query: str, lat: float, lng: float):
       async with httpx.AsyncClient() as client:
           response = await client.get(
               f"https://api.mapbox.com/geocoding/v5/mapbox.places/{query}.json",
               params={
                   "access_token": settings.MAPBOX_API_KEY,
                   "proximity": f"{lng},{lat}",
                   "types": "poi",
                   "limit": 10
               }
           )
           return response.json().get("features", [])
```
   
6. Implement result mapping functions
   - map_foursquare_result
   - map_mapbox_result
   - map_local_result

### Success Criteria
- Service structure created
- Individual search methods work
- Can query each source independently
- Result mapping functions work

### Files Created
- backend/app/services/search_service.py

---

## Session 15: Search Endpoint Implementation

### Objective
Complete search endpoint with deduplication and ranking.

### Tasks
1. Implement _deduplicate method
```python
   def _deduplicate(self, results: list):
       seen = set()
       unique = []
       for r in results:
           key = (
               r['name'].lower().strip(),
               round(r['lat'], 3),
               round(r['lng'], 3)
           )
           if key not in seen:
               seen.add(key)
               unique.append(r)
       return unique
```
   
2. Implement search_places method
```python
   async def search_places(self, query: str, lat: float, lng: float, radius_km: float = 5):
       results = []
       
       # 1. Search local database
       local = self._search_local(query, lat, lng, radius_km)
       results.extend([self.map_local_result(p) for p in local])
       
       # 2. If < 5 results, search Foursquare
       if len(results) < 5:
           fsq = await self._search_foursquare(query, lat, lng, radius_km)
           results.extend([self.map_foursquare_result(r) for r in fsq])
       
       # 3. If still < 5, search Mapbox
       if len(results) < 5:
           mbx = await self._search_mapbox(query, lat, lng)
           results.extend([self.map_mapbox_result(f) for f in mbx])
       
       # 4. Deduplicate and rank
       unique = self._deduplicate(results)
       ranked = self._rank_results(unique, query)
       
       return ranked[:10]
```
   
3. Implement _rank_results method
   - Priority: user_contributed > has_user_content > external
   - Secondary: distance
   - Tertiary: rating/popularity
   
4. Create search routes
   File: backend/app/api/v1/search.py
   - GET /search/places
   
5. Implement endpoint
```python
   @router.get("/places")
   async def search_places(
       q: str,
       lat: float,
       lng: float,
       radius_km: float = 5.0,
       db: Session = Depends(get_db)
   ):
       service = SearchService(db)
       results = await service.search_places(q, lat, lng, radius_km)
       return {
           "results": results,
           "sources_used": list(set([r['source'] for r in results]))
       }
```
   
6. Register router

### Success Criteria
- Search endpoint works
- Queries multiple sources
- Deduplication works
- Results ranked correctly
- Source attribution present

### Files Created
- backend/app/api/v1/search.py

### Files Modified
- backend/app/services/search_service.py
- backend/app/main.py

---

## Session 16: Search Tests

### Objective
Test search functionality with mocked external APIs.

### Tasks
1. Install pytest-mock
```bash
   pip install pytest-mock
```
   
2. Create test fixtures for mocked responses
   File: backend/tests/test_search.py
   - mock_foursquare_response
   - mock_mapbox_response
   
3. Write tests
   - test_search_local_only (enough local results)
   - test_search_with_foursquare (< 5 local, adds Foursquare)
   - test_search_with_mapbox (< 5 after Foursquare, adds Mapbox)
   - test_search_deduplication (same place from multiple sources)
   - test_search_ranking (user content ranked higher)
   - test_search_no_results
   
4. Mock external APIs
```python
   def test_search_with_foursquare(client, mocker):
       mock_response = {
           "results": [
               {"name": "Test Place", "geocodes": {"main": {"latitude": 28.6, "longitude": 77.2}}}
           ]
       }
       mocker.patch('httpx.AsyncClient.get', return_value=MockResponse(mock_response))
       
       response = client.get("/api/v1/search/places?q=coffee&lat=28.6&lng=77.2")
       assert response.status_code == 200
       assert "foursquare" in [r['source'] for r in response.json()['results']]
```
   
5. Run tests
```bash
   pytest tests/test_search.py -v
```

### Success Criteria
- All tests pass
- External APIs mocked (don't make real calls)
- Deduplication tested
- Ranking tested
- Coverage >80%

### Files Created
- backend/tests/test_search.py

---

## Phase Completion Checklist
- [ ] Search service implemented
- [ ] Queries local DB + Foursquare + Mapbox
- [ ] Deduplication works
- [ ] Results ranked correctly
- [ ] Search endpoint works
- [ ] Tests pass with mocked APIs
- [ ] Source attribution present