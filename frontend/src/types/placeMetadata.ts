export interface PlaceMetadata {
  place_id: string;
  component_type: 'city' | 'place' | 'activity' | 'accommodation' | 'food' | 'transport';
  experience_tags?: string[] | null;
  best_for?: string[] | null;
  budget_per_person?: number | null;
  duration_hours?: number | null;
  difficulty_rating?: number | null;
  physical_demand?: 'low' | 'medium' | 'high' | null;
  best_time?: 'sunrise' | 'morning' | 'afternoon' | 'sunset' | 'night' | 'anytime' | null;
  is_public: boolean;
  contribution_score: number;
  created_at: string;
  updated_at: string;
}

export interface PlaceMetadataCreate {
  component_type?: 'city' | 'place' | 'activity' | 'accommodation' | 'food' | 'transport';
  experience_tags?: string[];
  best_for?: string[];
  budget_per_person?: number;
  duration_hours?: number;
  difficulty_rating?: number;
  physical_demand?: 'low' | 'medium' | 'high';
  best_time?: 'sunrise' | 'morning' | 'afternoon' | 'sunset' | 'night' | 'anytime';
  is_public?: boolean;
}

export type PlaceMetadataUpdate = PlaceMetadataCreate;
