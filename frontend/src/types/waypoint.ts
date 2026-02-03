export interface Waypoint {
  id: string;
  route_id: string;
  trip_id: string;
  user_id: string;
  lat: number;
  lng: number;
  name: string;
  waypoint_type: 'stop' | 'note' | 'photo' | 'poi';
  notes: string | null;
  order_in_route: number;
  stopped_at: string | null;
  created_at: string;
}
