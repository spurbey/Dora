# Trails Data Normalization for Search + Visualization

## Goal
Ingest trail datasets (for example GPX/GeoJSON exports or open sources) into Dora's existing schema in a way that improves:
- realistic place search
- map visualization quality
- trail discovery (not turn-by-turn navigation)

## Scope and Legal Note
- This document describes normalization and mapping only.
- If source data has usage restrictions (for example platform terms), ingest only through compliant exports or licensed/open datasets.

## Current Backend Constraints
- Search ranking currently runs on `trip_places` through full-text `search_vector`.
- Route geometry is stored in `routes.route_geojson` (GeoJSON LineString), but route geometry is not directly full-text indexed.
- Data model is user/trip scoped. There is no dedicated global `trail_catalog` table yet.

## Canonical Trail Object (Pre-DB)
Normalize every inbound record to this shape before writing to DB:

```json
{
  "source": "alltrails|usgs|osm|gpx_import",
  "source_id": "string-or-null",
  "source_url": "string-or-null",
  "name": "string",
  "geometry": {
    "type": "LineString",
    "coordinates": [[-122.5, 37.7], [-122.4, 37.8]]
  },
  "start_point": {"lat": 37.7, "lng": -122.5},
  "end_point": {"lat": 37.8, "lng": -122.4},
  "centroid": {"lat": 37.75, "lng": -122.45},
  "distance_km": 12.4,
  "duration_mins": 210,
  "elevation_gain_m": 640,
  "difficulty_text": "moderate",
  "route_type": "loop|out-and-back|point-to-point|unknown",
  "tags": ["waterfall", "forest", "dog-friendly"],
  "raw_properties": {}
}
```

## Mapping to Dora Schema

### 1) `trip_places` (Search Anchor)
Create one place per trail so it is discoverable in existing search.

Field mapping:
- `name` <- canonical `name`
- `place_type` <- `"trail"` (or `"trailhead"` if representing start node)
- `lat`, `lng`, `location` <- `centroid` (or start point if you prefer trailhead-centric UX)
- `user_notes` <- searchable summary string (distance, elevation, type, tags)
- `external_data` <- full source object + canonical fields
- `order_in_trip` <- index within import batch/trip

Why this matters:
- `search_vector` currently indexes `name + user_notes + place_type`, so trail facets should be included in `user_notes` or a future dedicated indexed column.

### 2) `routes` (Geometry + Movement)
Create one route row per trail polyline.

Field mapping:
- `name` <- canonical `name`
- `route_geojson` <- canonical `geometry`
- `transport_mode` <- `"foot"`
- `route_category` <- `"ground"`
- `distance_km` <- canonical `distance_km` (source or computed)
- `duration_mins` <- canonical `duration_mins` (source or estimated)
- `start_place_id`, `end_place_id` <- optional (nullable in current model)
- `description` <- short route description from tags/type
- `order_in_trip` <- sequence index

### 3) `place_metadata` (Trail Semantics for Discovery)
Attach metadata to the `trip_places` trail anchor.

Suggested mapping:
- `component_type` = `"activity"`
- `experience_tags` <- trail tags (`waterfall`, `forest`, `lake`, `viewpoint`)
- `best_for` <- inferred (`solo-travelers`, `families`, `photographers`, etc.)
- `duration_hours` <- `duration_mins / 60`
- `difficulty_rating` <- mapped from source difficulty
- `physical_demand` <- inferred from difficulty + elevation gain
- `best_time` <- source hint if available, else null
- `is_public` <- true for catalog/discovery imports

### 4) `route_metadata` (Route Quality Display)
Attach to route for route-level visual filters.

Suggested mapping:
- `route_quality` = `"scenic"` or `"offbeat"` (avoid `"fastest"` for hiking)
- `road_condition` = `"offroad"` (for most trails)
- `scenic_rating` <- source score or derived proxy
- `safety_rating` <- optional conservative default if unknown
- `highlights` <- tags like `waterfall`, `ridge`, `viewpoint`
- `is_public` <- true for catalog/discovery imports

## Metadata You Can Capture

### Directly from source files/APIs (if present)
- trail name
- geometry (LineString or segment list)
- distance
- estimated duration
- elevation gain/descent
- difficulty label
- route type (loop/out-and-back/point-to-point)
- tags/features
- source url/id

### Derived during normalization
- centroid/start/end coordinates
- recomputed distance from geometry
- elevation stats (min/max/gain/descent if elevation samples exist)
- average grade and steep sections
- loop detection
- bounding box (map fit)
- simplified geometry for fast rendering

## Difficulty Normalization
Use a deterministic map to keep filtering predictable:

```text
easy -> difficulty_rating 2, physical_demand low
moderate -> difficulty_rating 3, physical_demand medium
hard/challenging -> difficulty_rating 4, physical_demand high
expert/very hard -> difficulty_rating 5, physical_demand high
unknown -> nulls
```

## Dedupe Strategy
Build a stable identity key:
- primary: `source + source_id`
- fallback: `normalized_name + rounded_start_latlng + rounded_distance`

Duplicate check thresholds:
- name similarity >= 90%
- start point distance <= 75m
- distance delta <= 8%

On conflict:
- keep existing canonical record
- merge new raw payload into `external_data.sources[]`

## Search-Focused Write Pattern
For each imported trail:
1. Upsert `trip_places` anchor first.
2. Upsert `routes` geometry linked to same trip/user.
3. Upsert `place_metadata` and `route_metadata`.
4. Populate `user_notes` with searchable trail summary text.

Example `user_notes` template:
```text
Trail | 12.4 km | 640 m gain | moderate | loop | waterfall, forest
```

## Visualization-Focused Read Pattern
Use `routes.route_geojson` for map drawing and derive style from metadata:
- color by `difficulty_rating`
- line width by popularity or source confidence
- badges from `highlights` and `experience_tags`
- filters: distance band, elevation band, difficulty, route type, tags

## Recommended Catalog Approach (With Current Schema)
Because Dora is trip-centric, create a system-owned public trail library:
- one importer user (for example `trailbot`)
- one public trip per region/state/park
- each trail imported as one place anchor + one route

This works now without schema migration and keeps discovery/search compatible with existing APIs.

## Future Upgrade (Optional)
Add a first-class global `trail_catalog` table later if you need:
- non-trip-centric indexing
- better source synchronization
- per-source freshness/versioning
- faster faceted search at scale
