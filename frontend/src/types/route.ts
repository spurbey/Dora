export interface Route {
  id: string;
  trip_id: string;
  user_id: string;
  name: string | null;
  description: string | null;
  transport_mode: 'car' | 'bike' | 'foot' | 'air' | 'bus' | 'train';
  route_category: 'ground' | 'air';
  start_place_id: string | null;
  end_place_id: string | null;
  route_geojson: GeoJSON.Geometry | GeoJSON.FeatureCollection;
  polyline_encoded: string | null;
  distance_km: number | null;
  duration_mins: number | null;
  order_in_trip: number;
  created_at: string;
  updated_at: string;
}

export interface RouteListResponse {
  routes: Route[];
  total: number;
}

export interface RouteCreate {
  route_geojson: GeoJSON.LineString;
  transport_mode: 'car' | 'bike' | 'foot' | 'air' | 'bus' | 'train';
  route_category: 'ground' | 'air';
  start_place_id?: string;
  end_place_id?: string;
  name?: string;
  description?: string;
  distance_km?: number;
  duration_mins?: number;
  order_in_trip: number;
}

export interface TempRoute {
  points: Array<{ lng: number; lat: number }>;
  preview?: {
    geojson: GeoJSON.LineString;
    distance_km: number;
    duration_mins: number;
  };
  transport_mode: 'car' | 'bike' | 'foot';
}
