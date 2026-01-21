# Mapbox API Integration

## Overview
Free tier: 100,000 requests/month per API
APIs used: Geocoding, Search, Directions (optional)

## Geocoding API

### Forward Geocoding (address → coordinates)
```bash
GET https://api.mapbox.com/geocoding/v5/mapbox.places/coffee%20Delhi.json?access_token=YOUR_TOKEN&proximity=77.2090,28.6139&types=poi
```

### Response
```json
{
  "features": [
    {
      "id": "poi.123456",
      "text": "Starbucks",
      "place_name": "Starbucks, Connaught Place, New Delhi",
      "center": [77.2090, 28.6319],
      "properties": {
        "category": "coffee, cafe"
      }
    }
  ]
}
```

### Reverse Geocoding (coordinates → address)
```bash
GET https://api.mapbox.com/geocoding/v5/mapbox.places/77.2090,28.6139.json?access_token=YOUR_TOKEN
```

## Mapping to Our Schema
```python
def map_mapbox_result(feature):
    return {
        "name": feature["text"],
        "lat": feature["center"][1],
        "lng": feature["center"][0],
        "address": feature.get("place_name"),
        "place_type": feature.get("properties", {}).get("category"),
        "source": "mapbox",
        "external_id": feature["id"],
        "can_claim": True
    }
```

## Usage in Search Service
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
        data = response.json()
        return [map_mapbox_result(f) for f in data.get("features", [])]
```

## Directions API (Optional)

### Request
```bash
GET https://api.mapbox.com/directions/v5/mapbox/driving/77.2090,28.6139;77.2345,28.6517?access_token=YOUR_TOKEN&geometries=geojson
```

### Response
```json
{
  "routes": [
    {
      "geometry": {
        "coordinates": [[77.2090, 28.6139], [77.2200, 28.6250], ...],
        "type": "LineString"
      },
      "distance": 5234.5,
      "duration": 892.3
    }
  ]
}
```

## Map Display (Mapbox GL JS)

### Frontend Integration
```typescript
import mapboxgl from 'mapbox-gl';

mapboxgl.accessToken = import.meta.env.VITE_MAPBOX_TOKEN;

const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/streets-v12',
  center: [77.2090, 28.6139],
  zoom: 12
});
```

## Rate Limits
- Geocoding: 100k requests/month free
- Map loads: 50k loads/month free
- Directions: 100k requests/month free

## Attribution
Required: "© Mapbox © OpenStreetMap"
Display in bottom-right of map