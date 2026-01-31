import { MediaFile } from './media';

// Matches backend TripPlace model
export interface Place {
  id: string;                           // UUID
  trip_id: string;                      // UUID
  user_id: string;                      // UUID
  name: string;
  lat: number;                          // -90 to 90
  lng: number;                          // -180 to 180
  place_type: string | null;            // 'restaurant', 'hotel', etc.
  user_notes: string | null;
  photos: MediaFile[];                  // Array of full media objects
  external_place_id: string | null;
  order_in_trip: number | null;
  created_at: string;                   // ISO datetime
  updated_at: string;                   // ISO datetime
}

// Matches backend PlaceCreate schema
export interface PlaceCreate {
  trip_id: string;                      // Required, UUID
  name: string;                         // Required, 1-200 chars
  lat: number;                          // Required, -90 to 90
  lng: number;                          // Required, -180 to 180
  place_type?: string;
  user_notes?: string;
  external_place_id?: string;
  order_in_trip?: number;
}

// Matches backend PlaceUpdate schema
export interface PlaceUpdate {
  name?: string;
  lat?: number;
  lng?: number;
  place_type?: string;
  user_notes?: string;
  order_in_trip?: number;
}

// Response wrapper for place list
export interface PlaceListResponse {
  places: Place[];
  total: number;
}
