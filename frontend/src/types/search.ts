// Matches backend SearchResult (Session 16)
export interface SearchResult {
  id: string | null;                    // "local:uuid" or "foursquare:id"
  name: string;
  lat: number;
  lng: number;
  address: string | null;
  source: 'local' | 'foursquare';
  distance_m: number;
  rating: number | null;
  popularity: number | null;
  has_user_content: boolean;
  score?: number;                       // Only if backend ranking implemented
}

// Matches backend SearchResponse
export interface SearchResponse {
  results: SearchResult[];
  count: number;
  query: string;
}
