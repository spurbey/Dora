// Matches backend MediaFile model
export interface MediaFile {
  id: string;                           // UUID
  user_id: string;                      // UUID
  trip_place_id: string;                // UUID
  trip_id: string;                      // UUID (for cache invalidation)
  file_url: string;                     // Full Supabase URL
  file_type: string;                    // 'photo' or 'video'
  file_size_bytes: number | null;
  mime_type: string | null;             // 'image/jpeg', 'image/png', etc.
  width: number | null;
  height: number | null;
  thumbnail_url: string | null;         // Supabase transformation URL
  caption: string | null;
  taken_at: string | null;              // ISO datetime
  created_at: string;                   // ISO datetime
}

// For upload (multipart/form-data)
export interface MediaUploadData {
  file: File;                           // Required
  trip_place_id: string;                // Required, UUID
  caption?: string;
  taken_at?: string;                    // ISO datetime
}
