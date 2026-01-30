export interface Trip {
  id: string;
  user_id: string;
  title: string;
  description: string | null;
  start_date: string | null;
  end_date: string | null;
  cover_photo_url: string | null;
  visibility: 'private' | 'unlisted' | 'public';
  views_count: number;
  saves_count: number;
  created_at: string;
  updated_at: string;
}

export interface TripCreate {
  title: string;
  description?: string;
  start_date?: string;
  end_date?: string;
  visibility?: 'private' | 'unlisted' | 'public';
}

export interface TripUpdate {
  title?: string;
  description?: string;
  start_date?: string;
  end_date?: string;
  visibility?: 'private' | 'unlisted' | 'public';
  cover_photo_url?: string;
}

export interface TripListResponse {
  trips: Trip[];
  total: number;
  page: number;
  page_size: number;
  total_pages: number;
}

export interface TripBounds {
  min_lat: number;
  min_lng: number;
  max_lat: number;
  max_lng: number;
  center_lat: number;
  center_lng: number;
}
