import type { Place } from '@/types/place';
import type { Route } from '@/types/route';

export interface TripComponent {
  id: string;
  trip_id: string;
  component_type: 'place' | 'route';
  name: string;
  order_in_trip: number;
  created_at: string;
}

export interface TripComponentListResponse {
  components: TripComponent[];
  total: number;
  trip_id: string;
}

export interface TripComponentDetailResponse {
  id: string;
  component_type: 'place' | 'route';
  order_in_trip: number;
  place_data: Place | null;
  route_data: Route | null;
}
