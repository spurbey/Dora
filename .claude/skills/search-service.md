---
name: search-service
description: Multi-source place search pattern (local DB + Foursquare + Mapbox)
---

# Multi-Source Search Pattern

## Service structure:

File: `backend/app/services/search_service.py`
```python
import httpx
from sqlalchemy.orm import Session

class SearchService:
    def __init__(self, db: Session):
        self.db = db
    
    async def search_places(self, query: str, lat: float, lng: float, radius_km: float = 5):
        results = []
        
        # 1. Search local database
        local = self._search_local(query, lat, lng, radius_km)
        results.extend(local)
        
        # 2. If < 5 results, query Foursquare
        if len(results) < 5:
            fsq = await self._search_foursquare(query, lat, lng, radius_km)
            results.extend(fsq)
        
        # 3. If still < 5, query Mapbox
        if len(results) < 5:
            mapbox = await self._search_mapbox(query, lat, lng)
            results.extend(mapbox)
        
        # 4. Deduplicate and rank
        return self._deduplicate(results)[:10]
    
    def _search_local(self, query, lat, lng, radius_km):
        # PostGIS query
        sql = """
        SELECT * FROM trip_places
        WHERE to_tsvector(name) @@ plainto_tsquery(:query)
        AND ST_DWithin(location, ST_Point(:lng, :lat)::geography, :radius)
        """
        return self.db.execute(sql, {...}).fetchall()
    
    async def _search_foursquare(self, query, lat, lng, radius_km):
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://api.foursquare.com/v3/places/search",
                headers={"Authorization": FOURSQUARE_KEY},
                params={"query": query, "ll": f"{lat},{lng}"}
            )
            return response.json()["results"]
    
    async def _search_mapbox(self, query, lat, lng):
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"https://api.mapbox.com/geocoding/v5/mapbox.places/{query}.json",
                params={"access_token": MAPBOX_TOKEN, "proximity": f"{lng},{lat}"}
            )
            return response.json()["features"]
    
    def _deduplicate(self, results):
        # Fuzzy match by name + rounded coords
        seen = set()
        unique = []
        for r in results:
            key = (r['name'].lower(), round(r['lat'], 3), round(r['lng'], 3))
            if key not in seen:
                seen.add(key)
                unique.append(r)
        return unique
```

## Notes
- Query local DB first (fastest, free)
- External APIs are fallback only
- Cache external results in Redis (optional)
- Always attribute source in response