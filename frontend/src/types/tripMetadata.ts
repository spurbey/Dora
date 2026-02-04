export interface TripMetadata {
  trip_id: string;
  traveler_type?: string[] | null;
  age_group?: 'gen-z' | 'millennial' | 'gen-x' | 'boomer' | null;
  travel_style?: string[] | null;
  difficulty_level?: 'easy' | 'moderate' | 'challenging' | 'extreme' | null;
  budget_category?: 'budget' | 'mid-range' | 'luxury' | null;
  activity_focus?: string[] | null;
  is_discoverable: boolean;
  tags?: string[] | null;
  quality_score: number;
  created_at: string;
  updated_at: string;
}

export interface TripMetadataCreate {
  traveler_type?: string[];
  age_group?: 'gen-z' | 'millennial' | 'gen-x' | 'boomer';
  travel_style?: string[];
  difficulty_level?: 'easy' | 'moderate' | 'challenging' | 'extreme';
  budget_category?: 'budget' | 'mid-range' | 'luxury';
  activity_focus?: string[];
  is_discoverable?: boolean;
  tags?: string[];
}

export type TripMetadataUpdate = TripMetadataCreate;
