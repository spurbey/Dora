# Foursquare Places API Integration

## Overview
Free tier: 100,000 calls/month
Endpoint: https://api.foursquare.com/v3/places/search

## Authentication
Header: `Authorization: <YOUR_API_KEY>`

## Place Search

### Request
```bash
GET https://api.foursquare.com/v3/places/search?query=coffee&ll=28.6139,77.2090&radius=5000&limit=10
```

### Response
```json
{
  "results": [
    {
      "fsq_id": "4b058aebf964a520c5b122e3",
      "name": "Blue Tokai Coffee Roasters",
      "geocodes": {
        "main": {
          "latitude": 28.6517,
          "longitude": 77.2345
        }
      },
      "location": {
        "formatted_address": "Champa Gali, Delhi",
        "locality": "New Delhi",
        "region": "Delhi"
      },
      "categories": [
        {
          "id": 13035,
          "name": "Coffee Shop"
        }
      ]
    }
  ]
}
```

## Mapping to Our Schema
```python
def map_foursquare_result(result):
    return {
        "name": result["name"],
        "lat": result["geocodes"]["main"]["latitude"],
        "lng": result["geocodes"]["main"]["longitude"],
        "place_type": result["categories"][0]["name"] if result.get("categories") else None,
        "address": result["location"].get("formatted_address"),
        "source": "foursquare",
        "external_id": result["fsq_id"],
        "can_claim": True
    }
```

## Usage in Search Service
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
        data = response.json()
        return [map_foursquare_result(r) for r in data.get("results", [])]
```

## Rate Limits
- 100k calls/month free
- After: $0.05 per 1000 calls
- Cache results to reduce API calls

## Attribution
Display: "Powered by Foursquare" when showing Foursquare results