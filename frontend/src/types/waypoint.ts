export interface Waypoint {
  id: string;
  route_id: string;
  trip_id: string;
  user_id: string;
  lat: number;
  lng: number;
  name: string;
  waypoint_type: 'stop' | 'note' | 'photo' | 'poi';
  notes?: string | null;
  order_in_route: number;
  stopped_at?: string | null;
  created_at: string;
}

export interface WaypointCreate {
  lat: number;
  lng: number;
  name: string;
  waypoint_type: 'stop' | 'note' | 'photo' | 'poi';
  notes?: string;
  order_in_route: number;
  stopped_at?: string;
}

export interface WaypointUpdate {
  name?: string;
  waypoint_type?: 'stop' | 'note' | 'photo' | 'poi';
  notes?: string;
  lat?: number;
  lng?: number;
  order_in_route?: number;
  stopped_at?: string | null;
}

export interface TempWaypoint {
  lat: number;
  lng: number;
  route_id: string;
  insertIndex: number;
}
